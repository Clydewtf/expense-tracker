# tests/integration/test_user_endpoints.py
import pytest
from fastapi import status
from app.models.user import User
from app.core.security import hash_password


def test_create_user(client, db_session):
    payload = {"email": "newuser@example.com", "password": "12345"}
    response = client.post("/users/", json=payload)

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["email"] == "newuser@example.com"
    assert "id" in data

    # check that the password was hashed correctly
    user_in_db = db_session.query(User).filter_by(email="newuser@example.com").first()
    assert user_in_db.password_hash != "12345"


def test_login(client, fake_user):
    transaction = {
        "email": fake_user.email,
        "password": "12345"
    }
    response = client.post("/users/login", json=transaction)

    assert response.status_code == 200
    data = response.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_get_user_by_id(client, fake_user):
    response = client.get(f"/users/{fake_user.id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["email"] == fake_user.email


def test_get_user_by_email(client, fake_user):
    response = client.get(f"/users/email/{fake_user.email}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["id"] == fake_user.id
