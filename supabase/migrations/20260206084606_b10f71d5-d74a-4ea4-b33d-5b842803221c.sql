-- Fix the overly permissive INSERT policy on feature_usage
-- Change from WITH CHECK (true) to require valid feature_name and action

DROP POLICY IF EXISTS "Anyone can log usage" ON public.feature_usage;

CREATE POLICY "Anyone can log usage" ON public.feature_usage FOR INSERT
  WITH CHECK (
    feature_name IS NOT NULL AND 
    feature_name != '' AND 
    action IS NOT NULL AND 
    action != ''
  );