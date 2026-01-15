--  ==========================================
--  YOUBOOK Driver Management
--  Production-ready driver management tables
--  ==========================================
--  Tables: drivers
--  Features: Driver profiles, licenses, ratings, assignments, performance tracking
--  ==========================================

--  ==========================================
--  1. DRIVERS TABLE
--  ==========================================

-- -- Drivers table (extends profiles)
-- -- Drop existing table if it exists with wrong schema
-- DROP TABLE IF EXISTS public.drivers CASCADE;

-- -- Create drivers table with correct schema
-- CREATE TABLE public.drivers (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     company_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     auth_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
--     email TEXT NOT NULL,
--     name TEXT NOT NULL,
--     license_number TEXT UNIQUE NOT NULL,
--     phone TEXT NOT NULL,
--     photo_url TEXT,
--     current_status driver_status DEFAULT 'Idle'::driver_status NOT NULL,
--     last_active_at TIMESTAMP WITH TIME ZONE,
--     total_trips INTEGER DEFAULT 0,
--     rating DECIMAL(3,2) DEFAULT 0.00,
--     rating_count INTEGER DEFAULT 0,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(auth_user_id),
--     UNIQUE(email)
-- );

-- -- Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_drivers_auth_user_id ON public.drivers(auth_user_id);
-- CREATE INDEX IF NOT EXISTS idx_drivers_company_id ON public.drivers(company_id);
-- CREATE INDEX IF NOT EXISTS idx_drivers_license_number ON public.drivers(license_number);
-- CREATE INDEX IF NOT EXISTS idx_drivers_current_status ON public.drivers(current_status);
-- CREATE INDEX IF NOT EXISTS idx_drivers_rating ON public.drivers(rating DESC);
-- CREATE INDEX IF NOT EXISTS idx_drivers_created_at ON public.drivers(created_at);

--  ==========================================
--  2. UPDATE TIMESTAMP TRIGGER
--  ==========================================

-- -- Update timestamp trigger for drivers
-- DROP TRIGGER IF EXISTS update_drivers_updated_at ON public.drivers;
-- CREATE TRIGGER update_drivers_updated_at
--     BEFORE UPDATE ON public.drivers
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

--  ==========================================
--  3. FUNCTIONS FOR DRIVER MANAGEMENT
--  ==========================================

--  Function to calculate driver rating
-- -- CREATE OR REPLACE FUNCTION public.update_driver_rating(
-- --     p_driver_id UUID,
-- --     p_new_rating DECIMAL(3,2)
-- -- )
-- -- RETURNS DECIMAL(3,2) AS $$
-- -- DECLARE
-- --     v_current_rating DECIMAL(3,2);
-- --     v_current_count INTEGER;
-- --     v_new_avg_rating DECIMAL(3,2);
-- -- BEGIN
-- --     -- Get current rating data
-- --     SELECT rating, rating_count INTO v_current_rating, v_current_count
-- --     FROM public.drivers
-- --     WHERE id = p_driver_id;

-- --     IF v_current_count IS NULL THEN
-- --         RAISE EXCEPTION 'Driver not found';
-- --     END IF;

-- --     -- Calculate new average rating
-- --     v_new_avg_rating := ((v_current_rating * v_current_count) + p_new_rating) / (v_current_count + 1);

-- --     -- Update driver rating
-- --     UPDATE public.drivers
-- --     SET rating = ROUND(v_new_avg_rating, 2),
-- --         rating_count = rating_count + 1,
-- --         updated_at = TIMEZONE('utc'::text, now())
-- --     WHERE id = p_driver_id;

-- --     RETURN ROUND(v_new_avg_rating, 2);
-- -- END;
-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  Function to assign driver to vehicle
-- -- CREATE OR REPLACE FUNCTION public.assign_driver_to_vehicle(
-- --     p_driver_id UUID,
-- --     p_vehicle_id UUID
-- -- )
-- -- RETURNS BOOLEAN AS $$
-- -- DECLARE
-- --     v_driver_status driver_status;
-- --     v_vehicle_status vehicle_status;
-- --     v_current_driver UUID;
-- -- BEGIN
-- --     -- Check driver status
-- --     SELECT status INTO v_driver_status
-- --     FROM public.drivers
-- --     WHERE id = p_driver_id;

-- --     IF v_driver_status != 'active'::driver_status THEN
-- --         RAISE EXCEPTION 'Driver is not active';
-- --     END IF;

-- --     -- Check vehicle status
-- --     SELECT status, current_driver_id INTO v_vehicle_status, v_current_driver
-- --     FROM public.vehicles
-- --     WHERE id = p_vehicle_id;

-- --     IF v_vehicle_status NOT IN ('active'::vehicle_status, 'maintenance'::vehicle_status) THEN
-- --         RAISE EXCEPTION 'Vehicle is not available for assignment';
-- --     END IF;

-- --     -- If vehicle has another driver, unassign them
-- --     IF v_current_driver IS NOT NULL AND v_current_driver != p_driver_id THEN
-- --         UPDATE public.drivers
-- --         SET current_vehicle_id = NULL,
-- --             status = 'active'::driver_status,
-- --             updated_at = TIMEZONE('utc'::text, now())
-- --         WHERE id = v_current_driver;
-- --     END IF;

-- --     -- Assign driver to vehicle
-- --     UPDATE public.vehicles
-- --     SET current_driver_id = p_driver_id,
-- --         status = 'active'::vehicle_status,
-- --         updated_at = TIMEZONE('utc'::text, now())
-- --     WHERE id = p_vehicle_id;

-- --     UPDATE public.drivers
-- --     SET current_vehicle_id = p_vehicle_id,
-- --         status = 'active'::driver_status,
-- --         last_active_at = TIMEZONE('utc'::text, now()),
-- --         updated_at = TIMEZONE('utc'::text, now())
-- --     WHERE id = p_driver_id;

-- --     RETURN true;
-- -- END;
-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  ==========================================
--  Drivers Setup Complete
--  ==========================================
--  Next: Run 06_schedules.sql to create trip schedule management tables
