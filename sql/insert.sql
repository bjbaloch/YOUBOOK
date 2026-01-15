-- -- Drop existing trigger and function
-- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
-- DROP FUNCTION IF EXISTS public.handle_new_user();

-- -- Recreate the function (now that enums exist)
-- CREATE OR REPLACE FUNCTION public.handle_new_user()
-- RETURNS TRIGGER AS $$
-- DECLARE
--     user_role_val user_role := 'passenger'::user_role;
-- BEGIN
--     -- Determine role: check for admin flag first, then explicit role, default to passenger
--     IF new.raw_user_meta_data->>'is_admin' = 'true' THEN
--         user_role_val := 'admin'::user_role;
--     ELSIF new.raw_user_meta_data->>'role' IS NOT NULL THEN
--         user_role_val := (new.raw_user_meta_data->>'role')::user_role;
--     END IF;

--     -- Insert into PROFILES
--     INSERT INTO public.profiles (
--         id,
--         email,
--         full_name,
--         phone_number,
--         cnic,
--         role,
--         avatar_url,
--         company_name,
--         credential_details
--     )
--     VALUES (
--         new.id,
--         new.email,
--         new.raw_user_meta_data->>'full_name',
--         new.raw_user_meta_data->>'phone_number',
--         COALESCE(new.raw_user_meta_data->>'cnic', 'PENDING-' || new.id::text),
--         user_role_val,
--         new.raw_user_meta_data->>'avatar_url',
--         new.raw_user_meta_data->>'company_name',
--         new.raw_user_meta_data->>'credential_details'
--     );

--     RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- -- Recreate the trigger
-- CREATE TRIGGER on_auth_user_created
--     AFTER INSERT ON auth.users
--     FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

