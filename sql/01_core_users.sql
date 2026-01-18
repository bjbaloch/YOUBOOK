 ==========================================
 YOUBOOK Core Users System
 Production-ready user management tables
 ==========================================
 Tables: profiles, manager_applications
 Features: User roles, manager applications, automatic profile creation
 ==========================================

 ==========================================
 1. PROFILES TABLE
 ==========================================

 Profiles table (extends auth.users)
 CREATE TABLE IF NOT EXISTS public.profiles (
     id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
     full_name TEXT,
     email TEXT UNIQUE NOT NULL,
     avatar_url TEXT,
     phone_number TEXT,
     cnic TEXT UNIQUE,
     role user_role DEFAULT 'passenger'::user_role NOT NULL,
     company_name TEXT,  -- For managers: company name
     credential_details TEXT,  -- For managers: JSON string of company details
     manager_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,  -- Driver's manager
     is_active BOOLEAN DEFAULT true NOT NULL,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
 );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
-- CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
-- CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON public.profiles(created_at);
-- CREATE INDEX IF NOT EXISTS idx_profiles_manager_id ON public.profiles(manager_id);

 ==========================================
 2. MANAGER APPLICATIONS TABLE
 ==========================================

 Manager Applications table
-- CREATE TABLE IF NOT EXISTS public.manager_applications (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     company_name TEXT NOT NULL,
--     credential_details TEXT NOT NULL,  -- JSON string of company details
--     status TEXT CHECK (status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending' NOT NULL,
--     reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
--     review_notes TEXT,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(user_id)  -- One application per user
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_manager_applications_user_id ON public.manager_applications(user_id);
-- CREATE INDEX IF NOT EXISTS idx_manager_applications_status ON public.manager_applications(status);
-- CREATE INDEX IF NOT EXISTS idx_manager_applications_created_at ON public.manager_applications(created_at);

 ==========================================
 3. TRIGGER FOR AUTOMATIC PROFILE CREATION
 ==========================================

 Function to handle new user signup automatically
 CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS TRIGGER AS $$
 DECLARE
     user_role_val user_role := 'passenger'::user_role;
 BEGIN
     -- Determine role: check for admin flag first, then explicit role, default to passenger
     IF new.raw_user_meta_data->>'is_admin' = 'true' THEN
         user_role_val := 'admin'::user_role;
     ELSIF new.raw_user_meta_data->>'role' IS NOT NULL THEN
         user_role_val := (new.raw_user_meta_data->>'role')::user_role;
     END IF;

     -- Insert into PROFILES
     INSERT INTO public.profiles (
         id,
         email,
         full_name,
         phone_number,
         cnic,
         role,
         avatar_url,
         company_name,
         credential_details
     )
     VALUES (
         new.id,
         new.email,
         new.raw_user_meta_data->>'full_name',
         new.raw_user_meta_data->>'phone_number',
         COALESCE(new.raw_user_meta_data->>'cnic', 'PENDING-' || new.id::text),
         user_role_val,
         new.raw_user_meta_data->>'avatar_url',
         new.raw_user_meta_data->>'company_name',
         new.raw_user_meta_data->>'credential_details'
     );

     RETURN new;
 END;
 $$ LANGUAGE plpgsql SECURITY DEFINER;

 Bind the signup trigger
 DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
 CREATE TRIGGER on_auth_user_created
     AFTER INSERT ON auth.users
     FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

 ==========================================
 4. TRIGGER FOR MANAGER APPLICATION APPROVAL
 ==========================================

 Function to handle manager application approval
-- CREATE OR REPLACE FUNCTION public.handle_manager_approval()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     -- If application is approved, update user role to manager
--     IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
--         UPDATE public.profiles
--         SET role = 'manager'::user_role,
--             company_name = NEW.company_name,
--             credential_details = NEW.credential_details,
--             updated_at = TIMEZONE('utc'::text, now())
--         WHERE id = NEW.user_id;
--     END IF;

--     -- If application is rejected, reset user role if they were manager
--     IF NEW.status = 'rejected' AND OLD.status != 'rejected' THEN
--         UPDATE public.profiles
--         SET role = 'passenger'::user_role,
--             company_name = NULL,
--             credential_details = NULL,
--             updated_at = TIMEZONE('utc'::text, now())
--         WHERE id = NEW.user_id AND role = 'manager'::user_role;
--     END IF;

--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 Manager application approval trigger
-- DROP TRIGGER IF EXISTS on_manager_application_status_change ON public.manager_applications;
-- CREATE TRIGGER on_manager_application_status_change
--     AFTER UPDATE ON public.manager_applications
--     FOR EACH ROW EXECUTE PROCEDURE public.handle_manager_approval();

 ==========================================
 5. UPDATE TIMESTAMP TRIGGER
 ==========================================

 Function to update updated_at timestamp
-- CREATE OR REPLACE FUNCTION public.update_updated_at_column()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.updated_at = TIMEZONE('utc'::text, now());
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

 Update timestamp triggers
-- DROP TRIGGER IF EXISTS update_profiles_updated_at ON public.profiles;
-- CREATE TRIGGER update_profiles_updated_at
--     BEFORE UPDATE ON public.profiles
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_manager_applications_updated_at ON public.manager_applications;
-- CREATE TRIGGER update_manager_applications_updated_at
--     BEFORE UPDATE ON public.manager_applications
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

 ==========================================
 Core Users Setup Complete
 ==========================================
 Next: Run 02_services.sql to create service management tables
