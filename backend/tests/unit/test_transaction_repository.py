# backend/tests/unit/test_transaction_repository.py
import pytest
from app.core.config import settings
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.db import Base
from app.models.user import User
from app.models.transaction import Transaction
from app.repositories.transaction_repository import TransactionRepository
from app.repositories.user_repository import UserRepository

# setup test db
engine = create_engine(settings.DATABASE_URL)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False)

# Fixture for db
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

# Fixture for transaction repository
@pytest.fixture
def transaction_repo(db_session):
    return TransactionRepository(db_session)

# Fixture for user repository
@pytest.fixture
def user_repo(db_session):
    return UserRepository(db_session)

# testing create transaction
def test_create_transaction(db_session, transaction_repo, user_repo):
    user = User(email="user1@example.com", password_hash="hashedpw")
    user_repo.create(user)

    transaction = Transaction(
        user_id=user.id,
        amount=100.0,
        currency="USD",
        category="Food",
        description="Lunch"
    )
    created_tx = transaction_repo.create(transaction)

    assert created_tx.id is not None
    assert created_tx.amount == 100.0
    assert created_tx.user_id == user.id

# testing get all user transactions
def test_get_all_by_user(db_session, transaction_repo, user_repo):
    user = User(email="user2@example.com", password_hash="hashedpw")
    user_repo.create(user)

    tx1 = Transaction(user_id=user.id, amount=50, currency="USD", category="Transport")
    tx2 = Transaction(user_id=user.id, amount=20, currency="USD", category="Coffee")
    transaction_repo.create(tx1)
    transaction_repo.create(tx2)

    transactions = transaction_repo.get_all_by_user(user.id)
    assert len(transactions) == 2
    assert all(tx.user_id == user.id for tx in transactions)