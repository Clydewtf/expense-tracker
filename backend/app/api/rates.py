from fastapi import APIRouter, HTTPException, Query
from app.services.exchange_service import ExchangeService

router = APIRouter(prefix="/rates", tags=["Rates"])


exchange_service = ExchangeService()


@router.get("/")
async def get_rate(
    base: str = Query(..., min_length=3, max_length=3, description="Base currency (for ex., USD)"),
    target: str = Query(..., min_length=3, max_length=3, description="Target currency (for ex., EUR)")
):
    """
    Get the current exchange rate between two currencies.
    Uses Redis cache, if the exchange rate was requested previously.
    """
    try:
        rate = await exchange_service.get_rate(base.upper(), target.upper())
        return {
            "base": base.upper(),
            "target": target.upper(),
            "rate": rate
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Internal server error: {e}")
