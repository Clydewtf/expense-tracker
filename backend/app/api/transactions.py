from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.db import get_db
from app.models.transaction import Transaction
from app.repositories.transaction_repository import TransactionRepository
from app.schemas.transaction_schema import TransactionCreate, TransactionRead

router = APIRouter(prefix="/transactions", tags=["transactions"])


@router.post("/", response_model=TransactionRead, status_code=status.HTTP_201_CREATED)
def create_transaction(transaction_in: TransactionCreate, db: Session = Depends(get_db)):
    repo = TransactionRepository(db)
    transaction = Transaction(**transaction_in.dict(), user_id=1)  # TODO: временно user_id=1, позже заменить на JWT
    created = repo.create(transaction)
    return created


@router.get("/", response_model=list[TransactionRead])
def get_all_transactions(user_id: int, db: Session = Depends(get_db)):
    repo = TransactionRepository(db)
    transactions = repo.get_all_by_user(user_id)
    return transactions


@router.get("/{transaction_id}", response_model=TransactionRead)
def get_transaction_by_id(transaction_id: int, db: Session = Depends(get_db)):
    repo = TransactionRepository(db)
    transaction = repo.get_by_id(transaction_id)
    if not transaction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    return transaction


@router.delete("/{transaction_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_transaction(transaction_id: int, db: Session = Depends(get_db)):
    repo = TransactionRepository(db)
    transaction = repo.get_by_id(transaction_id)
    if not transaction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    repo.delete(transaction)
