from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.core.db import get_db
from app.models.transaction import Transaction
from app.repositories.transaction_repository import TransactionRepository
from app.schemas.transaction_schema import TransactionCreate, TransactionRead, TransactionUpdate
from app.core.security import get_current_user
from app.models.user import User

router = APIRouter(prefix="/transactions", tags=["transactions"])


@router.post("/", response_model=TransactionRead, status_code=status.HTTP_201_CREATED)
def create_transaction(
        transaction_in: TransactionCreate,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user)
):
    repo = TransactionRepository(db)
    transaction = Transaction(**transaction_in.model_dump(), user_id=current_user.id)
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


@router.put("/{transaction_id}", response_model=TransactionRead)
def update_transaction(
    transaction_id: int,
    transaction_in: TransactionUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    repo = TransactionRepository(db)
    transaction = repo.get_by_id(transaction_id)
    if not transaction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")

    if transaction.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized to update this transaction")

    updated = repo.update(transaction, transaction_in.model_dump(exclude_unset=True))
    return updated


@router.delete("/{transaction_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_transaction(transaction_id: int, db: Session = Depends(get_db)):
    repo = TransactionRepository(db)
    transaction = repo.get_by_id(transaction_id)
    if not transaction:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Transaction not found")
    repo.delete(transaction)
