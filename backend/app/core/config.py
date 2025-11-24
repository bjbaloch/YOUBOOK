from typing import List, Optional
import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Project
    PROJECT_NAME: str = "YOUBOOK"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"

    # Security
    SECRET_KEY: str = "your-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Supabase
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "https://blycroutezsjhduujaai.supabase.co")
    SUPABASE_ANON_KEY: str = os.getenv("SUPABASE_ANON_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJseWNyb3V0ZXpzamhkdXVqYWFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4NDA4NTMsImV4cCI6MjA3MTQxNjg1M30.qcUskhKy_UR-IqWaECfI3j7CbJ66xtLCSedg6CKVkfQ")
    SUPABASE_SERVICE_ROLE_KEY: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "your-service-role-key")

    # Database (for local development)
    DATABASE_URL: str = os.getenv("DATABASE_URL", "postgresql://user:password@localhost/youbook")

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:3000",  # React dev server
        "http://localhost:8080",  # Vue dev server
        "http://127.0.0.1:8000",  # FastAPI
        "http://localhost:8000",
        "*",  # Allow all for demo - restrict in production
    ]

    # Encryption key for sensitive data
    ENCRYPTION_KEY: str = "your-encryption-key-32-chars-long"

    # Location/Geocoding
    OPENCAGE_API_KEY: str = os.getenv("OPENCAGE_API_KEY", "")

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
