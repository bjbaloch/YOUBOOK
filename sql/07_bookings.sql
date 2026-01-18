 ==========================================
 YOUBOOK Booking System
 Production-ready passenger booking management
 ==========================================
 Tables: bookings, booking_seats
 Features: Seat reservations, payment tracking, manifest management
 ==========================================

 ==========================================
 1. BOOKINGS TABLE
 ==========================================

 Bookings table (passenger reservations)
-- CREATE TABLE IF NOT EXISTS public.bookings (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     passenger_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     schedule_id UUID REFERENCES public.schedules(id) ON DELETE CASCADE,  -- Made nullable for service bookings
--     service_id UUID REFERENCES public.services(id) ON DELETE CASCADE,  -- For service-level bookings
--     booking_type TEXT DEFAULT 'schedule' CHECK (booking_type IN ('schedule', 'service')),  -- 'schedule' or 'service'
--     booking_date TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     travel_date DATE NOT NULL,
--     total_price DECIMAL(8,2) NOT NULL,
--     status booking_status DEFAULT 'confirmed'::booking_status NOT NULL,
--     passenger_cnic TEXT,  -- Encrypted
--     is_paid BOOLEAN DEFAULT false NOT NULL,
--     payment_method TEXT,  -- wallet, card, cash
--     payment_reference TEXT,
--     pickup_location JSONB,  -- Optional pickup point
--     special_requests TEXT,
--     selected_seats JSONB,  -- Store selected seats for service bookings
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- ==========================================
-- MIGRATION: Add columns for service bookings
-- ==========================================

-- ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS service_id UUID REFERENCES public.services(id) ON DELETE CASCADE;
-- ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS booking_type TEXT DEFAULT 'schedule' CHECK (booking_type IN ('schedule', 'service'));
-- ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS selected_seats JSONB;
-- ALTER TABLE public.bookings ALTER COLUMN schedule_id DROP NOT NULL;  -- Make schedule_id nullable for service bookings

-- CREATE INDEX IF NOT EXISTS idx_bookings_service_id ON public.bookings(service_id);
-- CREATE INDEX IF NOT EXISTS idx_bookings_booking_type ON public.bookings(booking_type);

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_bookings_passenger_id ON public.bookings(passenger_id);
-- CREATE INDEX IF NOT EXISTS idx_bookings_schedule_id ON public.bookings(schedule_id);
-- CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
-- CREATE INDEX IF NOT EXISTS idx_bookings_travel_date ON public.bookings(travel_date);
-- CREATE INDEX IF NOT EXISTS idx_bookings_booking_date ON public.bookings(booking_date);
-- CREATE INDEX IF NOT EXISTS idx_bookings_is_paid ON public.bookings(is_paid);
-- CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON public.bookings(created_at);

 ==========================================
 2. BOOKING SEATS TABLE
 ==========================================

 Booking seats table (many-to-many relationship)
-- CREATE TABLE IF NOT EXISTS public.booking_seats (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE NOT NULL,
--     schedule_id UUID REFERENCES public.schedules(id) ON DELETE CASCADE NOT NULL,
--     seat_id UUID REFERENCES public.seats(id) ON DELETE CASCADE NOT NULL,
--     seat_number TEXT NOT NULL,
--     seat_count INTEGER DEFAULT 1 NOT NULL,  -- For counting in available seats calculation
--     is_checked_in BOOLEAN DEFAULT false NOT NULL,
--     checked_in_at TIMESTAMP WITH TIME ZONE,
--     checked_in_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(booking_id, seat_id),
--     UNIQUE(schedule_id, seat_id)  -- Seat can only be booked once per schedule
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_booking_seats_booking_id ON public.booking_seats(booking_id);
-- CREATE INDEX IF NOT EXISTS idx_booking_seats_schedule_id ON public.booking_seats(schedule_id);
-- CREATE INDEX IF NOT EXISTS idx_booking_seats_seat_id ON public.booking_seats(seat_id);
-- CREATE INDEX IF NOT EXISTS idx_booking_seats_is_checked_in ON public.booking_seats(is_checked_in);

 ==========================================
 3. UPDATE TIMESTAMP TRIGGERS
 ==========================================

 Update timestamp triggers
-- DROP TRIGGER IF EXISTS update_bookings_updated_at ON public.bookings;
-- CREATE TRIGGER update_bookings_updated_at
--     BEFORE UPDATE ON public.bookings
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_booking_seats_updated_at ON public.booking_seats;
-- CREATE TRIGGER update_booking_seats_updated_at
--     BEFORE UPDATE ON public.booking_seats
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

 ==========================================
 Bookings Setup Complete
 ==========================================
 Next: Run 08_wallet_system.sql to create payment and wallet system
