from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.security import OAuth2PasswordRequestForm
from supabase import Client
from typing import List, Optional
from app.core.auth import require_role, authenticate_user, create_access_token
from app.core.database import get_supabase, get_supabase_service
from app.core.config import settings
from app.schemas.user import (
    User, ManagerApplication, NotificationCreate, Notification,
    Service, Vehicle, Route, Schedule, Booking, WalletTransaction,
    UserCreate, Token
)

router = APIRouter()

# Require admin role for all endpoints
admin_only = require_role("admin")


@router.post("/login", response_model=Token)
async def admin_login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    supabase: Client = Depends(get_supabase)
):
    """
    Admin login - verifies user has admin role before returning token.
    Uses OAuth2PasswordRequestForm which expects 'username' (email) and 'password'.
    """
    user = await authenticate_user(form_data.username, form_data.password, supabase)
    if not user:
        print(f"ADMIN LOGIN FAILED: No user found for email {form_data.username}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Check if user has admin role
    if user.get('role') != 'admin':
        print(f"ADMIN LOGIN FAILED: User {form_data.username} is not an admin (role: {user.get('role')})")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Access denied. Admin privileges required.",
        )

    print(f"ADMIN LOGIN SUCCESS: Admin {user.get('email')} logged in")

    # Generate JWT token upon successful authentication
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": form_data.username},
        expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}


@router.post("/signup")
async def signup_admin(
    user_data: UserCreate,
    supabase: Client = Depends(get_supabase)
):
    """Create a new admin user account that sends confirmation email"""
    # Define a default CNIC value if the user did not provide one.
    # This is CRITICAL because the 'cnic' column is marked NOT NULL in the database
    # and UNIQUE, so the placeholder must be unique.
    # Truncate email to 15 chars to keep placeholder reasonable length
    default_cnic_placeholder = f"PENDING-CNIC-{user_data.email[:15]}"

    try:
        # Use the same approach as regular signup - set metadata and let SQL trigger handle profile creation
        auth_response = supabase.auth.sign_up({
            "email": user_data.email,
            "password": user_data.password,
            "data": {
                "full_name": user_data.full_name,
                "phone_number": user_data.phone_number,
                "cnic": user_data.cnic if user_data.cnic else default_cnic_placeholder,
                "role": "admin",  # Explicitly set admin role in metadata
                "avatar_url": user_data.avatar_url
            }
        })

        if not auth_response.user:
            # This handles cases where user creation failed (e.g., bad password format)
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create admin account (check email confirmation settings)"
            )

        return {"message": "Admin account created successfully. Please check your email for the confirmation link."}

    except Exception as e:
        # Log the actual Supabase error for debugging
        print(f"ADMIN SIGNUP ERROR: {str(e)}")

        # Enhanced Error Detail Mapping for client feedback
        error_detail = "Failed to create admin account"
        error_message = str(e).lower()

        if "user already registered" in error_message or "email address already exists" in error_message:
            error_detail = "Email address is already registered. Try logging in instead."
        elif "password" in error_message and "weak" in error_message:
            error_detail = "Password is too weak. Please choose a stronger password."

        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=error_detail
        )


@router.post("/resend-confirmation")
async def resend_admin_confirmation(
    email: str,
    supabase_service: Client = Depends(get_supabase_service)
):
    """Resend confirmation email for admin signup"""
    try:
        # Check if user exists and is not confirmed
        user_response = supabase_service.auth.admin.get_user_by_email(email)
        if not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        user = user_response.user
        if user.email_confirmed_at:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User is already confirmed"
            )

        # Generate a new signup confirmation link (this should trigger email resend in Supabase)
        link_response = supabase_service.auth.admin.generate_link({
            "email": email,
            "type": "signup",
            "options": {
                "redirect_to": settings.ADMIN_APP_DEEP_LINK  # Admin app deep link
            }
        })

        # Note: generate_link returns the link but may not automatically resend email
        # In production, you might need to configure email templates or send manually
        return {"message": "Confirmation email resent. Please check your email (including spam folder)."}

    except Exception as e:
        print(f"RESEND CONFIRMATION ERROR: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Failed to resend confirmation email"
        )


@router.get("/users", response_model=List[User])
async def get_all_users(
    supabase: Client = Depends(get_supabase),
    current_admin = Depends(admin_only),
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=1000),
    role: Optional[str] = None,
    search: Optional[str] = None
):
    """Get all users with optional filtering"""
    query = supabase.table('profiles').select('*')

    if role:
        query = query.eq('role', role)

    if search:
        query = query.or_(f"email.ilike.%{search}%,full_name.ilike.%{search}%")

    response = query.range(skip, skip + limit - 1).execute()
    return response.data


@router.put("/users/{user_id}/role")
async def update_user_role(
    user_id: str,
    role: str,
    supabase: Client = Depends(get_supabase),
    current_admin = Depends(admin_only)
):
    """Update user role"""
    if role not in ['passenger', 'manager', 'driver', 'admin']:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid role"
        )

    response = supabase.table('profiles').update({'role': role}).eq('id', user_id).execute()

    if not response.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    return {"message": f"User role updated to {role}"}


@router.get("/manager-applications", response_model=List[ManagerApplication])
async def get_manager_applications(
    supabase: Client = Depends(get_supabase),
    current_admin = Depends(admin_only),
    status_filter: Optional[str] = Query(None, alias="status")
):
    """Get all manager applications"""
    query = supabase.table('manager_applications').select('*, profiles!inner(email, full_name)')

    if status_filter:
        query = query.eq('status', status_filter)

    response = query.execute()
    return response.data


@router.post("/manager-applications/{application_id}/approve")
async def approve_manager_application(
    application_id: str,
    review_notes: Optional[str] = None,
    supabase: Client = Depends(get_supabase),
    current_admin = Depends(admin_only)
):
    """Approve manager application"""
    # Get application
    app_response = supabase.table('manager_applications').select('*').eq('id', application_id).execute()

    if not app_response.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )

    application = app_response.data[0]

    # Update application status
    update_data = {
        'status': 'approved',
        'reviewed_by': current_admin['id']
    }
    if review_notes:
        update_data['review_notes'] = review_notes

    supabase.table('manager_applications').update(update_data).eq('id', application_id).execute()

    # The trigger will automatically update user role
    return {"message": "Manager application approved"}


@router.post("/manager-applications/{application_id}/reject")
async def reject_manager_application(
    application_id: str,
    review_notes: Optional[str] = None,
    supabase: Client = Depends(get_supabase),
    current_admin = Depends(admin_only)
):
    """Reject manager application"""
    update_data = {
        'status': 'rejected',
        'reviewed_by': current_admin['id']
    }
    if review_notes:
        update_data['review_notes'] = review_notes

    response = supabase.table('manager_applications').update(update_data).eq('id', application_id).execute()

    if not response.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )

    return {"message": "Manager application rejected"}


@router.post("/notifications/broadcast")
async def send_broadcast_notification(
    notification: NotificationCreate,
    supabase: Client = Depends(get_supabase),
    current_admin = Depends(admin_only)
):
    """Send notification to all users"""
    # Get all user IDs
    users_response = supabase.table('profiles').select('id').execute()
    user_ids = [user['id'] for user in users_response.data]

    # Insert notifications for all users
    notifications_data = [
        {
            'user_id': user_id,
            'title': notification.title,
            'message': notification.message,
            'type': notification.type,
            'data': {}
        }
        for user_id in user_ids
    ]

    supabase.table('notifications').insert(notifications_data).execute()

    return {"message": f"Broadcast notification sent to {len(user_ids)} users"}


@router.post("/notifications/user/{user_id}")
async def send_user_notification(
    user_id: str,
    notification: NotificationCreate,
    supabase: Client = Depends(get_supabase),
    current_admin = Depends(admin_only)
):
    """Send notification to specific user"""
    # Check if user exists
    user_check = supabase.table('profiles').select('id').eq('id', user_id).execute()
    if not user_check.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )

    notification_data = {
        'user_id': user_id,
        'title': notification.title,
        'message': notification.message,
        'type': notification.type,
        'data': {}
    }

    supabase.table('notifications').insert(notification_data).execute()

    return {"message": "Notification sent to user"}


@router.get("/stats")
async def get_system_stats(
    supabase: Client = Depends(get_supabase),
    current_admin = Depends(admin_only)
):
    """Get system statistics"""
    stats = {}

    # User counts by role
    users_response = supabase.table('profiles').select('role').execute()
    role_counts = {}
    for user in users_response.data:
        role = user['role']
        role_counts[role] = role_counts.get(role, 0) + 1
    stats['users_by_role'] = role_counts

    # Manager applications
    apps_response = supabase.table('manager_applications').select('status').execute()
    app_counts = {}
    for app in apps_response.data:
        status_val = app['status']
        app_counts[status_val] = app_counts.get(status_val, 0) + 1
    stats['manager_applications'] = app_counts

    # Total counts (if tables exist)
    try:
        bookings_count = supabase.table('bookings').select('id', count='exact').execute()
        stats['total_bookings'] = bookings_count.count
    except:
        stats['total_bookings'] = 0

    try:
        schedules_count = supabase.table('schedules').select('id', count='exact').execute()
        stats['total_schedules'] = schedules_count.count
    except:
        stats['total_schedules'] = 0

    return stats


# Additional endpoints for managing other entities would go here
# (services, vehicles, routes, schedules, bookings, etc.)
# For now, focusing on core admin functionality
