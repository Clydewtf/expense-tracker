# backend/tests/unit/test_user_repository.py
import pytest
from app.core.config import settings
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.db import Base
from app.models.user import User
from app.repositories.user_repository import UserRepository

# setup test db
engine = create_engine(settings.DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False)

# fixture for db
@pytest.fixture(scope="function")
def db_session():
    connection = engine.connect()
    transaction = connection.begin()
    db = TestingSessionLocal(bind=connection)
    try:
        yield db
    finally:
        db.close()
        transaction.rollback()
        connection.close()

# fixture for user repository
@pytest.fixture
def user_repo(db_session):
    return UserRepository(db_session)

# testing create user
def test_create_user(user_repo):
    user = User(email="test@example.com", password_hash="hashed123")
    created_user = user_repo.create(user)
    assert created_user.id is not None
    assert created_user.email == "test@example.com"

# testing get user by id
def test_get_by_id(user_repo):
    user = User(email="byid@example.com", password_hash="hash456")
    user_repo.create(user)
    fetched = user_repo.get_by_id(user.id)
    assert fetched is not None
    assert fetched.email == "byid@example.com"

# testing get user by email
def test_get_by_email(user_repo):
    user = User(email="byemail@example.com", password_hash="hash789")
    user_repo.create(user)
    fetched = user_repo.get_by_email("byemail@example.com")
    assert fetched is not None
    assert fetched.id == user.id