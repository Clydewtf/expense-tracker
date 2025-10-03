# backend/tests/integration/test_db_connection.py
import pytest
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from app.core.db import Base
from app.core.config import settings

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

def test_db_connection(db_session):
    # try to execute a simple query
    result = db_session.execute(text("SELECT 1")).scalar()
    assert result == 1