# backend/tests/integration/test_db_connection.py
import pytest
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app.core.db import Base
from app.core.config import settings


def test_db_connection(db_session):
    # try to execute a simple query
    result = db_session.execute(text("SELECT 1")).scalar()
    assert result == 1
