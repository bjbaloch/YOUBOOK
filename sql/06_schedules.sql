--  ==========================================
--  YOUBOOK Schedule Management
--  Production-ready trip schedule management tables
--  ==========================================
--  Tables: schedules
--  Features: Trip scheduling, availability tracking, pricing, driver assignments
--  ==========================================

--  ==========================================
--  1. SCHEDULES TABLE
--  ==========================================

-- -- Schedules table (trip schedules)
-- -- Drop existing table if it exists with wrong schema
-- DROP TABLE IF EXISTS public.schedules CASCADE;

-- -- Create schedules table with correct schema
-- CREATE TABLE public.schedules (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE NOT NULL,
--     route_id UUID REFERENCES public.routes(id) ON DELETE CASCADE NOT NULL,
--     assigned_driver_id UUID REFERENCES public.drivers(id) ON DELETE SET NULL,
--     service_id UUID REFERENCES public.services(id) ON DELETE SET NULL,
--     departure_time TIMESTAMP WITH TIME ZONE NOT NULL,
--     arrival_time TIMESTAMP WITH TIME ZONE NOT NULL,
--     travel_date DATE NOT NULL,
--     available_seats INTEGER,  -- Calculated field, updated by triggers
--     total_seats INTEGER NOT NULL,  -- From vehicle capacity
--     base_fare DECIMAL(8,2) NOT NULL,
--     dynamic_pricing JSONB DEFAULT '{"enabled": false, "multiplier": 1.0}'::jsonb,
--     status schedule_status DEFAULT 'scheduled'::schedule_status NOT NULL,
--     boarding_points JSONB DEFAULT '[]'::jsonb,  -- Array of boarding locations
--     notes TEXT,
--     is_active BOOLEAN DEFAULT true NOT NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

--  Add indexes for performance
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_vehicle_id ON public.schedules(vehicle_id);
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_route_id ON public.schedules(route_id);
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_driver_id ON public.schedules(driver_id);
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_service_id ON public.schedules(service_id);
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_departure_time ON public.schedules(departure_time);
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_travel_date ON public.schedules(travel_date);
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_status ON public.schedules(status);
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_available_seats ON public.schedules(available_seats);
-- -- CREATE INDEX IF NOT EXISTS idx_schedules_created_at ON public.schedules(created_at);

--  ==========================================
--  2. UPDATE TIMESTAMP TRIGGER
--  ==========================================

--  Update timestamp trigger for schedules
-- -- DROP TRIGGER IF EXISTS update_schedules_updated_at ON public.schedules;
-- -- CREATE TRIGGER update_schedules_updated_at
-- --     BEFORE UPDATE ON public.schedules
-- --     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

--  ==========================================
--  3. FUNCTIONS FOR SCHEDULE MANAGEMENT
--  ==========================================

--  Function to calculate available seats for a schedule
-- -- CREATE OR REPLACE FUNCTION public.calculate_available_seats(p_schedule_id UUID)
-- -- RETURNS INTEGER AS $$
-- -- DECLARE
-- --     v_total_seats INTEGER;
-- --     v_booked_seats INTEGER;
-- -- BEGIN
-- --     -- Get total seats from vehicle
-- --     SELECT v.capacity INTO v_total_seats
-- --     FROM public.schedules s
-- --     JOIN public.vehicles v ON s.vehicle_id = v.id
-- --     WHERE s.id = p_schedule_id;

-- --     -- Count booked seats
-- --     SELECT COALESCE(SUM(bs.seat_count), 0) INTO v_booked_seats
-- --     FROM public.booking_seats bs
-- --     WHERE bs.schedule_id = p_schedule_id;

-- --     RETURN GREATEST(0, v_total_seats - v_booked_seats);
-- -- END;
-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  Function to update available seats
-- -- CREATE OR REPLACE FUNCTION public.update_schedule_available_seats()
-- -- RETURNS TRIGGER AS $$
-- -- BEGIN
-- --     -- Update available seats when schedule is modified
-- --     UPDATE public.schedules
-- --     SET available_seats = public.calculate_available_seats(id),
-- --         updated_at = TIMEZONE('utc'::text, now())
-- --     WHERE id = COALESCE(NEW.id, OLD.id);

-- --     RETURN COALESCE(NEW, OLD);
-- -- END;
-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  Trigger to update available seats
-- -- DROP TRIGGER IF EXISTS trigger_update_schedule_seats ON public.schedules;
-- -- CREATE TRIGGER trigger_update_schedule_seats
-- --     AFTER INSERT OR UPDATE ON public.schedules
-- --     FOR EACH ROW EXECUTE PROCEDURE public.update_schedule_available_seats();

--  ==========================================
--  Schedules Setup Complete
--  ==========================================
--  Next: Run 07_bookings.sql to create passenger booking system
