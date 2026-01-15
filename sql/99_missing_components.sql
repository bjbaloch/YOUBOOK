-- -- ==========================================
-- -- YOUBOOK Missing Components
-- -- Components missing from existing SQL files but required by Flutter app
-- -- ==========================================

-- -- ==========================================
-- -- 1. ENUM TYPE FIXES
-- -- ==========================================

-- -- Fix Schedule Status Enum to match Flutter code
-- -- The Flutter app uses 'inProgress' but SQL had 'in_transit'
-- DO $$
-- BEGIN
--     -- Drop and recreate the schedule_status enum with correct values
--     DROP TYPE IF EXISTS schedule_status CASCADE;
--     CREATE TYPE schedule_status AS ENUM ('scheduled', 'inProgress', 'completed', 'cancelled', 'delayed');
-- EXCEPTION
--     WHEN duplicate_object THEN null;
-- END $$;

-- -- ==========================================
-- -- 2. MISSING FUNCTIONS
-- -- ==========================================

-- -- Function to calculate available seats for a schedule
-- CREATE OR REPLACE FUNCTION public.calculate_available_seats(p_schedule_id UUID)
-- RETURNS INTEGER AS $$
-- DECLARE
--     v_total_seats INTEGER;
--     v_booked_seats INTEGER;
-- BEGIN
--     SELECT total_seats INTO v_total_seats
--     FROM public.schedules
--     WHERE id = p_schedule_id;

--     SELECT COALESCE(SUM(seat_count), 0) INTO v_booked_seats
--     FROM public.booking_seats
--     WHERE schedule_id = p_schedule_id;

--     RETURN GREATEST(0, v_total_seats - v_booked_seats);
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- -- Function to update schedule available seats automatically
-- CREATE OR REPLACE FUNCTION public.update_schedule_available_seats()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     UPDATE public.schedules
--     SET available_seats = public.calculate_available_seats(id),
--         updated_at = TIMEZONE('utc'::text, now())
--     WHERE id = COALESCE(NEW.id, OLD.id);

--     RETURN COALESCE(NEW, OLD);
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- -- ==========================================
-- -- 3. MISSING TRIGGERS
-- -- ==========================================

-- -- Trigger to automatically update available seats when booking seats change
-- DROP TRIGGER IF EXISTS trigger_update_schedule_seats ON public.schedules;
-- CREATE TRIGGER trigger_update_schedule_seats
--     AFTER INSERT OR UPDATE ON public.schedules
--     FOR EACH ROW EXECUTE PROCEDURE public.update_schedule_available_seats();

-- -- ==========================================
-- -- 4. ADDITIONAL MISSING FUNCTIONS (if referenced in API)
-- -- ==========================================

-- -- Function to generate seats for a vehicle (basic implementation)
-- CREATE OR REPLACE FUNCTION public.generate_vehicle_seats(
--     p_vehicle_id UUID,
--     p_layout JSONB DEFAULT NULL
-- )
-- RETURNS INTEGER AS $$
-- DECLARE
--     v_capacity INTEGER;
--     v_seat_count INTEGER := 0;
-- BEGIN
--     SELECT capacity INTO v_capacity
--     FROM public.vehicles
--     WHERE id = p_vehicle_id;

--     IF v_capacity IS NULL THEN
--         RAISE EXCEPTION 'Vehicle not found or capacity not set';
--     END IF;

--     DELETE FROM public.seats WHERE vehicle_id = p_vehicle_id;

--     FOR i IN 1..v_capacity LOOP
--         INSERT INTO public.seats (vehicle_id, seat_number, seat_type)
--         VALUES (p_vehicle_id, i::TEXT, 'standard');
--     END LOOP;
--     v_seat_count := v_capacity;

--     RETURN v_seat_count;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- -- ==========================================
-- -- 5. MISSING TABLE COLUMNS (if needed)
-- -- ==========================================

-- -- Add missing columns to existing tables if they don't exist

-- -- Add available_seats to schedules table if missing
-- DO $$
-- BEGIN
--     IF NOT EXISTS (SELECT 1 FROM information_schema.columns
--                    WHERE table_name = 'schedules' AND column_name = 'available_seats') THEN
--         ALTER TABLE public.schedules ADD COLUMN available_seats INTEGER;
--     END IF;
-- EXCEPTION
--     WHEN others THEN null;
-- END $$;

-- -- Add is_seat_layout_configured to services table if missing
-- DO $$
-- BEGIN
--     IF NOT EXISTS (SELECT 1 FROM information_schema.columns
--                    WHERE table_name = 'services' AND column_name = 'is_seat_layout_configured') THEN
--         ALTER TABLE public.services ADD COLUMN is_seat_layout_configured BOOLEAN DEFAULT false;
--     END IF;
-- EXCEPTION
--     WHEN others THEN null;
-- END $$;

-- -- Add reference_type and reference_id to wallet_transactions if missing
-- DO $$
-- BEGIN
--     IF NOT EXISTS (SELECT 1 FROM information_schema.columns
--                    WHERE table_name = 'wallet_transactions' AND column_name = 'reference_type') THEN
--         ALTER TABLE public.wallet_transactions ADD COLUMN reference_type TEXT;
--         ALTER TABLE public.wallet_transactions ADD COLUMN reference_id UUID;
--     END IF;
-- EXCEPTION
--     WHEN others THEN null;
-- END $$;

-- -- ==========================================
-- -- SETUP COMPLETE
-- -- ==========================================
-- -- These are the missing components that need to be added to make the Flutter app work properly
-- -- Run this file after running the existing SQL files
