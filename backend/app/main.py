from fastapi import FastAPI
from app.core.config import settings
from app.core.db import engine, Base
from app.models import user, transaction

app = FastAPI(title=settings.PROJECT_NAME)
#Base.metadata.create_all(bind=engine)

@app.get("/ping")
def health_check():
    return {"status": "ok"}