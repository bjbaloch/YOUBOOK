-- -- Add address columns to profiles table
-- ALTER TABLE public.profiles
-- ADD COLUMN IF NOT EXISTS address TEXT,
-- ADD COLUMN IF NOT EXISTS city TEXT,
-- ADD COLUMN IF NOT EXISTS state_province TEXT,
-- ADD COLUMN IF NOT EXISTS country TEXT;

-- -- Add indexes for performance (optional but recommended)
-- CREATE INDEX IF NOT EXISTS idx_profiles_city ON public.profiles(city);
-- CREATE INDEX IF NOT EXISTS idx_profiles_country ON public.profiles(country);
