 ==========================================
 YOUBOOK Routes Management
 Production-ready route management tables
 ==========================================
 Tables: routes
 Features: Geographic routes with start/end locations, distances, durations
 ==========================================

 ==========================================
 1. ROUTES TABLE
 ==========================================

 Routes table
-- CREATE TABLE IF NOT EXISTS public.routes (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     name TEXT NOT NULL,
--     service_type TEXT DEFAULT 'bus' NOT NULL CHECK (service_type IN ('bus', 'van')),
--     start_location JSONB NOT NULL,  -- {latitude, longitude, address, city, province}
--     end_location JSONB NOT NULL,    -- {latitude, longitude, address, city, province}
--     distance_km DECIMAL(8,2),
--     estimated_duration_minutes INTEGER,
--     waypoints JSONB DEFAULT '[]'::jsonb,  -- Array of intermediate points
--     road_type TEXT DEFAULT 'highway',  -- highway, motorway, local_road
--     traffic_condition TEXT DEFAULT 'normal',  -- light, normal, heavy, congested
--     is_active BOOLEAN DEFAULT true NOT NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_routes_start_location ON public.routes USING GIN (start_location);
-- CREATE INDEX IF NOT EXISTS idx_routes_end_location ON public.routes USING GIN (end_location);
-- CREATE INDEX IF NOT EXISTS idx_routes_service_type ON public.routes(service_type);
-- CREATE INDEX IF NOT EXISTS idx_routes_is_active ON public.routes(is_active);
-- CREATE INDEX IF NOT EXISTS idx_routes_created_at ON public.routes(created_at);

 ==========================================
 2. UPDATE TIMESTAMP TRIGGER
 ==========================================

 Update timestamp trigger for routes
-- DROP TRIGGER IF EXISTS update_routes_updated_at ON public.routes;
-- CREATE TRIGGER update_routes_updated_at
--     BEFORE UPDATE ON public.routes
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

 ==========================================
 Routes Setup Complete
 ==========================================
 Next: Run 04_vehicles.sql to create vehicle management tables
