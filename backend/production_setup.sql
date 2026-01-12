-- -- ==========================================
-- -- YOUBOOK Production Database Schema
-- -- Production-ready with Auth, Profiles, and Manager Applications
-- -- Copy and paste these statements into Supabase SQL Editor
-- -- ==========================================

-- -- ==========================================
-- -- 1. SETUP EXTENSIONS
-- -- ==========================================
-- -- Required for UUID generation
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -- ==========================================
-- -- 2. TABLES CREATION
-- -- ==========================================

-- -- Profiles table (extends auth.users)
-- CREATE TABLE IF NOT EXISTS public.profiles (
--     id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
--     full_name TEXT,
--     email TEXT UNIQUE NOT NULL,
--     avatar_url TEXT,
--     phone_number TEXT,
--     cnic TEXT,
--     role TEXT CHECK (role IN ('passenger', 'manager', 'driver', 'admin')) DEFAULT 'passenger',
--     company_name TEXT,  -- For managers: company name
--     credential_details TEXT,  -- For managers: JSON string of company details
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

-- -- Manager Applications table
-- CREATE TABLE IF NOT EXISTS public.manager_applications (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     company_name TEXT NOT NULL,
--     credential_details TEXT NOT NULL,  -- JSON string of company details
--     status TEXT CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
--     reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
--     review_notes TEXT,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(user_id)  -- One application per user
-- );

-- -- Wallets table for user balances
-- CREATE TABLE IF NOT EXISTS public.wallets (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     balance DECIMAL(10,2) DEFAULT 0.00 NOT NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(user_id)
-- );

-- -- ==========================================
-- -- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- -- ==========================================

-- -- Enable RLS on all tables
-- ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.manager_applications ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

-- -- Profiles Policies
-- DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
-- CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
--     FOR SELECT USING (true);

-- DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
-- CREATE POLICY "Users can insert their own profile" ON public.profiles
--     FOR INSERT WITH CHECK (auth.uid() = id);

-- DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
-- CREATE POLICY "Users can update own profile" ON public.profiles
--     FOR UPDATE USING (auth.uid() = id);

-- -- Manager Applications Policies
-- DROP POLICY IF EXISTS "Users can view own applications" ON public.manager_applications;
-- CREATE POLICY "Users can view own applications" ON public.manager_applications
--     FOR SELECT USING (auth.uid() = user_id);

-- DROP POLICY IF EXISTS "Users can create own applications" ON public.manager_applications;
-- CREATE POLICY "Users can create own applications" ON public.manager_applications
--     FOR INSERT WITH CHECK (auth.uid() = user_id);

-- DROP POLICY IF EXISTS "Managers can view all applications" ON public.manager_applications;
-- CREATE POLICY "Managers can view all applications" ON public.manager_applications
--     FOR SELECT USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'manager'
--         )
--     );

-- DROP POLICY IF EXISTS "Managers can update application status" ON public.manager_applications;
-- CREATE POLICY "Managers can update application status" ON public.manager_applications
--     FOR UPDATE USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'manager'
--         )
--     );

-- -- Wallets Policies
-- DROP POLICY IF EXISTS "Users can view own wallet" ON public.wallets;
-- CREATE POLICY "Users can view own wallet" ON public.wallets
--     FOR SELECT USING (auth.uid() = user_id);

-- DROP POLICY IF EXISTS "Users can insert own wallet" ON public.wallets;
-- CREATE POLICY "Users can insert own wallet" ON public.wallets
--     FOR INSERT WITH CHECK (auth.uid() = user_id);

-- DROP POLICY IF EXISTS "Users can update own wallet" ON public.wallets;
-- CREATE POLICY "Users can update own wallet" ON public.wallets
--     FOR UPDATE USING (auth.uid() = user_id);

-- -- ==========================================
-- -- 4. FUNCTIONS AND TRIGGERS
-- -- ==========================================

-- -- Function to handle new user signup automatically
-- CREATE OR REPLACE FUNCTION public.handle_new_user()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   -- Insert into PROFILES
--   INSERT INTO public.profiles (
--     id,
--     email,
--     full_name,
--     phone_number,
--     cnic,
--     role,
--     avatar_url,
--     company_name,
--     credential_details
--   )
--   VALUES (
--     new.id,
--     new.email,
--     new.raw_user_meta_data->>'full_name',
--     new.raw_user_meta_data->>'phone_number',
--     new.raw_user_meta_data->>'cnic',
--     COALESCE(new.raw_user_meta_data->>'role', 'passenger'),
--     new.raw_user_meta_data->>'avatar_url',
--     new.raw_user_meta_data->>'company_name',
--     new.raw_user_meta_data->>'credential_details'
--   );

--   RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- -- Function to update updated_at timestamp
-- CREATE OR REPLACE FUNCTION public.update_updated_at_column()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.updated_at = TIMEZONE('utc'::text, now());
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- Function to handle manager application approval
-- CREATE OR REPLACE FUNCTION public.handle_manager_approval()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   -- If application is approved, update user role to manager
--   IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
--     UPDATE public.profiles
--     SET role = 'manager',
--         company_name = NEW.company_name,
--         credential_details = NEW.credential_details,
--         updated_at = TIMEZONE('utc'::text, now())
--     WHERE id = NEW.user_id;
--   END IF;

--   -- If application is rejected, reset user role if they were manager
--   IF NEW.status = 'rejected' AND OLD.status != 'rejected' THEN
--     UPDATE public.profiles
--     SET role = 'passenger',
--         company_name = NULL,
--         credential_details = NULL,
--         updated_at = TIMEZONE('utc'::text, now())
--     WHERE id = NEW.user_id AND role = 'manager';
--   END IF;

--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- -- ==========================================
-- -- 5. TRIGGERS
-- -- ==========================================

-- -- Bind the signup trigger
-- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- -- Update timestamps triggers
-- DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
-- CREATE TRIGGER update_profiles_updated_at
--     BEFORE UPDATE ON public.profiles
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_manager_applications_updated_at ON public.manager_applications;
-- CREATE TRIGGER update_manager_applications_updated_at
--     BEFORE UPDATE ON public.manager_applications
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_wallets_updated_at ON public.wallets;
-- CREATE TRIGGER update_wallets_updated_at
--     BEFORE UPDATE ON public.wallets
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- -- Manager application approval trigger
-- DROP TRIGGER IF EXISTS on_manager_application_status_change ON public.manager_applications;
-- CREATE TRIGGER on_manager_application_status_change
--     AFTER UPDATE ON public.manager_applications
--     FOR EACH ROW EXECUTE PROCEDURE public.handle_manager_approval();

-- -- ==========================================
-- -- 6. INDEXES (Performance optimization)
-- -- ==========================================

-- -- Profiles indexes
-- CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
-- CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
-- CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at);

-- -- Manager applications indexes
-- CREATE INDEX IF NOT EXISTS idx_manager_applications_user_id ON public.manager_applications(user_id);
-- CREATE INDEX IF NOT EXISTS idx_manager_applications_status ON public.manager_applications(status);
-- CREATE INDEX IF NOT EXISTS idx_manager_applications_created_at ON public.manager_applications(created_at);

-- -- Wallets indexes
-- CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON public.wallets(user_id);

-- -- -- ==========================================
-- -- -- SETUP COMPLETE
-- -- -- ==========================================
-- -- -- The database is now ready for production use!
-- -- -- Run these statements in Supabase SQL Editor in the correct order.
