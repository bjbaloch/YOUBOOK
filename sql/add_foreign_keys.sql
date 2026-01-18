-- ==========================================
-- YOUBOOK Foreign Key Constraints
-- Add missing foreign key relationships to existing tables
-- Run this after creating all tables to enable PostgREST joins
-- ==========================================

-- ==========================================
-- 1. SERVICES TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.services
ADD CONSTRAINT fk_services_manager_id
FOREIGN KEY (manager_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- ==========================================
-- 2. ROUTES TABLE (No FKs needed)
-- ==========================================

-- ==========================================
-- 3. VEHICLES TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.vehicles
ADD CONSTRAINT fk_vehicles_service_id
FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;

ALTER TABLE public.vehicles
ADD CONSTRAINT fk_vehicles_manager_id
FOREIGN KEY (manager_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.vehicles
ADD CONSTRAINT fk_vehicles_current_driver_id
FOREIGN KEY (current_driver_id) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- ==========================================
-- 4. SEATS TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.seats
ADD CONSTRAINT fk_seats_vehicle_id
FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id) ON DELETE CASCADE;

-- ==========================================
-- 5. DRIVERS TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.drivers
ADD CONSTRAINT fk_drivers_company_id
FOREIGN KEY (company_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.drivers
ADD CONSTRAINT fk_drivers_auth_user_id
FOREIGN KEY (auth_user_id) REFERENCES auth.users(id) ON DELETE CASCADE;

-- ==========================================
-- 6. SCHEDULES TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.schedules
ADD CONSTRAINT fk_schedules_vehicle_id
FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id) ON DELETE CASCADE;

ALTER TABLE public.schedules
ADD CONSTRAINT fk_schedules_assigned_driver_id
FOREIGN KEY (assigned_driver_id) REFERENCES public.drivers(id) ON DELETE SET NULL;

ALTER TABLE public.schedules
ADD CONSTRAINT fk_schedules_service_id
FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE SET NULL;

-- ==========================================
-- 7. BOOKINGS TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.bookings
ADD CONSTRAINT fk_bookings_passenger_id
FOREIGN KEY (passenger_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.bookings
ADD CONSTRAINT fk_bookings_schedule_id
FOREIGN KEY (schedule_id) REFERENCES public.schedules(id) ON DELETE CASCADE;

-- ==========================================
-- 8. BOOKING SEATS TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.booking_seats
ADD CONSTRAINT fk_booking_seats_booking_id
FOREIGN KEY (booking_id) REFERENCES public.bookings(id) ON DELETE CASCADE;

ALTER TABLE public.booking_seats
ADD CONSTRAINT fk_booking_seats_schedule_id
FOREIGN KEY (schedule_id) REFERENCES public.schedules(id) ON DELETE CASCADE;

ALTER TABLE public.booking_seats
ADD CONSTRAINT fk_booking_seats_seat_id
FOREIGN KEY (seat_id) REFERENCES public.seats(id) ON DELETE CASCADE;

-- ==========================================
-- 9. WALLETS TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.wallets
ADD CONSTRAINT fk_wallets_user_id
FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- ==========================================
-- 10. WALLET TRANSACTIONS TABLE FOREIGN KEYS
-- ==========================================

ALTER TABLE public.wallet_transactions
ADD CONSTRAINT fk_wallet_transactions_wallet_id
FOREIGN KEY (wallet_id) REFERENCES public.wallets(id) ON DELETE CASCADE;

ALTER TABLE public.wallet_transactions
ADD CONSTRAINT fk_wallet_transactions_processed_by
FOREIGN KEY (processed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;

-- ==========================================
-- Foreign Key Constraints Setup Complete
-- ==========================================
-- After running this file, PostgREST should recognize all table relationships
-- and your booking queries should work without the "relationship not found" error
