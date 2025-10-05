# backend/tests/unit/test_user_model.py
import pytest
from datetime import datetime
from app.models.user import User


def test_user_model_creation():
    # create a new user instance
    user = User(
        email="test@example.com",
        password_hash="hashed_password"
    )

    # check if the user instance is created correctly
    assert user.email == "test@example.com"
    assert user.password_hash == "hashed_password"
    assert isinstance(user.created_at, datetime) or user.created_at is None
    