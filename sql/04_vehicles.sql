 ==========================================
 YOUBOOK Vehicle Management
 Production-ready vehicle fleet management tables
 ==========================================
 Tables: vehicles, seats
 Features: Fleet management, seat layouts, maintenance tracking, GPS integration
 ==========================================

 ==========================================
 1. VEHICLES TABLE
 ==========================================

 Vehicles table
-- CREATE TABLE IF NOT EXISTS public.vehicles (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     service_id UUID REFERENCES public.services(id) ON DELETE CASCADE NOT NULL,
--     manager_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     registration_number TEXT UNIQUE NOT NULL,
--     vehicle_number TEXT UNIQUE NOT NULL,  -- Internal tracking number
--     type vehicle_type NOT NULL,
--     make TEXT NOT NULL,
--     model TEXT NOT NULL,
--     year INTEGER NOT NULL,
--     capacity INTEGER NOT NULL,  -- Total seats
--     seat_layout JSONB,  -- Seat configuration (rows, columns, layout pattern)
--     fuel_type TEXT DEFAULT 'diesel',  -- diesel, petrol, electric, hybrid
--     fuel_level DECIMAL(5,2) DEFAULT 100.00,  -- Percentage
--     current_driver_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
--     current_location JSONB,  -- {latitude, longitude, address}
--     latitude DECIMAL(10,8),
--     longitude DECIMAL(11,8),
--     last_maintenance_date DATE,
--     next_maintenance_date DATE,
--     total_km INTEGER DEFAULT 0,
--     status vehicle_status DEFAULT 'active'::vehicle_status NOT NULL,
--     is_active BOOLEAN DEFAULT true NOT NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_vehicles_service_id ON public.vehicles(service_id);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_manager_id ON public.vehicles(manager_id);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_registration_number ON public.vehicles(registration_number);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_type ON public.vehicles(type);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_status ON public.vehicles(status);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_current_driver_id ON public.vehicles(current_driver_id);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_is_active ON public.vehicles(is_active);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_created_at ON public.vehicles(created_at);

 ==========================================
 2. SEATS TABLE
 ==========================================

 Seats table for individual seat tracking
-- CREATE TABLE IF NOT EXISTS public.seats (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE NOT NULL,
--     seat_number TEXT NOT NULL,  -- e.g., "A1", "B2", "1A"
--     seat_type TEXT DEFAULT 'standard',  -- standard, premium, window, aisle
--     is_available BOOLEAN DEFAULT true NOT NULL,
--     is_locked BOOLEAN DEFAULT false NOT NULL,
--     locked_until TIMESTAMP WITH TIME ZONE,
--     price_modifier DECIMAL(5,2) DEFAULT 1.00,  -- Multiplier for seat pricing
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(vehicle_id, seat_number)
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_seats_vehicle_id ON public.seats(vehicle_id);
-- CREATE INDEX IF NOT EXISTS idx_seats_is_available ON public.seats(is_available);
-- CREATE INDEX IF NOT EXISTS idx_seats_is_locked ON public.seats(is_locked);
-- CREATE INDEX IF NOT EXISTS idx_seats_locked_until ON public.seats(locked_until);

 ==========================================
 3. UPDATE TIMESTAMP TRIGGERS
 ==========================================

 Update timestamp triggers
-- DROP TRIGGER IF EXISTS update_vehicles_updated_at ON public.vehicles;
-- CREATE TRIGGER update_vehicles_updated_at
--     BEFORE UPDATE ON public.vehicles
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_seats_updated_at ON public.seats;
-- CREATE TRIGGER update_seats_updated_at
--     BEFORE UPDATE ON public.seats
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

 ==========================================
 4. FUNCTION TO AUTO-GENERATE SEATS
 ==========================================

 Function to generate seats based on vehicle capacity and layout
-- CREATE OR REPLACE FUNCTION public.generate_vehicle_seats(
--     p_vehicle_id UUID,
--     p_layout JSONB DEFAULT NULL
-- )
-- RETURNS INTEGER AS $$
-- DECLARE
--     v_capacity INTEGER;
--     v_seat_count INTEGER := 0;
--     v_row TEXT;
--     v_col TEXT;
--     v_seat_num TEXT;
-- BEGIN
--     -- Get vehicle capacity
--     SELECT capacity INTO v_capacity
--     FROM public.vehicles
--     WHERE id = p_vehicle_id;

--     IF v_capacity IS NULL THEN
--         RAISE EXCEPTION 'Vehicle not found or capacity not set';
--     END IF;

--     -- Clear existing seats
--     DELETE FROM public.seats WHERE vehicle_id = p_vehicle_id;

--     -- Generate seats based on layout or simple numbering
--     IF p_layout IS NOT NULL AND p_layout->>'type' = 'grid' THEN
--         -- Grid layout (e.g., bus with rows and columns)
--         FOR v_row IN SELECT jsonb_array_elements_text(p_layout->'rows') LOOP
--             FOR v_col IN SELECT jsonb_array_elements_text(p_layout->'columns') LOOP
--                 v_seat_num := v_row || v_col;
--                 INSERT INTO public.seats (vehicle_id, seat_number, seat_type)
--                 VALUES (p_vehicle_id, v_seat_num, 'standard');
--                 v_seat_count := v_seat_count + 1;

--                 IF v_seat_count >= v_capacity THEN
--                     EXIT;
--                 END IF;
--             END LOOP;

--             IF v_seat_count >= v_capacity THEN
--                 EXIT;
--             END IF;
--         END LOOP;
--     ELSE
--         -- Simple numbered seats (1, 2, 3, ...)
--         FOR i IN 1..v_capacity LOOP
--             INSERT INTO public.seats (vehicle_id, seat_number, seat_type)
--             VALUES (p_vehicle_id, i::TEXT, 'standard');
--         END LOOP;
--         v_seat_count := v_capacity;
--     END IF;

--     RETURN v_seat_count;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 ==========================================
 Vehicles Setup Complete
 ==========================================
 Next: Run 05_drivers.sql to create driver management tables
