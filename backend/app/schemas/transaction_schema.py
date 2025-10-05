from pydantic import BaseModel
from datetime import datetime


class TransactionCreate(BaseModel):
    amount: float
    currency: str
    category: str
    description: str | None = None
    date: datetime | None = None


class TransactionRead(BaseModel):
    id: int
    user_id: int
    amount: float
    currency: str
    category: str
    description: str | None
    date: datetime

    class ConfigDict:
        from_attributes = True
