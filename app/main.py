import os
from fastapi import FastAPI, HTTPException
import logging
from app.logging_config import configure_logging

configure_logging()
app = FastAPI(title="DeployGuard")
APP_VERSION = os.getenv("APP_VERSION") or "dev"

logger = logging.getLogger("deployguard")
logger.info(
    "application_started",
    extra={
        "service": "DeployGuard",
        "version": APP_VERSION,
    },
)

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
        logger.error(
            "health_check_failed", 
            extra={
                "service": "DeployGuard",
                "version": APP_VERSION,
                "status": "unhealthy",
                "reason": "forced_failure",
            }
        )
        raise HTTPException(
            status_code=503,
            detail="Service intentionally unhealthy"
        )

    return {"status": "healthy"}


@app.get("/version")
def version():
    return {"version": APP_VERSION}