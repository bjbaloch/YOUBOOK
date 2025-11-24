-- YOUBOOK Supabase Database Schema

-- Enable necessary extensions
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -- Profiles table (extends auth.users)
-- CREATE TABLE profiles (
--     id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
--     full_name TEXT,
--     email TEXT UNIQUE NOT NULL,
--     avatar_url TEXT,
--     phone_number TEXT,
--     cnic TEXT UNIQUE NOT NULL,
--     role TEXT CHECK (role IN ('passenger', 'manager', 'driver')) DEFAULT 'passenger',
--     manager_id UUID REFERENCES profiles(id),
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Manager applications (for credential check)
-- CREATE TABLE manager_applications (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
--     company_name TEXT NOT NULL,
--     credential_details TEXT NOT NULL,
--     status TEXT CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Managers table (approved businesses)
-- CREATE TABLE managers (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
--     company_name TEXT NOT NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Services table (types of service)
-- CREATE TABLE services (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     name TEXT NOT NULL, -- e.g., "Bus", "Van", "Hotel", "Car Rental"
--     type TEXT CHECK (type IN ('transport', 'accommodation', 'rental')) NOT NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Routes table (available transport routes)
-- CREATE TABLE routes (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     name TEXT NOT NULL,
--     start_location GEOGRAPHY(POINT) NOT NULL,
--     end_location GEOGRAPHY(POINT) NOT NULL,
--     distance_km DECIMAL(10,2),
--     estimated_duration_minutes INTEGER,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Vehicles table
-- CREATE TABLE vehicles (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     manager_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
--     service_id UUID REFERENCES services(id) ON DELETE CASCADE,
--     name TEXT NOT NULL,
--     registration_plate TEXT UNIQUE NOT NULL,
--     total_seats INTEGER NOT NULL,
--     seat_map_json JSONB, -- Store seat layout configuration
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Schedules table (specific trips)
-- CREATE TABLE schedules (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     vehicle_id UUID REFERENCES vehicles(id) ON DELETE CASCADE,
--     route_id UUID REFERENCES routes(id) ON DELETE CASCADE,
--     driver_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
--     departure_time TIMESTAMP WITH TIME ZONE NOT NULL,
--     arrival_time TIMESTAMP WITH TIME ZONE NOT NULL,
--     price_per_seat DECIMAL(10,2) NOT NULL,
--     status TEXT CHECK (status IN ('scheduled', 'boarding', 'departed', 'arrived', 'cancelled')) DEFAULT 'scheduled',
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Bookings table
-- CREATE TABLE bookings (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     passenger_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
--     schedule_id UUID REFERENCES schedules(id) ON DELETE CASCADE,
--     seat_numbers TEXT[] NOT NULL, -- Array of seat numbers like ['A1', 'A2']
--     total_price DECIMAL(10,2) NOT NULL,
--     status TEXT CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed')) DEFAULT 'pending',
--     -- Encrypted passenger CNIC for security
--     passenger_cnic TEXT NOT NULL, -- Will be encrypted using pgsodium
--     pickup_location GEOGRAPHY(POINT), -- Pickup point for the passenger
--     is_picked_up BOOLEAN DEFAULT FALSE,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Live locations table (for GPS tracking)
-- CREATE TABLE live_locations (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     schedule_id UUID REFERENCES schedules(id) ON DELETE CASCADE,
--     location GEOGRAPHY(POINT) NOT NULL,
--     timestamp TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     speed_kmh DECIMAL(5,2),
--     heading DECIMAL(5,2)
-- );

-- -- Wallet table (for payments)
-- CREATE TABLE wallets (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES profiles(id) ON DELETE CASCADE UNIQUE,
--     balance DECIMAL(10,2) DEFAULT 0.00,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Wallet transactions
-- CREATE TABLE wallet_transactions (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
--     amount DECIMAL(10,2) NOT NULL,
--     type TEXT CHECK (type IN ('credit', 'debit')) NOT NULL,
--     description TEXT,
--     reference_id UUID, -- Could reference booking_id or other entities
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Advertisements
-- CREATE TABLE advertisements (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     title TEXT NOT NULL,
--     description TEXT,
--     image_url TEXT,
--     target_url TEXT,
--     priority INTEGER DEFAULT 0,
--     is_active BOOLEAN DEFAULT TRUE,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     expires_at TIMESTAMP WITH TIME ZONE
-- );

-- -- Notifications
-- CREATE TABLE notifications (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
--     title TEXT NOT NULL,
--     message TEXT NOT NULL,
--     type TEXT CHECK (type IN ('info', 'warning', 'success', 'error')) DEFAULT 'info',
--     is_read BOOLEAN DEFAULT FALSE,
--     data JSONB, -- Additional data for the notification
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Create indexes for performance
-- CREATE INDEX idx_schedules_departure_time ON schedules (departure_time);
-- CREATE INDEX idx_schedules_route_id ON schedules (route_id);
-- CREATE INDEX idx_bookings_schedule_id ON bookings (schedule_id);
-- CREATE INDEX idx_bookings_passenger_id ON bookings (passenger_id);
-- CREATE INDEX idx_live_locations_schedule_id ON live_locations (schedule_id);
-- CREATE INDEX idx_live_locations_timestamp ON live_locations (timestamp);

-- -- Row Level Security (RLS) Policies

-- -- Enable RLS on all tables
-- ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE manager_applications ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE managers ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- -- Profiles: Users can read/write their own profile
-- CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
-- CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- -- Bookings: Passengers can see their own bookings, managers can see bookings for their vehicles
-- CREATE POLICY "Passengers can view own bookings" ON bookings FOR SELECT USING (auth.uid() = passenger_id);
-- CREATE POLICY "Passengers can create bookings" ON bookings FOR INSERT WITH CHECK (auth.uid() = passenger_id);

-- -- Notifications: Users can see their own notifications
-- CREATE POLICY "Users can view own notifications" ON notifications FOR SELECT USING (auth.uid() = user_id);

-- -- Wallets: Users can see their own wallet
-- CREATE POLICY "Users can view own wallet" ON wallets FOR SELECT USING (auth.uid() = user_id);

-- -- Functions for real-time location updates and seat locking
-- CREATE OR REPLACE FUNCTION notify_location_update()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     PERFORM pg_notify('location_updates', json_build_object(
--         'schedule_id', NEW.schedule_id,
--         'location', ST_AsGeoJSON(NEW.location)::json,
--         'timestamp', NEW.timestamp
--     )::text);
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION notify_booking_update()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     PERFORM pg_notify('booking_updates', json_build_object(
--         'booking_id', NEW.id,
--         'schedule_id', NEW.schedule_id,
--         'status', NEW.status,
--         'is_picked_up', NEW.is_picked_up
--     )::text);
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Triggers
-- CREATE TRIGGER location_update_trigger
--     AFTER INSERT ON live_locations
--     FOR EACH ROW EXECUTE FUNCTION notify_location_update();

-- CREATE TRIGGER booking_update_trigger
--     AFTER UPDATE ON bookings
--     FOR EACH ROW EXECUTE FUNCTION notify_booking_update();
