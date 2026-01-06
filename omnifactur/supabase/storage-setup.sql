-- Supabase Storage Bucket Configuration
-- Run in Supabase SQL Editor after project creation

-- Create logos bucket for white-label uploads
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES (
  'logos', 
  'logos', 
  true,
  2097152, -- 2MB limit
  ARRAY['image/png', 'image/jpeg', 'image/svg+xml']
);

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated accountants can upload logos
CREATE POLICY "Accountants can upload logos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'logos' 
  AND auth.uid() IN (SELECT auth_user_id FROM accountants)
);

-- Policy: Public can view logos (for white-label display)
CREATE POLICY "Public can view logos"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'logos');

-- Policy: Accountants can update their own cabinet's logo
CREATE POLICY "Accountants can update cabinet logos"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'logos'
  AND auth.uid() IN (SELECT auth_user_id FROM accountants)
);

-- Policy: Accountants can delete their own cabinet's logo
CREATE POLICY "Accountants can delete cabinet logos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'logos'
  AND auth.uid() IN (SELECT auth_user_id FROM accountants)
);

-- Verify bucket creation
SELECT * FROM storage.buckets WHERE id = 'logos';
