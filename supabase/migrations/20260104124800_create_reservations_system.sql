-- Location: supabase/migrations/20260104124800_create_reservations_system.sql
-- Schema Analysis: Existing vehicles table with complete car rental data
-- Integration Type: Addition - Adding booking/reservation system
-- Dependencies: vehicles table (existing)

-- 1. Create reservation status enum
CREATE TYPE public.reservation_status AS ENUM (
    'pending',
    'confirmed',
    'active',
    'completed',
    'cancelled'
);

-- 2. Create reservations table
CREATE TABLE public.reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id UUID NOT NULL REFERENCES public.vehicles(id) ON DELETE RESTRICT,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    customer_id_card TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    pickup_location TEXT NOT NULL,
    dropoff_location TEXT,
    total_days INTEGER NOT NULL,
    daily_rate NUMERIC NOT NULL,
    total_amount NUMERIC NOT NULL,
    deposit_amount NUMERIC DEFAULT 0,
    status public.reservation_status DEFAULT 'pending'::public.reservation_status,
    special_requests TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_dates CHECK (end_date >= start_date),
    CONSTRAINT valid_total_days CHECK (total_days > 0),
    CONSTRAINT valid_amounts CHECK (total_amount >= 0 AND daily_rate >= 0 AND deposit_amount >= 0)
);

-- 3. Create indexes for reservations
CREATE INDEX idx_reservations_vehicle_id ON public.reservations(vehicle_id);
CREATE INDEX idx_reservations_customer_email ON public.reservations(customer_email);
CREATE INDEX idx_reservations_status ON public.reservations(status);
CREATE INDEX idx_reservations_start_date ON public.reservations(start_date);
CREATE INDEX idx_reservations_end_date ON public.reservations(end_date);
CREATE INDEX idx_reservations_created_at ON public.reservations(created_at);

-- 4. Create trigger function for updating updated_at
CREATE OR REPLACE FUNCTION public.update_reservations_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

-- 5. Create trigger
CREATE TRIGGER trigger_update_reservations_updated_at
    BEFORE UPDATE ON public.reservations
    FOR EACH ROW
    EXECUTE FUNCTION public.update_reservations_updated_at();

-- 6. Enable RLS
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;

-- 7. Create RLS policies for reservations
-- Allow authenticated users to read all reservations (admin access)
CREATE POLICY "authenticated_users_read_reservations"
ON public.reservations
FOR SELECT
TO authenticated
USING (true);

-- Allow authenticated users to insert reservations
CREATE POLICY "authenticated_users_insert_reservations"
ON public.reservations
FOR INSERT
TO authenticated
WITH CHECK (true);

-- Allow authenticated users to update reservations
CREATE POLICY "authenticated_users_update_reservations"
ON public.reservations
FOR UPDATE
TO authenticated
USING (true)
WITH CHECK (true);

-- Allow authenticated users to delete reservations
CREATE POLICY "authenticated_users_delete_reservations"
ON public.reservations
FOR DELETE
TO authenticated
USING (true);

-- Allow anonymous users to read active/confirmed reservations (for public display)
CREATE POLICY "anonymous_users_read_active_reservations"
ON public.reservations
FOR SELECT
TO anon
USING (status IN ('confirmed', 'active'));

-- 8. Create mock data using ONLY existing vehicles
DO $$
DECLARE
    vehicle1_id UUID;
    vehicle2_id UUID;
BEGIN
    -- Get existing vehicle IDs from actual database
    SELECT id INTO vehicle1_id FROM public.vehicles WHERE brand = 'Toyota' AND model = 'Camry' LIMIT 1;
    SELECT id INTO vehicle2_id FROM public.vehicles WHERE brand = 'Honda' AND model = 'Civic' LIMIT 1;

    -- Only insert if vehicles exist
    IF vehicle1_id IS NOT NULL AND vehicle2_id IS NOT NULL THEN
        -- Insert sample reservations with Thai customer names
        INSERT INTO public.reservations (
            vehicle_id,
            customer_name,
            customer_email,
            customer_phone,
            customer_id_card,
            start_date,
            end_date,
            pickup_location,
            dropoff_location,
            total_days,
            daily_rate,
            total_amount,
            deposit_amount,
            status,
            special_requests
        ) VALUES
        (
            vehicle1_id,
            'สมชาย ใจดี',
            'somchai.jaidee@email.com',
            '081-234-5678',
            '1-1234-56789-01-2',
            CURRENT_DATE + INTERVAL '2 days',
            CURRENT_DATE + INTERVAL '5 days',
            'สนามบินดอนเมือง',
            'สนามบินดอนเมือง',
            3,
            1500,
            4500,
            1500,
            'confirmed',
            'ต้องการที่นั่งเด็ก 1 ที่'
        ),
        (
            vehicle2_id,
            'สมหญิง รักสนุก',
            'somying.raksanuk@email.com',
            '082-345-6789',
            '1-2345-67890-12-3',
            CURRENT_DATE + INTERVAL '1 day',
            CURRENT_DATE + INTERVAL '3 days',
            'สนามบินสุวรรณภูมิ',
            'สนามบินสุวรรณภูมิ',
            2,
            1200,
            2400,
            1000,
            'pending',
            'รับรถที่สนามบินเวลา 10:00 น.'
        ),
        (
            vehicle1_id,
            'ประยุทธ มั่นคง',
            'prayut.mankhong@email.com',
            '083-456-7890',
            '1-3456-78901-23-4',
            CURRENT_DATE - INTERVAL '2 days',
            CURRENT_DATE + INTERVAL '3 days',
            'โรงแรมในกรุงเทพ',
            'เชียงใหม่',
            5,
            1500,
            7500,
            2500,
            'active',
            'เดินทางท่องเที่ยวเชียงใหม่'
        ),
        (
            vehicle2_id,
            'วิไล สว่างจิต',
            'wilai.swangjit@email.com',
            '084-567-8901',
            '1-4567-89012-34-5',
            CURRENT_DATE + INTERVAL '7 days',
            CURRENT_DATE + INTERVAL '10 days',
            'พัทยา',
            'พัทยา',
            3,
            1200,
            3600,
            1200,
            'confirmed',
            NULL
        ),
        (
            vehicle1_id,
            'นภัสวรรณ สุขใจ',
            'napat.sukchai@email.com',
            '085-678-9012',
            '1-5678-90123-45-6',
            CURRENT_DATE - INTERVAL '5 days',
            CURRENT_DATE - INTERVAL '2 days',
            'หัวหิน',
            'หัวหิน',
            3,
            1500,
            4500,
            1500,
            'completed',
            'เดินทางเที่ยวทะเล'
        );
    END IF;
END $$;

-- 9. Create function to check vehicle availability
CREATE OR REPLACE FUNCTION public.check_vehicle_availability(
    p_vehicle_id UUID,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS BOOLEAN
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $func$
BEGIN
    RETURN NOT EXISTS (
        SELECT 1
        FROM public.reservations r
        WHERE r.vehicle_id = p_vehicle_id
        AND r.status IN ('confirmed', 'active')
        AND (
            (r.start_date <= p_end_date AND r.end_date >= p_start_date)
        )
    );
END;
$func$;

COMMENT ON TABLE public.reservations IS 'Stores car rental reservations and bookings';
COMMENT ON TYPE public.reservation_status IS 'Status of car rental reservation';