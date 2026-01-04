-- Migration to fix seats constraint to accommodate larger vehicles
-- The previous constraint allowed only 2-12 seats, but vans and buses need more

-- Drop the existing check constraint
ALTER TABLE public.vehicles DROP CONSTRAINT IF EXISTS vehicles_seats_check;

-- Add new constraint that allows up to 20 seats for larger vehicles (vans, buses)
ALTER TABLE public.vehicles ADD CONSTRAINT vehicles_seats_check 
    CHECK (seats >= 2 AND seats <= 20);

COMMENT ON CONSTRAINT vehicles_seats_check ON public.vehicles IS 'Allows vehicles with 2-20 seats to accommodate cars, vans, and small buses';