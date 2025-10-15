# backend/tests/integration/test_transaction_repository.py
import pytest
from app.core.config import settings
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.db import Base
from app.models.user import User
from app.models.transaction import Transaction
from app.repositories.transaction_repository import TransactionRepository
from app.repositories.user_repository import UserRepository
from app.core.security import hash_password


# testing create transaction
def test_create_transaction(transaction_repo, user_repo, fake_user):
    transaction = Transaction(
        user_id=fake_user.id,
        amount=100.0,
        currency="USD",
        category="Food",
        description="Lunch"
    )
    created_tx = transaction_repo.create(transaction)

    assert created_tx.id is not None
    assert created_tx.amount == 100.0
    assert created_tx.user_id == fake_user.id


# testing get all user transactions
def test_get_all_by_user(transaction_repo, user_repo, fake_user):
    tx1 = Transaction(user_id=fake_user.id, amount=50, currency="USD", category="Transport")
    tx2 = Transaction(user_id=fake_user.id, amount=20, currency="USD", category="Coffee")
    transaction_repo.create(tx1)
    transaction_repo.create(tx2)

    transactions = transaction_repo.get_all_by_user(fake_user.id)
    assert len(transactions) == 2
    assert all(tx.user_id == fake_user.id for tx in transactions)


# testing get transaction by id
def test_get_by_id(transaction_repo, user_repo, fake_user):
    tx = Transaction(user_id=fake_user.id, amount=25, currency="USD", category="Coffee")
    created_tx = transaction_repo.create(tx)

    fetched = transaction_repo.get_by_id(created_tx.id)
    assert fetched is not None
    assert fetched.id == created_tx.id


# testing delete transaction
def test_delete_transaction(transaction_repo, user_repo, fake_user):
    tx = Transaction(user_id=fake_user.id, amount=50.0, currency="USD", category="Snacks")
    created_tx = transaction_repo.create(tx)

    transaction_repo.delete(created_tx)
    deleted = transaction_repo.get_by_id(created_tx.id)
    assert deleted is None
