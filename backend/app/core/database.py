from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from supabase import create_client, Client
from app.core.config import settings

# SQLAlchemy for local development (optional) - commented out since using Supabase
# engine = create_engine(settings.DATABASE_URL)
# SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base = declarative_base()

# Supabase client for production
supabase: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_ANON_KEY)
# supabase_service: Client = create_client(settings.SUPABASE_URL, settings.SUPABASE_SERVICE_ROLE_KEY)

# Dependency to get DB session (for local dev) - commented out
# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()

# Dependency to get Supabase client
def get_supabase() -> Client:
    return supabase

# Dependency to get Supabase service role client (for admin operations)
# def get_supabase_service() -> Client:
#     return supabase_service
