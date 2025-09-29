from fastapi import FastAPI

app = FastAPI(title="Expense Tracker Backend")

@app.get("/")
async def root():
    return {"message": "Backend is running"}