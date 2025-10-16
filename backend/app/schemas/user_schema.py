from pydantic import BaseModel, EmailStr
from typing import Optional


class UserCreate(BaseModel):
    email: EmailStr
    password: str


class UserRead(BaseModel):
    id: int
    email: EmailStr
    default_currency: str

    class ConfigDict:
        from_attributes = True


class UserUpdate(BaseModel):
    default_currency: Optional[str] = None
