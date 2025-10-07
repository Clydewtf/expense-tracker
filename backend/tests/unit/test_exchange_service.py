import pytest
from unittest.mock import AsyncMock, patch
from app.services.exchange_service import ExchangeService


@pytest.mark.asyncio
async def test_get_rate_cache_hit_and_miss():
    # create mock for redis cache
    mock_cache = AsyncMock()
    mock_cache.get.return_value = None  # first cache miss
    mock_cache.set.return_value = None

    service = ExchangeService(cache=mock_cache)

    # mock fetch_rate
    async def mock_fetch_rate(base, target):
        return 1.23

    service.fetch_rate = mock_fetch_rate

    # cache miss
    rate = await service.get_rate("USD", "EUR")
    assert rate == 1.23
    mock_cache.set.assert_called_once()

    # cache hit
    mock_cache.get.return_value = {"rate": 1.23}
    rate2 = await service.get_rate("USD", "EUR")
    assert rate2 == 1.23
