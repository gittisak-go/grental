-- ============================================================
-- Car Rental MVP: Cars, Bookings, Payments, Audit Log
-- Roles: Super_Admin, Admin, User, Guest
-- Principles: Default Deny, Least Privilege, No Privilege Escalation
-- ============================================================

-- ============================================================
-- STEP 1: Create cars table (extends existing vehicles table)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.cars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vehicle_id TEXT REFERENCES public.vehicles(vehicle_id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL CHECK (year >= 2000 AND year <= 2030),
    color TEXT,
    license_plate TEXT UNIQUE,
    category TEXT NOT NULL DEFAULT 'sedan' CHECK (category IN ('sedan', 'suv', 'pickup', 'van', 'hatchback', 'luxury')),
    seats INTEGER NOT NULL DEFAULT 5 CHECK (seats >= 2 AND seats <= 15),
    price_per_day NUMERIC(10,2) NOT NULL CHECK (price_per_day > 0),
    deposit_amount NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (deposit_amount >= 0),
    description TEXT,
    features JSONB DEFAULT '[]'::jsonb,
    images JSONB DEFAULT '[]'::jsonb,
    location TEXT DEFAULT 'สำนักงานใหญ่',
    is_available BOOLEAN NOT NULL DEFAULT true,
    is_active BOOLEAN NOT NULL DEFAULT true,
    mileage INTEGER DEFAULT 0 CHECK (mileage >= 0),
    last_service_date DATE,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cars_is_available ON public.cars(is_available);
CREATE INDEX IF NOT EXISTS idx_cars_category ON public.cars(category);
CREATE INDEX IF NOT EXISTS idx_cars_price_per_day ON public.cars(price_per_day);
CREATE INDEX IF NOT EXISTS idx_cars_vehicle_id ON public.cars(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_cars_is_active ON public.cars(is_active);

-- ============================================================
-- STEP 2: Create bookings table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_number TEXT UNIQUE NOT NULL DEFAULT ('BK-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 6))),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    car_id UUID NOT NULL REFERENCES public.cars(id) ON DELETE RESTRICT,
    pickup_date DATE NOT NULL,
    return_date DATE NOT NULL,
    pickup_location TEXT NOT NULL DEFAULT 'สำนักงานใหญ่',
    return_location TEXT NOT NULL DEFAULT 'สำนักงานใหญ่',
    total_days INTEGER GENERATED ALWAYS AS (return_date - pickup_date) STORED,
    price_per_day NUMERIC(10,2) NOT NULL,
    subtotal NUMERIC(10,2) NOT NULL,
    discount_amount NUMERIC(10,2) DEFAULT 0,
    deposit_amount NUMERIC(10,2) DEFAULT 0,
    total_amount NUMERIC(10,2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled', 'rejected')),
    payment_status TEXT NOT NULL DEFAULT 'unpaid' CHECK (payment_status IN ('unpaid', 'partial', 'paid', 'refunded')),
    special_requests TEXT,
    admin_notes TEXT,
    confirmed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMPTZ,
    cancelled_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT bookings_dates_check CHECK (return_date > pickup_date)
);

CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_car_id ON public.bookings(car_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_payment_status ON public.bookings(payment_status);
CREATE INDEX IF NOT EXISTS idx_bookings_pickup_date ON public.bookings(pickup_date);
CREATE INDEX IF NOT EXISTS idx_bookings_return_date ON public.bookings(return_date);
CREATE INDEX IF NOT EXISTS idx_bookings_booking_number ON public.bookings(booking_number);

-- ============================================================
-- STEP 3: Create payments table
-- ============================================================
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_number TEXT UNIQUE NOT NULL DEFAULT ('PAY-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 6))),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE RESTRICT,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    currency TEXT NOT NULL DEFAULT 'THB',
    payment_method TEXT NOT NULL DEFAULT 'bank_transfer' CHECK (payment_method IN ('bank_transfer', 'credit_card', 'debit_card', 'promptpay', 'cash', 'other')),
    payment_type TEXT NOT NULL DEFAULT 'booking' CHECK (payment_type IN ('booking', 'deposit', 'balance', 'refund', 'penalty')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled')),
    bank_name TEXT,
    bank_account_number TEXT,
    transfer_reference TEXT,
    slip_image_url TEXT,
    slip_uploaded_at TIMESTAMPTZ,
    verified_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    verified_at TIMESTAMPTZ,
    rejection_reason TEXT,
    notes TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON public.payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_payment_method ON public.payments(payment_method);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON public.payments(created_at);

-- ============================================================
-- STEP 4: Ensure audit_log table has all needed columns
-- (table already exists per schema analysis)
-- ============================================================
ALTER TABLE public.audit_log
ADD COLUMN IF NOT EXISTS user_agent TEXT;

ALTER TABLE public.audit_log
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS idx_audit_log_actor_id ON public.audit_log(actor_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_action ON public.audit_log(action);
CREATE INDEX IF NOT EXISTS idx_audit_log_table_name ON public.audit_log(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON public.audit_log(created_at);

-- ============================================================
-- STEP 5: Helper functions (MUST be before RLS policies)
-- These extend existing functions from fix_rls_security_policies migration
-- ============================================================

-- Function to log audit events
CREATE OR REPLACE FUNCTION public.log_audit_event(
    p_action TEXT,
    p_table_name TEXT,
    p_record_id UUID DEFAULT NULL,
    p_old_data JSONB DEFAULT NULL,
    p_new_data JSONB DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_role TEXT;
BEGIN
    SELECT role INTO v_role FROM public.profiles WHERE id = auth.uid() LIMIT 1;
    
    INSERT INTO public.audit_log (
        actor_id,
        actor_role,
        action,
        table_name,
        record_id,
        old_data,
        new_data,
        created_at
    ) VALUES (
        auth.uid(),
        COALESCE(v_role, 'Guest'),
        p_action,
        p_table_name,
        p_record_id,
        p_old_data,
        p_new_data,
        NOW()
    );
EXCEPTION
    WHEN OTHERS THEN
        -- Silently fail audit logging to not break main operations
        NULL;
END;
$$;

-- Function to check if a car is available for given dates
CREATE OR REPLACE FUNCTION public.is_car_available(
    p_car_id UUID,
    p_pickup_date DATE,
    p_return_date DATE,
    p_exclude_booking_id UUID DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT NOT EXISTS (
        SELECT 1 FROM public.bookings b
        WHERE b.car_id = p_car_id
          AND b.status NOT IN ('cancelled', 'rejected', 'completed')
          AND (p_exclude_booking_id IS NULL OR b.id != p_exclude_booking_id)
          AND (
              (b.pickup_date <= p_pickup_date AND b.return_date > p_pickup_date)
              OR (b.pickup_date < p_return_date AND b.return_date >= p_return_date)
              OR (b.pickup_date >= p_pickup_date AND b.return_date <= p_return_date)
          )
    )
    AND EXISTS (
        SELECT 1 FROM public.cars c
        WHERE c.id = p_car_id AND c.is_available = true AND c.is_active = true
    );
$$;

-- Trigger function: auto-update updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

-- Trigger function: update car availability when booking status changes
CREATE OR REPLACE FUNCTION public.sync_car_availability()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- When booking becomes active, mark car as unavailable
    IF NEW.status = 'active' AND (OLD.status IS NULL OR OLD.status != 'active') THEN
        UPDATE public.cars SET is_available = false, updated_at = NOW()
        WHERE id = NEW.car_id;
    END IF;
    
    -- When booking is completed/cancelled/rejected, check if car should be available again
    IF NEW.status IN ('completed', 'cancelled', 'rejected') AND OLD.status = 'active' THEN
        UPDATE public.cars SET is_available = true, updated_at = NOW()
        WHERE id = NEW.car_id
          AND NOT EXISTS (
              SELECT 1 FROM public.bookings
              WHERE car_id = NEW.car_id
                AND status = 'active'
                AND id != NEW.id
          );
    END IF;
    
    RETURN NEW;
END;
$$;

-- Trigger function: auto-update booking payment_status based on payments
CREATE OR REPLACE FUNCTION public.sync_booking_payment_status()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_total_paid NUMERIC(10,2);
    v_booking_total NUMERIC(10,2);
    v_new_status TEXT;
BEGIN
    SELECT COALESCE(SUM(amount), 0) INTO v_total_paid
    FROM public.payments
    WHERE booking_id = COALESCE(NEW.booking_id, OLD.booking_id)
      AND status = 'completed'
      AND payment_type != 'refund';
    
    SELECT total_amount INTO v_booking_total
    FROM public.bookings
    WHERE id = COALESCE(NEW.booking_id, OLD.booking_id)
    LIMIT 1;
    
    IF v_total_paid <= 0 THEN
        v_new_status := 'unpaid';
    ELSIF v_total_paid >= v_booking_total THEN
        v_new_status := 'paid';
    ELSE
        v_new_status := 'partial';
    END IF;
    
    UPDATE public.bookings
    SET payment_status = v_new_status, updated_at = NOW()
    WHERE id = COALESCE(NEW.booking_id, OLD.booking_id);
    
    RETURN NEW;
END;
$$;

-- ============================================================
-- STEP 6: Enable RLS on new tables
-- ============================================================
ALTER TABLE public.cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- STEP 7: RLS Policies for public.cars
-- Guest/User: SELECT only (available cars)
-- Admin: SELECT + INSERT + UPDATE
-- Super_Admin: Full access
-- ============================================================

-- SELECT: All authenticated users can view active cars
DROP POLICY IF EXISTS "cars_select_authenticated" ON public.cars;
CREATE POLICY "cars_select_authenticated"
    ON public.cars
    FOR SELECT
    TO authenticated
    USING (is_active = true OR public.is_admin_or_above());

-- SELECT: Public (anon) can view available cars
DROP POLICY IF EXISTS "cars_select_public" ON public.cars;
CREATE POLICY "cars_select_public"
    ON public.cars
    FOR SELECT
    TO anon
    USING (is_active = true AND is_available = true);

-- INSERT: Admin and Super_Admin only
DROP POLICY IF EXISTS "cars_insert_admin" ON public.cars;
CREATE POLICY "cars_insert_admin"
    ON public.cars
    FOR INSERT
    TO authenticated
    WITH CHECK (public.is_admin_or_above());

-- UPDATE: Admin and Super_Admin only
DROP POLICY IF EXISTS "cars_update_admin" ON public.cars;
CREATE POLICY "cars_update_admin"
    ON public.cars
    FOR UPDATE
    TO authenticated
    USING (public.is_admin_or_above())
    WITH CHECK (public.is_admin_or_above());

-- DELETE: Super_Admin only
DROP POLICY IF EXISTS "cars_delete_super_admin" ON public.cars;
CREATE POLICY "cars_delete_super_admin"
    ON public.cars
    FOR DELETE
    TO authenticated
    USING (public.is_super_admin());

-- ============================================================
-- STEP 8: RLS Policies for public.bookings
-- User: SELECT/INSERT/UPDATE own bookings
-- Admin: SELECT all + UPDATE status
-- Super_Admin: Full access
-- ============================================================

-- SELECT: User sees own bookings; Admin/Super_Admin sees all
DROP POLICY IF EXISTS "bookings_select_own" ON public.bookings;
CREATE POLICY "bookings_select_own"
    ON public.bookings
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid() OR public.is_admin_or_above());

-- INSERT: Authenticated users can create bookings for themselves
DROP POLICY IF EXISTS "bookings_insert_user" ON public.bookings;
CREATE POLICY "bookings_insert_user"
    ON public.bookings
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

-- UPDATE: User can update own pending bookings; Admin can update any
DROP POLICY IF EXISTS "bookings_update_own" ON public.bookings;
CREATE POLICY "bookings_update_own"
    ON public.bookings
    FOR UPDATE
    TO authenticated
    USING (
        (user_id = auth.uid() AND status IN ('pending'))
        OR public.is_admin_or_above()
    )
    WITH CHECK (
        (user_id = auth.uid() AND status IN ('pending'))
        OR public.is_admin_or_above()
    );

-- DELETE: Super_Admin only (soft delete preferred)
DROP POLICY IF EXISTS "bookings_delete_super_admin" ON public.bookings;
CREATE POLICY "bookings_delete_super_admin"
    ON public.bookings
    FOR DELETE
    TO authenticated
    USING (public.is_super_admin());

-- ============================================================
-- STEP 9: RLS Policies for public.payments
-- User: SELECT/INSERT own payments
-- Admin: SELECT all + UPDATE (verify/reject)
-- Super_Admin: Full access
-- ============================================================

-- SELECT: User sees own payments; Admin/Super_Admin sees all
DROP POLICY IF EXISTS "payments_select_own" ON public.payments;
CREATE POLICY "payments_select_own"
    ON public.payments
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid() OR public.is_admin_or_above());

-- INSERT: Authenticated users can submit payments for their own bookings
DROP POLICY IF EXISTS "payments_insert_user" ON public.payments;
CREATE POLICY "payments_insert_user"
    ON public.payments
    FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.bookings
            WHERE id = booking_id AND user_id = auth.uid()
        )
    );

-- UPDATE: Admin/Super_Admin can verify/reject payments
DROP POLICY IF EXISTS "payments_update_admin" ON public.payments;
CREATE POLICY "payments_update_admin"
    ON public.payments
    FOR UPDATE
    TO authenticated
    USING (public.is_admin_or_above())
    WITH CHECK (public.is_admin_or_above());

-- DELETE: Super_Admin only
DROP POLICY IF EXISTS "payments_delete_super_admin" ON public.payments;
CREATE POLICY "payments_delete_super_admin"
    ON public.payments
    FOR DELETE
    TO authenticated
    USING (public.is_super_admin());

-- ============================================================
-- STEP 10: RLS Policies for public.audit_log
-- User: No access
-- Admin: SELECT only
-- Super_Admin: SELECT + INSERT (system inserts via function)
-- ============================================================

DROP POLICY IF EXISTS "audit_log_select_admin" ON public.audit_log;
CREATE POLICY "audit_log_select_admin"
    ON public.audit_log
    FOR SELECT
    TO authenticated
    USING (public.is_admin_or_above());

DROP POLICY IF EXISTS "audit_log_insert_system" ON public.audit_log;
CREATE POLICY "audit_log_insert_system"
    ON public.audit_log
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- ============================================================
-- STEP 11: Triggers
-- ============================================================

-- updated_at triggers
DROP TRIGGER IF EXISTS set_cars_updated_at ON public.cars;
CREATE TRIGGER set_cars_updated_at
    BEFORE UPDATE ON public.cars
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_bookings_updated_at ON public.bookings;
CREATE TRIGGER set_bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

DROP TRIGGER IF EXISTS set_payments_updated_at ON public.payments;
CREATE TRIGGER set_payments_updated_at
    BEFORE UPDATE ON public.payments
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- Car availability sync trigger
DROP TRIGGER IF EXISTS trg_sync_car_availability ON public.bookings;
CREATE TRIGGER trg_sync_car_availability
    AFTER INSERT OR UPDATE OF status ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION public.sync_car_availability();

-- Payment status sync trigger
DROP TRIGGER IF EXISTS trg_sync_booking_payment_status ON public.payments;
CREATE TRIGGER trg_sync_booking_payment_status
    AFTER INSERT OR UPDATE OF status ON public.payments
    FOR EACH ROW
    EXECUTE FUNCTION public.sync_booking_payment_status();

-- ============================================================
-- STEP 12: Seed data — Cars (12 vehicles matching app data)
-- ============================================================
DO $$
DECLARE
    car1_id UUID := gen_random_uuid();
    car2_id UUID := gen_random_uuid();
    car3_id UUID := gen_random_uuid();
    car4_id UUID := gen_random_uuid();
    car5_id UUID := gen_random_uuid();
    car6_id UUID := gen_random_uuid();
    car7_id UUID := gen_random_uuid();
    car8_id UUID := gen_random_uuid();
    car9_id UUID := gen_random_uuid();
    car10_id UUID := gen_random_uuid();
    car11_id UUID := gen_random_uuid();
    car12_id UUID := gen_random_uuid();
BEGIN
    INSERT INTO public.cars (
        id, name, brand, model, year, color, license_plate, category,
        seats, price_per_day, deposit_amount, description, features, images,
        location, is_available, is_active
    ) VALUES
    (
        car1_id, 'Honda City Turbo', 'Honda', 'City Turbo', 2023, 'ขาว', 'กข-1234',
        'sedan', 5, 1200.00, 5000.00,
        'Honda City Turbo รุ่นใหม่ ประหยัดน้ำมัน สมรรถนะดี เหมาะสำหรับการเดินทางในเมือง',
        '["เกียร์อัตโนมัติ", "กล้องถอยหลัง", "เซ็นเซอร์จอดรถ", "Apple CarPlay", "Android Auto"]'::jsonb,
        '["https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800"]'::jsonb,
        'สำนักงานใหญ่', true, true
    ),
    (
        car2_id, 'Toyota Yaris Sport', 'Toyota', 'Yaris Sport', 2023, 'แดง', 'คง-5678',
        'hatchback', 5, 900.00, 4000.00,
        'Toyota Yaris Sport สปอร์ตสไตล์ ขับสนุก ประหยัดน้ำมัน',
        '["เกียร์อัตโนมัติ", "กล้องถอยหลัง", "Bluetooth", "USB Charging"]'::jsonb,
        '["https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800"]'::jsonb,
        'สำนักงานใหญ่', true, true
    ),
    (
        car3_id, 'Toyota Yaris Ativ', 'Toyota', 'Yaris Ativ', 2022, 'เงิน', 'งจ-9012',
        'sedan', 5, 850.00, 3500.00,
        'Toyota Yaris Ativ ประหยัดน้ำมัน เหมาะสำหรับการเดินทางในเมืองและต่างจังหวัด',
        '["เกียร์อัตโนมัติ", "กล้องถอยหลัง", "Bluetooth"]'::jsonb,
        '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800"]'::jsonb,
        'สาขาสนามบิน', true, true
    ),
    (
        car4_id, 'Nissan Almera', 'Nissan', 'Almera', 2023, 'ดำ', 'ฉช-3456',
        'sedan', 5, 950.00, 4000.00,
        'Nissan Almera ซีดานสไตล์หรู ขับสบาย เหมาะสำหรับทุกการเดินทาง',
        '["เกียร์อัตโนมัติ", "กล้องถอยหลัง", "เซ็นเซอร์จอดรถ", "Bluetooth"]'::jsonb,
        '["https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800"]'::jsonb,
        'สำนักงานใหญ่', true, true
    ),
    (
        car5_id, 'Suzuki Ciaz', 'Suzuki', 'Ciaz', 2022, 'น้ำเงิน', 'ซฌ-7890',
        'sedan', 5, 800.00, 3500.00,
        'Suzuki Ciaz ซีดานประหยัดน้ำมัน ขับสบาย ราคาคุ้มค่า',
        '["เกียร์อัตโนมัติ", "กล้องถอยหลัง", "Bluetooth", "USB Charging"]'::jsonb,
        '["https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800"]'::jsonb,
        'สาขาสนามบิน', true, true
    ),
    (
        car6_id, 'Ford Ranger Raptor', 'Ford', 'Ranger Raptor', 2023, 'ส้ม', 'ญฎ-1234',
        'pickup', 5, 2500.00, 10000.00,
        'Ford Ranger Raptor กระบะสมรรถนะสูง เหมาะสำหรับการผจญภัยและการเดินทางออฟโรด',
        '["เกียร์อัตโนมัติ", "4WD", "กล้องถอยหลัง 360°", "Apple CarPlay", "Android Auto", "หลังคาแข็ง"]'::jsonb,
        '["https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800"]'::jsonb,
        'สำนักงานใหญ่', true, true
    ),
    (
        car7_id, 'Toyota Vigo Champ', 'Toyota', 'Hilux Vigo Champ', 2022, 'ขาว', 'ฏฐ-5678',
        'pickup', 5, 1800.00, 7000.00,
        'Toyota Hilux Vigo Champ กระบะทนทาน เชื่อถือได้ เหมาะสำหรับทุกสภาพถนน',
        '["เกียร์อัตโนมัติ", "4WD", "กล้องถอยหลัง", "Bluetooth"]'::jsonb,
        '["https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800"]'::jsonb,
        'สำนักงานใหญ่', true, true
    ),
    (
        car8_id, 'Toyota Veloz', 'Toyota', 'Veloz', 2023, 'เทา', 'ณด-9012',
        'van', 7, 1500.00, 6000.00,
        'Toyota Veloz MPV 7 ที่นั่ง เหมาะสำหรับครอบครัวและกลุ่มเพื่อน',
        '["เกียร์อัตโนมัติ", "7 ที่นั่ง", "กล้องถอยหลัง", "Apple CarPlay", "Android Auto"]'::jsonb,
        '["https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800"]'::jsonb,
        'สาขาสนามบิน', true, true
    ),
    (
        car9_id, 'Mitsubishi Pajero Sport Elite', 'Mitsubishi', 'Pajero Sport Elite', 2023, 'ดำ', 'ตถ-3456',
        'suv', 7, 3000.00, 12000.00,
        'Mitsubishi Pajero Sport Elite SUV หรูหรา 7 ที่นั่ง เหมาะสำหรับการเดินทางระยะไกล',
        '["เกียร์อัตโนมัติ", "4WD", "7 ที่นั่ง", "กล้อง 360°", "Apple CarPlay", "Android Auto", "หลังคาซันรูฟ"]'::jsonb,
        '["https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800"]'::jsonb,
        'สำนักงานใหญ่', true, true
    ),
    (
        car10_id, 'Toyota Cross', 'Toyota', 'Corolla Cross', 2023, 'ขาว', 'ทน-7890',
        'suv', 5, 1800.00, 7000.00,
        'Toyota Corolla Cross SUV ไฮบริด ประหยัดน้ำมัน สมรรถนะดี',
        '["เกียร์อัตโนมัติ", "Hybrid", "กล้องถอยหลัง", "เซ็นเซอร์จอดรถ", "Apple CarPlay"]'::jsonb,
        '["https://images.unsplash.com/photo-1617469767053-d3b523a0b982?w=800"]'::jsonb,
        'สาขาสนามบิน', true, true
    ),
    (
        car11_id, 'Mitsubishi Xpander', 'Mitsubishi', 'Xpander', 2023, 'เงิน', 'บป-1234',
        'van', 7, 1400.00, 5500.00,
        'Mitsubishi Xpander MPV 7 ที่นั่ง ดีไซน์สปอร์ต เหมาะสำหรับครอบครัว',
        '["เกียร์อัตโนมัติ", "7 ที่นั่ง", "กล้องถอยหลัง", "Bluetooth", "USB Charging"]'::jsonb,
        '["https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800"]'::jsonb,
        'สำนักงานใหญ่', true, true
    ),
    (
        car12_id, 'Isuzu MU-X', 'Isuzu', 'MU-X', 2023, 'น้ำตาล', 'ผฝ-5678',
        'suv', 7, 2200.00, 9000.00,
        'Isuzu MU-X SUV 7 ที่นั่ง ทนทาน เหมาะสำหรับการเดินทางทุกสภาพถนน',
        '["เกียร์อัตโนมัติ", "4WD", "7 ที่นั่ง", "กล้องถอยหลัง", "Apple CarPlay", "Android Auto"]'::jsonb,
        '["https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800"]'::jsonb,
        'สาขาสนามบิน', true, true
    )
    ON CONFLICT (id) DO NOTHING;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Car seed data insertion failed: %', SQLERRM;
END $$;
