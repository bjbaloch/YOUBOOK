from typing import Optional, List, Dict, Any
from uuid import UUID
from pydantic import BaseModel, EmailStr
from datetime import datetime


class UserBase(BaseModel):
    email: EmailStr
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    avatar_url: Optional[str] = None
    cnic: Optional[str] = None


class UserCreate(UserBase):
    password: str


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(UserBase):
    company_name: Optional[str] = None
    credential_details: Optional[str] = None


class UserInDBBase(UserBase):
    id: UUID
    role: str
    manager_id: Optional[UUID] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class User(UserInDBBase):
    pass


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    email: Optional[str] = None


# Manager Application Schemas
class ManagerApplicationBase(BaseModel):
    company_name: str
    credential_details: str


class ManagerApplicationCreate(ManagerApplicationBase):
    pass


class ManagerApplication(ManagerApplicationBase):
    id: UUID
    user_id: UUID
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class ManagerApproval(BaseModel):
    approved: bool
    company_name: Optional[str] = None


# Service Schemas
class ServiceBase(BaseModel):
    name: str
    type: str  # 'transport', 'accommodation', 'rental'


class Service(ServiceBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# Vehicle Schemas
class VehicleBase(BaseModel):
    name: str
    registration_plate: str
    total_seats: int
    seat_map_json: Optional[Dict[str, Any]] = None


class VehicleCreate(VehicleBase):
    service_id: UUID


class Vehicle(VehicleBase):
    id: UUID
    manager_id: UUID
    service_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Location/Route Schemas
class LocationPoint(BaseModel):
    latitude: float
    longitude: float


class RouteBase(BaseModel):
    name: str
    start_location: LocationPoint
    end_location: LocationPoint
    distance_km: Optional[float] = None
    estimated_duration_minutes: Optional[int] = None


class Route(RouteBase):
    id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# Schedule Schemas
class ScheduleBase(BaseModel):
    departure_time: datetime
    arrival_time: datetime
    price_per_seat: float


class ScheduleCreate(ScheduleBase):
    vehicle_id: UUID
    route_id: UUID


class Schedule(ScheduleBase):
    id: UUID
    vehicle_id: UUID
    route_id: UUID
    driver_id: Optional[UUID] = None
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Booking Schemas
class BookingBase(BaseModel):
    seat_numbers: List[str]
    pickup_location: Optional[LocationPoint] = None


class BookingCreate(BookingBase):
    schedule_id: UUID


class BookingUpdate(BaseModel):
    status: Optional[str] = None
    is_picked_up: Optional[bool] = None


class Booking(BookingBase):
    id: UUID
    passenger_id: UUID
    schedule_id: UUID
    total_price: float
    status: str
    passenger_cnic: str  # Will be encrypted
    is_picked_up: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Live Location Schemas
class LiveLocationBase(BaseModel):
    location: LocationPoint
    speed_kmh: Optional[float] = None
    heading: Optional[float] = None


class LiveLocationCreate(LiveLocationBase):
    schedule_id: UUID


class LiveLocation(LiveLocationBase):
    id: UUID
    schedule_id: UUID
    timestamp: datetime

    class Config:
        from_attributes = True


# Wallet Schemas
class WalletBase(BaseModel):
    balance: float = 0.0


class Wallet(WalletBase):
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class WalletTransactionBase(BaseModel):
    amount: float
    type: str  # 'credit', 'debit'
    description: Optional[str] = None
    reference_id: Optional[UUID] = None


class WalletTransaction(WalletTransactionBase):
    id: UUID
    wallet_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


# Notification Schemas
class NotificationBase(BaseModel):
    title: str
    message: str
    type: str = "info"


class NotificationCreate(NotificationBase):
    user_id: UUID


class Notification(NotificationBase):
    id: UUID
    user_id: UUID
    is_read: bool
    data: Optional[Dict[str, Any]] = None
    created_at: datetime

    class Config:
        from_attributes = True


# Driver Manifest/Get Passenger List
class PassengerManifest(BaseModel):
    booking_id: UUID
    passenger_name: str
    passenger_phone: str
    passenger_cnic: str  # Will be encrypted
    seat_numbers: List[str]
    pickup_location: Optional[str] = None
    is_picked_up: bool


# Real-time Channel Response
class RealtimeChannel(BaseModel):
    channel_name: str
    channel_key: str
