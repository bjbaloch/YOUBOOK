-- -- ==========================================
-- -- Fix Schedule Relationships for PostgREST
-- -- Add missing foreign key constraints needed for schedule queries
-- -- ==========================================

-- -- Add foreign key from schedules to services
-- ALTER TABLE public.schedules
-- ADD CONSTRAINT fk_schedules_service_id
-- FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE SET NULL;

-- -- Add foreign key from schedules to vehicles
-- ALTER TABLE public.schedules
-- ADD CONSTRAINT fk_schedules_vehicle_id
-- FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id) ON DELETE CASCADE;

-- -- Add foreign key from vehicles to services
-- ALTER TABLE public.vehicles
-- ADD CONSTRAINT fk_vehicles_service_id
-- FOREIGN KEY (service_id) REFERENCES public.services(id) ON DELETE CASCADE;

-- -- Add foreign key from schedules to drivers
-- ALTER TABLE public.schedules
-- ADD CONSTRAINT fk_schedules_assigned_driver_id
-- FOREIGN KEY (assigned_driver_id) REFERENCES public.drivers(id) ON DELETE SET NULL;

-- -- ==========================================
-- -- After running this SQL, restart your Supabase project
-- -- to refresh the PostgREST schema cache
-- -- ==========================================
