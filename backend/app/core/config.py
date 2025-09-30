import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Expense Tracker API"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_DB: str = "expense_db"
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: str = "5432"
    JWT_SECRET: str = "supersecret"   # лучше потом вынести в env
    JWT_ALGORITHM: str = "HS256"

    @property
    def DATABASE_URL(self):
        return (
            f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

settings = Settings()