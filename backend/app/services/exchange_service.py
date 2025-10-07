import requests
import aiohttp
from datetime import datetime, timezone
from app.core.config import settings
from app.services.cache_service import RedisCache


class ExchangeService:
    BASE_URL = "https://open.er-api.com/v6/latest"

    def __init__(self, cache: RedisCache | None = None):
        self.cache = cache or RedisCache()

    async def fetch_rate(self, base: str, target: str) -> float:
        """Fetch rate from external API."""
        async with aiohttp.ClientSession() as session:
            async with session.get(f"{self.BASE_URL}?base={base}&symbols={target}") as resp:
                data = await resp.json()

        rates = data.get("rates")
        if not rates or target not in rates:
            raise ValueError(f"API response invalid: {data}")
        return rates[target]

    async def get_rate(self, base: str, target: str) -> float:
        """Get exchange rate from cache or API."""
        key = f"exchange:{base}:{target}"

        # Check Redis
        cached = await self.cache.get(key)
        if cached:
            print(f"[CACHE HIT] {base}->{target}: {cached['rate']}")
            return cached["rate"]

        rate = await self.fetch_rate(base, target)

        # Save in Redis for 10 minutes (600 sec)
        await self.cache.set(key, {"rate": rate})

        print(f"[CACHE MISS] Saved new rate for {base}->{target}: {rate}")
        return rate
