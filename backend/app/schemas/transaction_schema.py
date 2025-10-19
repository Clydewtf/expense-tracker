from pydantic import BaseModel
from datetime import datetime
from enum import Enum


class TransactionType(str, Enum):
    income = "income"
    expense = "expense"


class TransactionCreate(BaseModel):
    amount: float
    currency: str
    category: str
    description: str | None = None
    date: datetime | None = None
    type: TransactionType = TransactionType.expense


class TransactionRead(BaseModel):
    id: int
    user_id: int
    amount: float
    currency: str
    category: str
    description: str | None
    date: datetime
    type: TransactionType

    class ConfigDict:
        from_attributes = True


class TransactionUpdate(BaseModel):
    amount: float | None = None
    currency: str | None = None
    category: str | None = None
    description: str | None = None
    date: datetime | None = None
    type: TransactionType | None = None
