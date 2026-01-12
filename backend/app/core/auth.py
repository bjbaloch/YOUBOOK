from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from supabase import Client
from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from app.core.config import settings
from app.core.database import get_supabase

# Password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT token handling
oauth2_scheme = HTTPBearer()

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

async def authenticate_user(email: str, password: str, supabase: Client):
    """Authenticate user with Supabase"""
    try:
        print(f"AUTHENTICATE: Attempting login for {email}")

        # Sign in with Supabase Auth
        response = supabase.auth.sign_in_with_password({
            "email": email,
            "password": password
        })

        print(f"AUTHENTICATE: Supabase auth response - user: {response.user is not None}, session: {response.session is not None}")

        # If authentication successful, get user profile data
        if response.user and response.session:
            print(f"AUTHENTICATE: Getting profile for user ID: {response.user.id}")
            user_response = supabase.table('profiles').select('*').eq('email', email).execute()
            print(f"AUTHENTICATE: Profile query result: {len(user_response.data) if user_response.data else 0} records")

            if user_response.data:
                user_data = user_response.data[0]
                print(f"AUTHENTICATE: Found user profile - role: {user_data.get('role')}, email: {user_data.get('email')}")
                return user_data  # Return user profile data
            else:
                print(f"AUTHENTICATE: No profile found for email {email}")
        else:
            print(f"AUTHENTICATE: Supabase auth failed")
        return None
    except Exception as e:
        print(f"AUTHENTICATE: Exception - {str(e)}")
        return None

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(oauth2_scheme),
    supabase: Client = Depends(get_supabase)
):
    """Get current authenticated user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(credentials.credentials, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    # Get user from Supabase
    try:
        user_response = supabase.table('profiles').select('*').eq('email', email).execute()
        if not user_response.data:
            raise credentials_exception
        return user_response.data[0]
    except Exception:
        raise credentials_exception

async def get_current_active_user(current_user = Depends(get_current_user)):
    """Get current active user"""
    return current_user

def require_role(required_role: str):
    """Dependency to check user role"""
    async def role_checker(current_user = Depends(get_current_active_user)):
        if current_user.get("role") != required_role:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Access denied. Required role: {required_role}",
            )
        return current_user
    return role_checker
