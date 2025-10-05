# backend/tests/conftest.py
import pytest
import uuid
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient

from app.core.config import settings
from app.core.db import Base, get_db
from app.main import app
from app.models.user import User
from app.core.security import hash_password, get_current_user
from app.repositories.transaction_repository import TransactionRepository
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


# Fixture for UserRepository
@pytest.fixture
def user_repo(db_session):
    return UserRepository(db_session)


# Fixture for TransactionRepository
@pytest.fixture
def transaction_repo(db_session):
    return TransactionRepository(db_session)


# fixture for client api
@pytest.fixture(scope="function")
def client(db_session):
    # override dependency for get_db in FastAPI to our test session
    def override_get_db():
        try:
            yield db_session
        finally:
            db_session.close()
    app.dependency_overrides[get_db] = override_get_db
    yield TestClient(app)
    app.dependency_overrides.clear()


# fixture for fake user
@pytest.fixture
def fake_user(db_session):
    #email = f"test_{uuid.uuid4().hex}@example.com"
    user = User(
        email="test@example.com",
        password_hash=hash_password("12345")
    )
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


@pytest.fixture(autouse=True)
def override_get_current_user(db_session, fake_user):
    def _get_current_user():
        # return object linked to current session
        return db_session.get(User, fake_user.id)

    app.dependency_overrides[get_current_user] = _get_current_user
    yield
    app.dependency_overrides.clear()

