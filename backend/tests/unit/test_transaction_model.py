# backend/tests/unit/test_transaction_model.py
import pytest
from datetime import datetime
from app.models.transaction import Transaction
from app.models.user import User

def test_transaction_creation():
    """
    Check that an object Transaction is created correctly
    and the relationships with User works.
    """

    # create "user"
    user = User(id=1, email="test@example.com", password_hash="hashed")

    # create transaction
    transaction = Transaction(
        id=1,
        user_id=user.id,
        amount=150.0,
        currency="USD",
        category="Food",
        description="Lunch",
        date=datetime(2025, 10, 1, 12, 0, 0),
        user=user
    )

    # check fields
    assert transaction.id == 1
    assert transaction.user_id == user.id
    assert transaction.amount == 150.0
    assert transaction.currency == "USD"
    assert transaction.category == "Food"
    assert transaction.description == "Lunch"
    assert transaction.date == datetime(2025, 10, 1, 12, 0, 0)
    assert transaction.user.email == "test@example.com"