from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from supabase import Client
# Assuming these core modules exist in your project structure:
from app.core.auth import authenticate_user, create_access_token, get_current_user
from app.core.database import get_supabase
from app.core.config import settings
from app.schemas.user import Token, UserCreate, UserLogin

router = APIRouter()


@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    supabase: Client = Depends(get_supabase)
):
    """
    Login user and return JWT token.
    Uses OAuth2PasswordRequestForm which expects 'username' (email) and 'password'.
    """
    user = await authenticate_user(form_data.username, form_data.password, supabase)
    if not user:
        print(f"LOGIN FAILED: No user found for email {form_data.username}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    print(f"LOGIN SUCCESS: User {user.get('email')} with role {user.get('role')} logged in")

    # Generate JWT token upon successful authentication
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": form_data.username},
        expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@router.post("/signup", response_model=Token)
async def signup(
    user_data: UserCreate,
    supabase: Client = Depends(get_supabase)
):
    """
    Create new user account in auth.users, and corresponding profile and wallet rows.
    Includes cleanup if database insertion fails.
    """
    
    # Define a default CNIC value if the user did not provide one.
    # This is CRITICAL because the 'cnic' column is marked NOT NULL in the database
    # and UNIQUE, so the placeholder must be unique.
    # Truncate email to 15 chars to keep placeholder reasonable length
    default_cnic_placeholder = f"PENDING-CNIC-{user_data.email[:15]}" 
    
    auth_response = None
    try:
        # STEP 1: Create user in Supabase Auth (auth.users table)
        auth_response = supabase.auth.sign_up({
            "email": user_data.email,
            "password": user_data.password
        })

        if not auth_response.user:
            # This handles cases where user creation failed (e.g., bad password format)
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create user account (check email confirmation settings)"
            )
        
        user_id = auth_response.user.id
        
        # STEP 2: Create user profile in 'profiles' table (Requires RLS INSERT policy)
        profile_data = {
            "id": user_id,
            "email": user_data.email,
            "full_name": user_data.full_name,
            "phone_number": user_data.phone_number,
            "avatar_url": user_data.avatar_url,
            "role": "passenger",
            
            # FIX: Ensure CNIC is always included to satisfy NOT NULL constraint
            "cnic": user_data.cnic if user_data.cnic else default_cnic_placeholder
        }

        # Insert profile data (Must succeed for the wallet insert to work via FK)
        supabase.table('profiles').insert(profile_data).execute()
        
        # STEP 3: Create initial wallet record in 'wallets' table (Requires RLS INSERT policy)
        # The balance defaults to 0.00 in the schema, so only 'user_id' is required.
        wallet_data = {
            "user_id": user_id,
        }
        supabase.table('wallets').insert(wallet_data).execute()

        # STEP 4: Generate JWT token for immediate login
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user_data.email},
            expires_delta=access_token_expires
        )

        return {"access_token": access_token, "token_type": "bearer"}

    except Exception as e:
        # CRITICAL CLEANUP: If any database step fails (Step 2 or 3), 
        # delete the Auth user created in Step 1 to prevent orphans.
        if auth_response and auth_response.user:
            try:
                # Use admin client to ensure deletion
                supabase.auth.admin.delete_user(auth_response.user.id)
                print(f"CLEANUP SUCCESS: Deleted orphaned auth user {auth_response.user.id}")
            except Exception as delete_error:
                 print(f"CLEANUP WARNING: Failed to delete auth user {auth_response.user.id}: {str(delete_error)}")
            
        # Log the actual Supabase error for debugging
        print(f"SIGNUP ERROR: {str(e)}")
        
        # Enhanced Error Detail Mapping for client feedback
        error_detail = "Database error saving new user"
        error_message = str(e).lower()
        
        if "violates foreign key constraint" in error_message:
            error_detail = "User authentication failed - foreign key constraint"
        elif "duplicate key value" in error_message:
            error_detail = "Email or CNIC already registered"
        elif "not-null constraint" in error_message:
            error_detail = "Missing required profile data (NOT NULL constraint violation)."
        elif "permission denied for table" in error_message or "violates row-level security policy" in error_message:
            error_detail = "Database permission error - check RLS INSERT policy on 'profiles' and 'wallets'."

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create account: {error_detail}"
        )


@router.post("/refresh-token", response_model=Token)
async def refresh_token(
    current_user = Depends(get_current_user)
):
    """Refresh JWT token"""
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": current_user["email"]},
        expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me")
async def get_current_user_profile(
    current_user = Depends(get_current_user)
):
    """Get current authenticated user profile"""
    return current_user


@router.post("/logout")
async def logout(
    supabase: Client = Depends(get_supabase)
):
    """Logout user (client-side token deletion is sufficient)"""
    return {"message": "Successfully logged out"}


@router.post("/forgot-password")
async def forgot_password(
    email: str,
    supabase: Client = Depends(get_supabase)
):
    """
    Send password reset email to user.
    """
    try:
        # Send password reset email
        response = supabase.auth.reset_password_for_email(
            email,
            {
                "redirect_to": f"{settings.FRONTEND_URL}/reset-password"  # Configure this URL
            }
        )

        # Always return success for security (don't reveal if email exists)
        return {"message": "If an account with this email exists, we've sent you a password reset link."}

    except Exception as e:
        # Log error but return success message for security
        print(f"Forgot password error: {str(e)}")
        # Always return success to prevent email enumeration attacks
        return {"message": "If an account with this email exists, we've sent you a password reset link."}
