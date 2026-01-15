--  ==========================================
--  YOUBOOK Fleet Management System
--  Production-ready GPS tracking and fleet analytics
--  ==========================================
--  Tables: vehicle_locations, vehicle_statuses, vehicle_maintenance, driver_alerts, fleet_analytics
--  Features: Real-time GPS tracking, maintenance scheduling, driver alerts, fleet analytics
--  ==========================================

--  Ensure vehicle_status enum exists
-- -- DO $$ BEGIN
-- --     CREATE TYPE vehicle_status AS ENUM ('active', 'inactive', 'maintenance', 'out_of_service');
-- -- EXCEPTION
-- --     WHEN duplicate_object THEN null;
-- -- END $$;

--  ==========================================
--  1. VEHICLE LOCATIONS TABLE
--  ==========================================

-- -- GPS tracking for vehicles
-- -- Drop existing table if it exists with wrong schema
-- DROP TABLE IF EXISTS public.vehicle_locations CASCADE;

-- -- Create vehicle locations table with correct schema
-- CREATE TABLE public.vehicle_locations (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE NOT NULL,
--     driver_id UUID REFERENCES public.drivers(id) ON DELETE CASCADE NOT NULL,
--     latitude DECIMAL(10,8) NOT NULL,
--     longitude DECIMAL(11,8) NOT NULL,
--     accuracy DECIMAL(6,2),  -- GPS accuracy in meters
--     speed DECIMAL(5,2),  -- Speed in km/h
--     heading DECIMAL(5,2),  -- Direction in degrees (0-360)
--     altitude DECIMAL(7,2),
--     timestamp TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     is_moving BOOLEAN DEFAULT false,
--     battery_level DECIMAL(5,2),  -- Device battery level
--     network_type TEXT,  -- wifi, cellular, etc.
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Add indexes for performance (optimized for time-series queries)
-- CREATE INDEX IF NOT EXISTS idx_vehicle_locations_vehicle_id ON public.vehicle_locations(vehicle_id);
-- CREATE INDEX IF NOT EXISTS idx_vehicle_locations_driver_id ON public.vehicle_locations(driver_id);
-- CREATE INDEX IF NOT EXISTS idx_vehicle_locations_timestamp ON public.vehicle_locations(timestamp DESC);
-- CREATE INDEX IF NOT EXISTS idx_vehicle_locations_vehicle_timestamp ON public.vehicle_locations(vehicle_id, timestamp DESC);
-- CREATE INDEX IF NOT EXISTS idx_vehicle_locations_is_moving ON public.vehicle_locations(is_moving);

--  ==========================================
--  2. VEHICLE STATUSES TABLE
--  ==========================================

--  Real-time vehicle status
-- -- CREATE TABLE IF NOT EXISTS public.vehicle_statuses (
-- --     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
-- --     vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE NOT NULL,
-- --     driver_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
-- --     status vehicle_status DEFAULT 'inactive'::vehicle_status NOT NULL,
-- --     fuel_level DECIMAL(5,2) DEFAULT 100.00,
-- --     battery_level DECIMAL(5,2),  -- Device battery
-- --     engine_hours INTEGER DEFAULT 0,
-- --     odometer_km INTEGER DEFAULT 0,
-- --     last_location JSONB,  -- Last known location
-- --     current_route_id UUID REFERENCES public.routes(id) ON DELETE SET NULL,
-- --     current_schedule_id UUID,  -- Will reference schedules table
-- --     last_communication TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()),
-- --     is_online BOOLEAN DEFAULT false,
-- --     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
-- --     UNIQUE(vehicle_id)
-- -- );

--  Add indexes for performance
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_statuses_vehicle_id ON public.vehicle_statuses(vehicle_id);
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_statuses_driver_id ON public.vehicle_statuses(driver_id);
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_statuses_status ON public.vehicle_statuses(status);
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_statuses_is_online ON public.vehicle_statuses(is_online);
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_statuses_last_communication ON public.vehicle_statuses(last_communication DESC);

--  ==========================================
--  3. VEHICLE MAINTENANCE TABLE
--  ==========================================

--  Vehicle maintenance scheduling and tracking
-- -- CREATE TABLE IF NOT EXISTS public.vehicle_maintenance (
-- --     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
-- --     vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE NOT NULL,
-- --     maintenance_type TEXT NOT NULL,  -- oil_change, tire_rotation, brake_check, etc.
-- --     description TEXT,
-- --     priority priority_level DEFAULT 'medium',  -- Uses ENUM from setup file
-- --     due_date DATE NOT NULL,
-- --     due_km INTEGER,  -- Due at specific kilometer reading
-- --     completed_date DATE,
-- --     completed_km INTEGER,
-- --     cost DECIMAL(10,2),
-- --     status TEXT DEFAULT 'scheduled',  -- scheduled, in_progress, completed, overdue, cancelled
-- --     notes TEXT,
-- --     performed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,  -- Mechanic/admin
-- --     scheduled_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
-- --     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
-- --     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- -- );

--  Add indexes for performance
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_vehicle_id ON public.vehicle_maintenance(vehicle_id);
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_status ON public.vehicle_maintenance(status);
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_due_date ON public.vehicle_maintenance(due_date);
-- -- CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_priority ON public.vehicle_maintenance(priority);

--  ==========================================
--  4. DRIVER ALERTS TABLE
--  ==========================================

--  Alerts and notifications for drivers
-- -- CREATE TABLE IF NOT EXISTS public.driver_alerts (
-- --     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
-- --     driver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
-- --     alert_type TEXT NOT NULL,  -- schedule_change, passenger_issue, vehicle_issue, etc.
-- --     title TEXT NOT NULL,
-- --     message TEXT NOT NULL,
-- --     priority priority_level DEFAULT 'medium',  -- Uses ENUM from setup file
-- --     is_read BOOLEAN DEFAULT false NOT NULL,
-- --     action_required BOOLEAN DEFAULT false,
-- --     action_taken BOOLEAN DEFAULT false,
-- --     expires_at TIMESTAMP WITH TIME ZONE,
-- --     related_schedule_id UUID,  -- Will reference schedules table
-- --     related_booking_id UUID,  -- Will reference bookings table
-- --     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
-- --     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- -- );

--  Add indexes for performance
-- -- CREATE INDEX IF NOT EXISTS idx_driver_alerts_driver_id ON public.driver_alerts(driver_id);
-- -- CREATE INDEX IF NOT EXISTS idx_driver_alerts_alert_type ON public.driver_alerts(alert_type);
-- -- CREATE INDEX IF NOT EXISTS idx_driver_alerts_priority ON public.driver_alerts(priority DESC);
-- -- CREATE INDEX IF NOT EXISTS idx_driver_alerts_is_read ON public.driver_alerts(is_read);
-- -- CREATE INDEX IF NOT EXISTS idx_driver_alerts_expires_at ON public.driver_alerts(expires_at);

--  ==========================================
--  5. FLEET ANALYTICS TABLE
--  ==========================================

--  Daily fleet performance analytics
-- -- CREATE TABLE IF NOT EXISTS public.fleet_analytics (
-- --     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
-- --     date DATE NOT NULL,
-- --     total_vehicles INTEGER DEFAULT 0,
-- --     active_vehicles INTEGER DEFAULT 0,
-- --     maintenance_vehicles INTEGER DEFAULT 0,
-- --     offline_vehicles INTEGER DEFAULT 0,
-- --     total_drivers INTEGER DEFAULT 0,
-- --     active_drivers INTEGER DEFAULT 0,
-- --     on_duty_drivers INTEGER DEFAULT 0,
-- --     total_schedules INTEGER DEFAULT 0,
-- --     completed_schedules INTEGER DEFAULT 0,
-- --     cancelled_schedules INTEGER DEFAULT 0,
-- --     total_bookings INTEGER DEFAULT 0,
-- --     completed_bookings INTEGER DEFAULT 0,
-- --     cancelled_bookings INTEGER DEFAULT 0,
-- --     total_revenue DECIMAL(12,2) DEFAULT 0,
-- --     total_distance_km INTEGER DEFAULT 0,
-- --     average_fuel_efficiency DECIMAL(5,2),
-- --     total_maintenance_cost DECIMAL(10,2) DEFAULT 0,
-- --     incidents_reported INTEGER DEFAULT 0,
-- --     customer_satisfaction DECIMAL(3,2),  -- Average rating
-- --     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
-- --     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
-- --     UNIQUE(date)
-- -- );

--  Add indexes for performance
-- -- CREATE INDEX IF NOT EXISTS idx_fleet_analytics_date ON public.fleet_analytics(date DESC);

--  ==========================================
--  6. UPDATE TIMESTAMP TRIGGERS
--  ==========================================

--  Update timestamp triggers
-- -- DROP TRIGGER IF EXISTS update_vehicle_locations_updated_at ON public.vehicle_locations;
-- -- CREATE TRIGGER update_vehicle_locations_updated_at
-- --     BEFORE UPDATE ON public.vehicle_locations
-- --     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- -- DROP TRIGGER IF EXISTS update_vehicle_statuses_updated_at ON public.vehicle_statuses;
-- -- CREATE TRIGGER update_vehicle_statuses_updated_at
-- --     BEFORE UPDATE ON public.vehicle_statuses
-- --     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- -- DROP TRIGGER IF EXISTS update_vehicle_maintenance_updated_at ON public.vehicle_maintenance;
-- -- CREATE TRIGGER update_vehicle_maintenance_updated_at
-- --     BEFORE UPDATE ON public.vehicle_maintenance
-- --     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- -- DROP TRIGGER IF EXISTS update_driver_alerts_updated_at ON public.driver_alerts;
-- -- CREATE TRIGGER update_driver_alerts_updated_at
-- --     BEFORE UPDATE ON public.driver_alerts
-- --     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- -- DROP TRIGGER IF EXISTS update_fleet_analytics_updated_at ON public.fleet_analytics;
-- -- CREATE TRIGGER update_fleet_analytics_updated_at
-- --     BEFORE UPDATE ON public.fleet_analytics
-- --     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

--  ==========================================
--  7. FUNCTIONS FOR FLEET MANAGEMENT
--  ==========================================

-- -- Function to update vehicle location
-- CREATE OR REPLACE FUNCTION public.update_vehicle_location(
--     p_vehicle_id UUID,
--     p_driver_id UUID,
--     p_latitude DECIMAL(10,8),
--     p_longitude DECIMAL(11,8),
--     p_accuracy DECIMAL(6,2) DEFAULT NULL,
--     p_speed DECIMAL(5,2) DEFAULT NULL,
--     p_heading DECIMAL(5,2) DEFAULT NULL,
--     p_altitude DECIMAL(7,2) DEFAULT NULL,
--     p_battery_level DECIMAL(5,2) DEFAULT NULL
-- )
-- RETURNS UUID AS $$
-- DECLARE
--     location_id UUID;
--     is_moving BOOLEAN := false;
-- BEGIN
--     -- Determine if vehicle is moving
--     IF p_speed IS NOT NULL AND p_speed > 5 THEN
--         is_moving := true;
--     END IF;

--     -- Insert location record
--     INSERT INTO public.vehicle_locations (
--         vehicle_id, driver_id, latitude, longitude, accuracy, speed,
--         heading, altitude, is_moving, battery_level
--     ) VALUES (
--         p_vehicle_id, p_driver_id, p_latitude, p_longitude, p_accuracy, p_speed,
--         p_heading, p_altitude, is_moving, p_battery_level
--     ) RETURNING id INTO location_id;

--     -- Update driver last active time
--     UPDATE public.drivers
--     SET last_active_at = TIMEZONE('utc'::text, now()),
--         updated_at = TIMEZONE('utc'::text, now())
--     WHERE auth_user_id = p_driver_id;

--     RETURN location_id;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  ==========================================
--  Fleet Management Setup Complete
--  ==========================================
--  Next: Run 11_communication.sql to create chat and messaging system
