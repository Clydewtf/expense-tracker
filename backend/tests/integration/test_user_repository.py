# backend/tests/integration/test_user_repository.py
import pytest
from app.core.config import settings
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.db import Base
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.core.security import hash_password


# testing create user
def test_create_user(user_repo):
    user = User(email="user_create@example.com", password_hash=hash_password("hashed123"))
    created_user = user_repo.create(user)

    assert created_user.id is not None
    assert created_user.email == "user_create@example.com"
    assert created_user.password_hash != "hashed123"


# testing get user by id
def test_get_by_id(user_repo, fake_user):
    fetched = user_repo.get_by_id(fake_user.id)
    assert fetched is not None
    assert fetched.email == fake_user.email


# testing get user by email
def test_get_by_email(user_repo, fake_user):
    fetched = user_repo.get_by_email(fake_user.email)
    assert fetched is not None
    assert fetched.id == fake_user.id
