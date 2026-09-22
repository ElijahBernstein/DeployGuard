import os
from fastapi import FastAPI

app = FastAPI(title="DeployGuard")
APP_VERSION = os.getenv("APP_VERSION") or "dev"

@app.get("/")
def root():
    return {
        "service": "DeployGuard",
        "message": "Deployment service is running",
    }


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/version")
def version():
    return {"version": APP_VERSION}