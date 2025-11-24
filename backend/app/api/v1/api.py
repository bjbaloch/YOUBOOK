from fastapi import APIRouter

from app.api.v1.endpoints import auth, profiles

api_router = APIRouter()
api_router.include_router(auth.router, prefix="/auth", tags=["authentication"])
api_router.include_router(profiles.router, prefix="/profile", tags=["profiles"])
# api_router.include_router(managers.router, prefix="/manager", tags=["managers"])
# api_router.include_router(passengers.router, prefix="/passenger", tags=["passengers"])
# api_router.include_router(drivers.router, prefix="/driver", tags=["drivers"])
