import os
from fastapi import FastAPI, HTTPException

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
    force_unhealthy = os.getenv("FORCE_UNHEALTHY", "false").lower() == "true"

    if force_unhealthy:
        raise HTTPException(
            status_code=503,
            detail="Service intentionally unhealthy"
        )

    return {"status": "healthy"}


@app.get("/version")
def version():
    return {"version": APP_VERSION}