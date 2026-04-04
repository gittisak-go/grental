-- ============================================================
-- Seed Data for Car Rental App
-- Environment: staging / preview
-- Roles: Super_Admin, Admin, User, Guest
-- NOTE: This seed runs AFTER all migrations
-- ============================================================

-- ============================================================
-- Test Users (for staging/preview only)
-- Passwords: Test@1234 for all test accounts
-- ============================================================
DO $$
DECLARE
    super_admin1_id UUID := gen_random_uuid();
    super_admin2_id UUID := gen_random_uuid();
    admin1_id UUID := gen_random_uuid();
    user1_id UUID := gen_random_uuid();
    user2_id UUID := gen_random_uuid();
    guest1_id UUID := gen_random_uuid();
    
    car1_id UUID;
    car2_id UUID;
    car3_id UUID;
    
    booking1_id UUID := gen_random_uuid();
    booking2_id UUID := gen_random_uuid();
    booking3_id UUID := gen_random_uuid();
BEGIN
    -- --------------------------------------------------------
    -- Create test auth users
    -- --------------------------------------------------------
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
    -- Super Admin 1
    (super_admin1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     'phongwut.w@gmail.com', crypt('Test@1234', gen_salt('bf', 10)), now(), now(), now(),
     jsonb_build_object('full_name', 'พงศ์วุฒิ วงศ์', 'role', 'Super_Admin'),
     jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
     false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
    -- Super Admin 2
    (super_admin2_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     'gittisakwannakeeree@gmail.com', crypt('Test@1234', gen_salt('bf', 10)), now(), now(), now(),
     jsonb_build_object('full_name', 'กิตติศักดิ์ วรรณกีรี', 'role', 'Super_Admin'),
     jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
     false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
    -- Admin
    (admin1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     'nongsandyza@gmail.com', crypt('Test@1234', gen_salt('bf', 10)), now(), now(), now(),
     jsonb_build_object('full_name', 'น้องแซนดี้', 'role', 'Admin'),
     jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
     false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
    -- User 1
    (user1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     'mtdzfc@gmail.com', crypt('Test@1234', gen_salt('bf', 10)), now(), now(), now(),
     jsonb_build_object('full_name', 'ผู้ใช้ทดสอบ', 'role', 'User'),
     jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
     false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
    -- User 2
    (user2_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     'testuser2@example.com', crypt('Test@1234', gen_salt('bf', 10)), now(), now(), now(),
     jsonb_build_object('full_name', 'สมชาย ใจดี', 'role', 'User'),
     jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
     false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
    -- Guest
    (guest1_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
     'guest@example.com', crypt('Test@1234', gen_salt('bf', 10)), now(), now(), now(),
     jsonb_build_object('full_name', 'ผู้เยี่ยมชม', 'role', 'Guest'),
     jsonb_build_object('provider', 'email', 'providers', ARRAY['email']::TEXT[]),
     false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null)
    ON CONFLICT (id) DO NOTHING;

    -- --------------------------------------------------------
    -- Get car IDs for bookings
    -- --------------------------------------------------------
    SELECT id INTO car1_id FROM public.cars WHERE name = 'Honda City Turbo' LIMIT 1;
    SELECT id INTO car2_id FROM public.cars WHERE name = 'Toyota Yaris Sport' LIMIT 1;
    SELECT id INTO car3_id FROM public.cars WHERE name = 'Mitsubishi Pajero Sport Elite' LIMIT 1;

    -- --------------------------------------------------------
    -- Create test bookings (only if cars exist)
    -- --------------------------------------------------------
    IF car1_id IS NOT NULL THEN
        INSERT INTO public.bookings (
            id, booking_number, user_id, car_id,
            pickup_date, return_date,
            pickup_location, return_location,
            price_per_day, subtotal, deposit_amount, total_amount,
            status, payment_status, special_requests
        ) VALUES
        (
            booking1_id,
            'BK-TEST-001',
            user1_id, car1_id,
            CURRENT_DATE + 3, CURRENT_DATE + 6,
            'สำนักงานใหญ่', 'สำนักงานใหญ่',
            1200.00, 3600.00, 5000.00, 8600.00,
            'confirmed', 'partial',
            'ต้องการที่นั่งเด็ก 1 ชุด'
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    IF car2_id IS NOT NULL THEN
        INSERT INTO public.bookings (
            id, booking_number, user_id, car_id,
            pickup_date, return_date,
            pickup_location, return_location,
            price_per_day, subtotal, deposit_amount, total_amount,
            status, payment_status
        ) VALUES
        (
            booking2_id,
            'BK-TEST-002',
            user2_id, car2_id,
            CURRENT_DATE + 7, CURRENT_DATE + 10,
            'สาขาสนามบิน', 'สาขาสนามบิน',
            900.00, 2700.00, 4000.00, 6700.00,
            'pending', 'unpaid'
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    IF car3_id IS NOT NULL THEN
        INSERT INTO public.bookings (
            id, booking_number, user_id, car_id,
            pickup_date, return_date,
            pickup_location, return_location,
            price_per_day, subtotal, deposit_amount, total_amount,
            status, payment_status, admin_notes
        ) VALUES
        (
            booking3_id,
            'BK-TEST-003',
            user1_id, car3_id,
            CURRENT_DATE - 10, CURRENT_DATE - 5,
            'สำนักงานใหญ่', 'สำนักงานใหญ่',
            3000.00, 15000.00, 12000.00, 27000.00,
            'completed', 'paid',
            'ลูกค้าคืนรถตรงเวลา สภาพดี'
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- --------------------------------------------------------
    -- Create test payments
    -- --------------------------------------------------------
    IF car1_id IS NOT NULL THEN
        INSERT INTO public.payments (
            id, payment_number, booking_id, user_id,
            amount, currency, payment_method, payment_type,
            status, bank_name, transfer_reference, notes
        ) VALUES
        (
            gen_random_uuid(),
            'PAY-TEST-001',
            booking1_id, user1_id,
            5000.00, 'THB', 'bank_transfer', 'deposit',
            'completed', 'กสิกรไทย', 'REF-20260404-001',
            'ชำระมัดจำ'
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    IF car3_id IS NOT NULL THEN
        INSERT INTO public.payments (
            id, payment_number, booking_id, user_id,
            amount, currency, payment_method, payment_type,
            status, bank_name, transfer_reference, notes
        ) VALUES
        (
            gen_random_uuid(),
            'PAY-TEST-002',
            booking3_id, user1_id,
            27000.00, 'THB', 'bank_transfer', 'booking',
            'completed', 'ไทยพาณิชย์', 'REF-20260325-001',
            'ชำระเต็มจำนวน'
        )
        ON CONFLICT (id) DO NOTHING;
    END IF;

    -- --------------------------------------------------------
    -- Seed audit log entries
    -- --------------------------------------------------------
    INSERT INTO public.audit_log (
        id, actor_id, actor_role, action, table_name, record_id, new_data, created_at
    ) VALUES
    (
        gen_random_uuid(), super_admin1_id, 'Super_Admin',
        'SEED_DATA_CREATED', 'system', NULL,
        jsonb_build_object('environment', 'staging', 'created_at', NOW()::TEXT),
        NOW()
    )
    ON CONFLICT (id) DO NOTHING;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Seed data insertion failed: %', SQLERRM;
END $$;

-- ============================================================
-- Seed Summary
-- ============================================================
-- Test Accounts (password: Test@1234 for all):
-- Super_Admin: phongwut.w@gmail.com
-- Super_Admin: gittisakwannakeeree@gmail.com
-- Admin:       nongsandyza@gmail.com
-- User:        mtdzfc@gmail.com
-- User:        testuser2@example.com
-- Guest:       guest@example.com
--
-- Cars: 12 vehicles seeded via migration
-- Bookings: 3 test bookings (confirmed, pending, completed)
-- Payments: 2 test payments
-- ============================================================
