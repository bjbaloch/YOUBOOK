from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client
from app.core.auth import get_current_user
from app.core.database import get_supabase
from app.schemas.user import User, UserUpdate, ManagerApplication, ManagerApplicationCreate

router = APIRouter()


@router.get("/", response_model=User)
async def get_profile(
    current_user = Depends(get_current_user)
):
    """Get current user profile"""
    return current_user


@router.put("/", response_model=User)
async def update_profile(
    user_update: UserUpdate,
    supabase: Client = Depends(get_supabase),
    current_user = Depends(get_current_user)
):
    """Update current user profile"""
    try:
        update_data = user_update.dict(exclude_unset=True)
        if update_data:
            update_data["updated_at"] = "now()"

            response = supabase.table('profiles').update(update_data).eq('id', current_user['id']).execute()

            if response.data:
                return response.data[0]

        return current_user
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to update profile: {str(e)}"
        )


# Manager Application Endpoints
@router.post("/apply-manager", response_model=ManagerApplication)
async def apply_for_manager(
    application: ManagerApplicationCreate,
    supabase: Client = Depends(get_supabase),
    current_user = Depends(get_current_user)
):
    """Apply to become a manager"""
    # Check if user already has a pending application
    existing_app = supabase.table('manager_applications').select('*').eq('user_id', current_user['id']).eq('status', 'pending').execute()

    if existing_app.data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You already have a pending application"
        )

    try:
        app_data = {
            "user_id": current_user['id'],
            "company_name": application.company_name,
            "credential_details": application.credential_details
        }

        response = supabase.table('manager_applications').insert(app_data).execute()
        return response.data[0]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to submit application: {str(e)}"
        )


@router.get("/manager-application", response_model=ManagerApplication)
async def get_manager_application(
    supabase: Client = Depends(get_supabase),
    current_user = Depends(get_current_user)
):
    """Get current user's manager application status"""
    response = supabase.table('manager_applications').select('*').eq('user_id', current_user['id']).execute()

    if not response.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No manager application found"
        )

    return response.data[0]
