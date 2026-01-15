-- -- Supabase Storage Bucket Setup for Avatars
-- -- Run this in your Supabase SQL Editor

-- -- Enable RLS on storage.objects if not already enabled
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- -- Drop existing policies if they exist to avoid conflicts
-- DROP POLICY IF EXISTS "Avatar insert policy" ON storage.objects;
-- DROP POLICY IF EXISTS "Avatar update policy" ON storage.objects;
-- DROP POLICY IF EXISTS "Avatar select policy" ON storage.objects;
-- DROP POLICY IF EXISTS "Avatar delete policy" ON storage.objects;

-- -- Allow authenticated users to upload avatar files
-- CREATE POLICY "Avatar insert policy" ON storage.objects
-- FOR INSERT WITH CHECK (
--   bucket_id = 'avatars'
--   AND auth.role() = 'authenticated'
-- );

-- -- Allow authenticated users to update their avatar files
-- CREATE POLICY "Avatar update policy" ON storage.objects
-- FOR UPDATE USING (
-- -- Allow public access to view avatar files
-- CREATE POLICY "Avatar select policy" ON storage.objects
-- FOR SELECT TO public
-- USING (bucket_id = 'avatars');

-- -- Allow authenticated users to delete their avatar files
-- CREATE POLICY "Avatar delete policy" ON storage.objects
-- FOR DELETE TO authenticated
-- USING (bucket_id = 'avatars');
