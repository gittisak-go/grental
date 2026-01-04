-- Location: supabase/migrations/20260104141212_add_fleet_inventory_features.sql
-- Schema Analysis: Extending existing vehicles table for fleet inventory management
-- Integration Type: extension
-- Dependencies: vehicles table (already exists)

-- 1. Create ENUM for vehicle status
CREATE TYPE public.vehicle_status AS ENUM ('available', 'in_use', 'maintenance', 'offline');

-- 2. Add fleet management columns to existing vehicles table
ALTER TABLE public.vehicles
ADD COLUMN IF NOT EXISTS status public.vehicle_status DEFAULT 'available'::public.vehicle_status,
ADD COLUMN IF NOT EXISTS license_plate TEXT,
ADD COLUMN IF NOT EXISTS fuel_level NUMERIC(5,2) DEFAULT 100.00,
ADD COLUMN IF NOT EXISTS fuel_capacity NUMERIC(5,2) DEFAULT 50.00,
ADD COLUMN IF NOT EXISTS current_mileage NUMERIC(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS gps_latitude NUMERIC(10,8),
ADD COLUMN IF NOT EXISTS gps_longitude NUMERIC(11,8),
ADD COLUMN IF NOT EXISTS last_gps_update TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS last_maintenance_date DATE,
ADD COLUMN IF NOT EXISTS next_maintenance_date DATE,
ADD COLUMN IF NOT EXISTS utilization_rate NUMERIC(5,2) DEFAULT 0;

-- 3. Create maintenance_schedules table
CREATE TABLE public.maintenance_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID REFERENCES public.vehicles(id) ON DELETE CASCADE,
    service_type TEXT NOT NULL,
    scheduled_date DATE NOT NULL,
    completed_date DATE,
    status TEXT DEFAULT 'pending',
    notes TEXT,
    cost NUMERIC(10,2),
    technician_name TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Create indexes for fleet operations
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON public.vehicles(status);
CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON public.vehicles(license_plate);
CREATE INDEX IF NOT EXISTS idx_vehicles_fuel_level ON public.vehicles(fuel_level);
CREATE INDEX IF NOT EXISTS idx_vehicles_next_maintenance ON public.vehicles(next_maintenance_date);
CREATE INDEX IF NOT EXISTS idx_maintenance_schedules_vehicle_id ON public.maintenance_schedules(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_schedules_scheduled_date ON public.maintenance_schedules(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_maintenance_schedules_status ON public.maintenance_schedules(status);

-- 5. Create trigger function for maintenance_schedules updated_at
CREATE OR REPLACE FUNCTION public.update_maintenance_schedules_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 6. Create trigger for maintenance_schedules
CREATE TRIGGER trigger_update_maintenance_schedules_updated_at
BEFORE UPDATE ON public.maintenance_schedules
FOR EACH ROW
EXECUTE FUNCTION public.update_maintenance_schedules_updated_at();

-- 7. Enable RLS for maintenance_schedules
ALTER TABLE public.maintenance_schedules ENABLE ROW LEVEL SECURITY;

-- 8. RLS policies for maintenance_schedules (Pattern 4 - Public Read, Private Write)
CREATE POLICY "public_can_read_maintenance_schedules"
ON public.maintenance_schedules
FOR SELECT
TO public
USING (true);

CREATE POLICY "authenticated_manage_maintenance_schedules"
ON public.maintenance_schedules
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 9. Add mock data for fleet inventory features
DO $$
DECLARE
    vehicle1_id UUID;
    vehicle2_id UUID;
BEGIN
    -- Get existing vehicle IDs
    SELECT id INTO vehicle1_id FROM public.vehicles LIMIT 1 OFFSET 0;
    SELECT id INTO vehicle2_id FROM public.vehicles LIMIT 1 OFFSET 1;

    -- Update existing vehicles with fleet data
    UPDATE public.vehicles
    SET 
        status = 'available'::public.vehicle_status,
        license_plate = 'กข-1234 กทม',
        fuel_level = 85.50,
        fuel_capacity = 55.00,
        current_mileage = 45230.00,
        gps_latitude = 13.7563,
        gps_longitude = 100.5018,
        last_gps_update = CURRENT_TIMESTAMP,
        last_maintenance_date = CURRENT_DATE - INTERVAL '15 days',
        next_maintenance_date = CURRENT_DATE + INTERVAL '45 days',
        utilization_rate = 78.50
    WHERE id = vehicle1_id;

    UPDATE public.vehicles
    SET 
        status = 'in_use'::public.vehicle_status,
        license_plate = 'ฉช-5678 กทม',
        fuel_level = 62.30,
        fuel_capacity = 50.00,
        current_mileage = 32145.00,
        gps_latitude = 13.7650,
        gps_longitude = 100.5380,
        last_gps_update = CURRENT_TIMESTAMP,
        last_maintenance_date = CURRENT_DATE - INTERVAL '8 days',
        next_maintenance_date = CURRENT_DATE + INTERVAL '52 days',
        utilization_rate = 82.00
    WHERE id = vehicle2_id;

    -- Add maintenance schedules
    INSERT INTO public.maintenance_schedules (vehicle_id, service_type, scheduled_date, status, notes, cost)
    VALUES
        (vehicle1_id, 'Oil Change', CURRENT_DATE + INTERVAL '10 days', 'pending', 'Regular 5,000 km service', 1200.00),
        (vehicle1_id, 'Tire Rotation', CURRENT_DATE + INTERVAL '20 days', 'pending', 'Check tire wear and alignment', 800.00),
        (vehicle2_id, 'Brake Inspection', CURRENT_DATE + INTERVAL '5 days', 'scheduled', 'Annual brake system check', 1500.00),
        (vehicle2_id, 'Air Filter Replacement', CURRENT_DATE + INTERVAL '15 days', 'pending', 'Replace cabin and engine air filters', 600.00);
END $$;