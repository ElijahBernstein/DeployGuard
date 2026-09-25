import logging
import os
from pythonjsonlogger.json import JsonFormatter

def configure_logging() -> None:
    log_level = os.getenv("LOG_LEVEL", "INFO").upper()

    #handler outputs logging info to the terminal
    handler = logging.StreamHandler()

    formatter = JsonFormatter(
        "%(asctime)s %(levelname)s %(name)s %(message)s", 
        rename_fields={
            "asctime": "timestamp",
            "levelname": "level",
            "name": "logger",
            "message": "event",
        }
    )

    handler.setFormatter(formatter)

    root_logger = logging.getLogger()
    root_logger.handlers.clear()
    root_logger.addHandler(handler)
    root_logger.setLevel(log_level)