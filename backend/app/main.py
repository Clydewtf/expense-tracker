from fastapi import FastAPI
from app.core.config import settings
from app.core.db import engine, Base
from app.models import user, transaction
from app.api.users import router as user_router
from app.api.transactions import router as transaction_router

app = FastAPI(title=settings.PROJECT_NAME)
app.include_router(user_router)
app.include_router(transaction_router)
#Base.metadata.create_all(bind=engine)

@app.get("/ping")
def health_check():
    return {"status": "ok"}