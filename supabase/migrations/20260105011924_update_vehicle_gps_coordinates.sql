-- Update vehicles with realistic GPS coordinates for Bangkok, Thailand
-- Central Bangkok coordinates (Siam area): 13.7463° N, 100.5352° E

UPDATE public.vehicles 
SET 
  gps_latitude = 13.7463,
  gps_longitude = 100.5352,
  last_gps_update = NOW()
WHERE id = 'b8203371-4162-4dea-bb32-b28e4eed0b3e';

UPDATE public.vehicles 
SET 
  gps_latitude = 13.7520,
  gps_longitude = 100.5435,
  last_gps_update = NOW()
WHERE id = 'f264250a-2ef0-4795-856b-52fa45e6459d';

-- Add GPS coordinates to any other vehicles without coordinates
UPDATE public.vehicles 
SET 
  gps_latitude = 13.7463 + (RANDOM() * 0.05 - 0.025), -- Random offset within ~2.5km
  gps_longitude = 100.5352 + (RANDOM() * 0.05 - 0.025),
  last_gps_update = NOW()
WHERE gps_latitude IS NULL OR gps_longitude IS NULL;