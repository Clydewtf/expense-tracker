from sqlalchemy.orm import Session
from app.models.transaction import Transaction

class TransactionRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_all_by_user(self, user_id: int):
        return self.db.query(Transaction).filter(Transaction.user_id == user_id).all()

    def create(self, transaction: Transaction) -> Transaction:
        self.db.add(transaction)
        self.db.commit()
        self.db.refresh(transaction)
        return transaction