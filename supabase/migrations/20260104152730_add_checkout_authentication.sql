-- Location: supabase/migrations/20260104152730_add_checkout_authentication.sql
-- Schema Analysis: Extends existing reservations system with authentication and payment tracking
-- Integration Type: Extension - adds auth infrastructure and payment transactions
-- Dependencies: vehicles (existing), reservations (existing), auth.users (Supabase managed)

-- ============================================================================
-- 1. ENUM TYPES - Payment status and methods
-- ============================================================================

CREATE TYPE public.payment_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded'
);

CREATE TYPE public.payment_method AS ENUM (
    'bank_transfer',
    'credit_card',
    'cash',
    'qr_payment'
);

-- ============================================================================
-- 2. CORE TABLES - User profiles (auth intermediary)
-- ============================================================================

CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.user_profiles IS 'User profile information linked to Supabase auth.users';

-- ============================================================================
-- 3. DEPENDENT TABLES - Payment transactions
-- ============================================================================

CREATE TABLE public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id UUID NOT NULL REFERENCES public.reservations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    payment_method public.payment_method NOT NULL,
    payment_status public.payment_status DEFAULT 'pending'::public.payment_status,
    transaction_reference TEXT,
    payment_date TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE public.payment_transactions IS 'Tracks payment transactions for rental reservations';

-- ============================================================================
-- 4. INDEXES - Performance optimization
-- ============================================================================

CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_payment_transactions_reservation_id ON public.payment_transactions(reservation_id);
CREATE INDEX idx_payment_transactions_user_id ON public.payment_transactions(user_id);
CREATE INDEX idx_payment_transactions_status ON public.payment_transactions(payment_status);
CREATE INDEX idx_payment_transactions_created_at ON public.payment_transactions(created_at);

-- ============================================================================
-- 5. FUNCTIONS - Automatic profile creation and timestamp updates
-- ============================================================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, phone, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'phone', NULL),
        COALESCE(NEW.raw_user_meta_data->>'avatar_url', NULL)
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_user_profiles_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_payment_transactions_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- ============================================================================
-- 6. RLS SETUP - Enable row level security
-- ============================================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 7. RLS POLICIES - User-based access control
-- ============================================================================

-- Pattern 1: Core user table - Simple ownership
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for payment transactions
CREATE POLICY "users_manage_own_payment_transactions"
ON public.payment_transactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Public read access for user profiles (optional - for displaying names in rental status)
CREATE POLICY "public_read_user_profiles"
ON public.user_profiles
FOR SELECT
TO public
USING (true);

-- ============================================================================
-- 8. TRIGGERS - Automatic updates
-- ============================================================================

CREATE TRIGGER trigger_handle_new_user
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

CREATE TRIGGER trigger_update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_user_profiles_updated_at();

CREATE TRIGGER trigger_update_payment_transactions_updated_at
    BEFORE UPDATE ON public.payment_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_payment_transactions_updated_at();

-- ============================================================================
-- 9. MOCK DATA - Test users and payment transactions
-- ============================================================================

DO $$
DECLARE
    customer_uuid UUID := gen_random_uuid();
    admin_uuid UUID := gen_random_uuid();
    existing_reservation_id UUID;
BEGIN
    -- Create test auth users with complete fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (customer_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'customer@rungrojcarrental.com', crypt('customer123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "สมชาย รักรถ", "phone": "081-234-5678"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@rungrojcarrental.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Patteera Sunatrai", "phone": "085-123-4567"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Get existing reservation ID
    SELECT id INTO existing_reservation_id FROM public.reservations LIMIT 1;

    -- Create sample payment transactions if reservation exists
    IF existing_reservation_id IS NOT NULL THEN
        INSERT INTO public.payment_transactions (
            reservation_id, user_id, amount, payment_method, payment_status,
            transaction_reference, payment_date, notes
        ) VALUES
            (existing_reservation_id, customer_uuid, 1500.00, 'bank_transfer'::public.payment_method,
             'completed'::public.payment_status, 'BT-2026-001', now() - interval '1 day',
             'มัดจำค่าเช่ารถ BMW 3 Series'),
            (existing_reservation_id, customer_uuid, 3000.00, 'bank_transfer'::public.payment_method,
             'pending'::public.payment_status, null, null,
             'รอชำระค่าเช่าส่วนที่เหลือ');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data insertion error: %', SQLERRM;
END $$;