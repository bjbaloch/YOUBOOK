-- -- ==========================================
-- -- YOUBOOK Enum Types Setup
-- -- Missing enum types required for database operations
-- -- ==========================================
-- -- Run this file to create enum types that are required for triggers and constraints
-- -- ==========================================

-- -- ==========================================
-- -- 1. ENABLE REQUIRED EXTENSIONS
-- -- ==========================================

-- -- Enable required extensions (available in Supabase)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -- Set timezone to UTC for consistency
-- SET timezone = 'UTC';

-- -- ==========================================
-- -- 2. CREATE ENUM TYPES
-- -- ==========================================

-- -- User roles enum
-- DO $$ BEGIN
--     CREATE TYPE user_role AS ENUM ('passenger', 'manager', 'driver', 'admin');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Vehicle types enum
-- DO $$ BEGIN
--     CREATE TYPE vehicle_type AS ENUM ('bus', 'van', 'mini_bus', 'luxury_bus');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Service types enum
-- DO $$ BEGIN
--     CREATE TYPE service_type AS ENUM ('transport', 'accommodation', 'rental');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Service status enum
-- DO $$ BEGIN
--     CREATE TYPE service_status AS ENUM ('active', 'inactive', 'maintenance', 'suspended');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Booking status enum
-- DO $$ BEGIN
--     CREATE TYPE booking_status AS ENUM ('confirmed', 'cancelled', 'completed', 'refunded');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Schedule status enum
-- DO $$ BEGIN
--     CREATE TYPE schedule_status AS ENUM ('scheduled', 'in_transit', 'completed', 'cancelled', 'delayed');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Vehicle status enum
-- DO $$ BEGIN
--     CREATE TYPE vehicle_status AS ENUM ('active', 'inactive', 'maintenance', 'out_of_service');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Driver status enum
-- DO $$ BEGIN
--     CREATE TYPE driver_status AS ENUM ('Idle', 'Assigned', 'On Trip');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Notification types enum
-- DO $$ BEGIN
--     CREATE TYPE notification_type AS ENUM ('info', 'success', 'warning', 'error', 'critical');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- Priority levels enum
-- DO $$ BEGIN
--     CREATE TYPE priority_level AS ENUM ('low', 'medium', 'high', 'critical');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- ==========================================
-- -- Enum Types Setup Complete
-- -- ==========================================
-- -- Next: Run this file in Supabase SQL Editor to fix the signup database error
