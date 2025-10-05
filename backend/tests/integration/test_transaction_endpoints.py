# tests/integration/test_transaction_endpoints.py
import pytest
from fastapi import status
from app.models import Transaction


def test_create_transaction(client, fake_user):
    transaction = {
        "amount": 100.0,
        "currency": "USD",
        "category": "Food",
        "description": "Lunch"
    }
    response = client.post("/transactions/", json=transaction)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["amount"] == 100.0
    assert data["user_id"] is not None


def test_get_all_transactions(client, fake_user):
    response = client.get(f"/transactions/?user_id={fake_user.id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)


def test_get_transaction_by_id(client, transaction_repo, fake_user):
    tx = transaction_repo.create(
        Transaction(user_id=fake_user.id, amount=50, currency="USD", category="Coffee")
    )
    response = client.get(f"/transactions/{tx.id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == tx.id


def test_delete_transaction(client, transaction_repo, fake_user):
    tx = transaction_repo.create(
        Transaction(user_id=fake_user.id, amount=75, currency="USD", category="Snack")
    )
    response = client.delete(f"/transactions/{tx.id}")
    assert response.status_code == status.HTTP_204_NO_CONTENT

    # check that the transaction was deleted
    response_get = client.get(f"/transactions/{tx.id}")
    assert response_get.status_code == status.HTTP_404_NOT_FOUND
