from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.db import engine, Base
from app.models import user, transaction
from app.api.users import router as user_router
from app.api.transactions import router as transaction_router
from app.api.rates import router as rate_router


app = FastAPI(title=settings.PROJECT_NAME)
app.include_router(user_router)
app.include_router(transaction_router)
app.include_router(rate_router)
#Base.metadata.create_all(bind=engine)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/ping")
def health_check():
    return {"status": "ok"}
