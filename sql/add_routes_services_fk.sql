-- Add foreign key constraint from routes.service_id to services.id
-- This enables the join query in getRoutesWithVehicles method
ALTER TABLE routes
ADD CONSTRAINT routes_service_id_fkey
FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE;
