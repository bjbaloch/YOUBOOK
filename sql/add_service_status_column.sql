-- -- ==========================================
-- -- Add Status Column to Services Table
-- -- This adds the missing status column that the application expects
-- -- ==========================================

-- -- First, ensure the service_status enum exists (run 17_enum_types.sql if not already run)
-- -- This should have been created by the enum types setup

-- -- Add status column to services table
-- ALTER TABLE public.services
-- ADD COLUMN IF NOT EXISTS status service_status DEFAULT 'active'::service_status;

-- -- Update existing records to have 'active' status if they don't have one
-- UPDATE public.services
-- SET status = 'active'::service_status
-- WHERE status IS NULL;

-- -- Make the column NOT NULL after setting defaults
-- ALTER TABLE public.services
-- ALTER COLUMN status SET NOT NULL;

-- -- Add index for performance
-- CREATE INDEX IF NOT EXISTS idx_services_status ON public.services(status);

-- -- ==========================================
-- -- Migration Complete
-- -- ==========================================
