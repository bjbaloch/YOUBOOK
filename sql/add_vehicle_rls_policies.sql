-- ==========================================
-- Add Row Level Security Policies for Vehicles Table
-- This fixes the RLS policy violation error when inserting vehicles
-- ==========================================

-- ==========================================
-- VEHICLES POLICIES
-- ==========================================

-- Enable RLS on vehicles table (if not already enabled)
-- ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

-- Vehicles are viewable by everyone for booking purposes (active vehicles only)
-- DROP POLICY IF EXISTS "Vehicles are viewable by everyone" ON public.vehicles;
-- CREATE POLICY "Vehicles are viewable by everyone" ON public.vehicles
--     FOR SELECT USING (is_active = true);

-- Managers can manage vehicles for their services
-- DROP POLICY IF EXISTS "Managers can manage vehicles for their services" ON public.vehicles;
-- CREATE POLICY "Managers can manage vehicles for their services" ON public.vehicles
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.services s
--             WHERE s.id = service_id AND s.manager_id = auth.uid()
--         )
--     );

-- Drivers can view vehicles assigned to them
-- DROP POLICY IF EXISTS "Drivers can view assigned vehicles" ON public.vehicles;
-- CREATE POLICY "Drivers can view assigned vehicles" ON public.vehicles
--     FOR SELECT USING (
--         current_driver_id = auth.uid()
--     );

-- Admins can manage all vehicles
-- DROP POLICY IF EXISTS "Admins can manage all vehicles" ON public.vehicles;
-- CREATE POLICY "Admins can manage all vehicles" ON public.vehicles
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

-- ==========================================
-- SEATS POLICIES (dependent on vehicles)
-- ==========================================

-- Seats are viewable by everyone for active vehicles
-- DROP POLICY IF EXISTS "Seats are viewable for active vehicles" ON public.seats;
-- CREATE POLICY "Seats are viewable for active vehicles" ON public.seats
--     FOR SELECT USING (
--         EXISTS (
--             SELECT 1 FROM public.vehicles v
--             WHERE v.id = vehicle_id AND v.is_active = true
--         )
--     );

-- Managers can manage seats for their vehicles
-- DROP POLICY IF EXISTS "Managers can manage seats for their vehicles" ON public.seats;
-- CREATE POLICY "Managers can manage seats for their vehicles" ON public.seats
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.vehicles v
--             JOIN public.services s ON v.service_id = s.id
--             WHERE v.id = vehicle_id AND s.manager_id = auth.uid()
--         )
--     );

-- Admins can manage all seats
-- DROP POLICY IF EXISTS "Admins can manage all seats" ON public.seats;
-- CREATE POLICY "Admins can manage all seats" ON public.seats
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

-- ==========================================
-- SCHEDULES POLICIES (dependent on vehicles)
-- ==========================================

-- Schedules are viewable by everyone for active services
-- DROP POLICY IF EXISTS "Schedules are viewable for active services" ON public.schedules;
-- CREATE POLICY "Schedules are viewable for active services" ON public.schedules
--     FOR SELECT USING (
--         EXISTS (
--             SELECT 1 FROM public.services s
--             WHERE s.id = service_id AND s.is_active = true
--         )
--     );

-- Managers can manage schedules for their services
-- DROP POLICY IF EXISTS "Managers can manage schedules for their services" ON public.schedules;
-- CREATE POLICY "Managers can manage schedules for their services" ON public.schedules
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.services s
--             WHERE s.id = service_id AND s.manager_id = auth.uid()
--         )
--     );

-- Drivers can view schedules assigned to them
-- DROP POLICY IF EXISTS "Drivers can view assigned schedules" ON public.schedules;
-- CREATE POLICY "Drivers can view assigned schedules" ON public.schedules
--     FOR SELECT USING (driver_id = auth.uid());

-- Drivers can update their schedule status
-- DROP POLICY IF EXISTS "Drivers can update their schedule status" ON public.schedules;
-- CREATE POLICY "Drivers can update their schedule status" ON public.schedules
--     FOR UPDATE USING (driver_id = auth.uid())
--     WITH CHECK (driver_id = auth.uid());

-- Admins can manage all schedules
-- DROP POLICY IF EXISTS "Admins can manage all schedules" ON public.schedules;
-- CREATE POLICY "Admins can manage all schedules" ON public.schedules
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

-- ==========================================
-- DRIVERS POLICIES
-- ==========================================

-- Drivers can view their own profile
-- DROP POLICY IF EXISTS "Drivers can view own profile" ON public.drivers;
-- CREATE POLICY "Drivers can view own profile" ON public.drivers
--     FOR SELECT USING (auth.uid() = user_id);

-- Drivers can update their own profile
-- DROP POLICY IF EXISTS "Drivers can update own profile" ON public.drivers;
-- CREATE POLICY "Drivers can update own profile" ON public.drivers
--     FOR UPDATE USING (auth.uid() = user_id);

-- Managers can manage drivers for their services
-- DROP POLICY IF EXISTS "Managers can manage drivers for their services" ON public.drivers;
-- CREATE POLICY "Managers can manage drivers for their services" ON public.drivers
--     FOR ALL USING (manager_id = auth.uid());

-- Admins can manage all drivers
-- DROP POLICY IF EXISTS "Admins can manage all drivers" ON public.drivers;
-- CREATE POLICY "Admins can manage all drivers" ON public.drivers
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

-- ==========================================
-- ROUTES POLICIES
-- ==========================================

-- Routes are viewable by everyone
-- DROP POLICY IF EXISTS "Routes are viewable by everyone" ON public.routes;
-- CREATE POLICY "Routes are viewable by everyone" ON public.routes
--     FOR SELECT USING (true);

-- Managers can manage routes for their services
-- DROP POLICY IF EXISTS "Managers can manage routes for their services" ON public.routes;
-- CREATE POLICY "Managers can manage routes for their services" ON public.routes
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.services s
--             WHERE s.manager_id = auth.uid()
--         )
--     );

-- Admins can manage all routes
-- DROP POLICY IF EXISTS "Admins can manage all routes" ON public.routes;
-- CREATE POLICY "Admins can manage all routes" ON public.routes
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

-- ==========================================
-- Vehicle RLS Policies Setup Complete
-- ==========================================
