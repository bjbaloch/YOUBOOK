-- Add service_id column to routes table to link routes to specific services
-- This enables service-based routing where routes belong to services

ALTER TABLE public.routes
ADD COLUMN service_id UUID REFERENCES public.services(id) ON DELETE CASCADE;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_routes_service_id ON public.routes(service_id);

-- Update existing routes to link to services based on service_type
-- This is a migration script - run after adding the column
-- UPDATE public.routes
-- SET service_id = (
--   SELECT id FROM public.services
--   WHERE manager_id = (SELECT auth.uid()) -- Current user's services
--   AND type = routes.service_type
--   LIMIT 1
-- )
-- WHERE service_id IS NULL;

-- Note: The above UPDATE is commented out because it requires specific logic
-- to determine which service each route should belong to.
-- This should be handled in the application logic when routes are created.
