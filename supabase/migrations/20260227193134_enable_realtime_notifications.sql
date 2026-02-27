-- Location: supabase/migrations/20260227193134_enable_realtime_notifications.sql
-- Schema Analysis: Existing reservations, vehicles, notification_preferences tables
-- Integration Type: Addition - Enable realtime + app_notifications table
-- Dependencies: reservations, vehicles, user_profiles, notification_preferences tables

-- 1. Create notification type enum
DROP TYPE IF EXISTS public.app_notification_type CASCADE;
CREATE TYPE public.app_notification_type AS ENUM (
    'vehicle_available',
    'booking_confirmed',
    'booking_cancelled',
    'booking_modified',
    'rental_active',
    'rental_completed',
    'payment_success',
    'payment_failed'
);

-- 2. Create app_notifications table for storing in-app notifications
CREATE TABLE IF NOT EXISTS public.app_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE NOT NULL,
    notification_type public.app_notification_type NOT NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    reference_id UUID,
    reference_table TEXT,
    is_read BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 3. Create indexes
CREATE INDEX IF NOT EXISTS idx_app_notifications_user_id ON public.app_notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_app_notifications_is_read ON public.app_notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_app_notifications_created_at ON public.app_notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_app_notifications_type ON public.app_notifications(notification_type);

-- 4. Enable RLS
ALTER TABLE public.app_notifications ENABLE ROW LEVEL SECURITY;

-- 5. RLS policies
DROP POLICY IF EXISTS "users_manage_own_app_notifications" ON public.app_notifications;
CREATE POLICY "users_manage_own_app_notifications"
ON public.app_notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 6. Function to create a notification respecting user preferences
CREATE OR REPLACE FUNCTION public.create_notification_if_enabled(
    p_user_id UUID,
    p_notification_type public.app_notification_type,
    p_title TEXT,
    p_body TEXT,
    p_reference_id UUID DEFAULT NULL,
    p_reference_table TEXT DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_category TEXT;
    v_is_enabled BOOLEAN := true;
    v_notification_id UUID;
BEGIN
    -- Map notification type to preference category
    CASE p_notification_type
        WHEN 'booking_confirmed' THEN v_category := 'booking_confirmations';
        WHEN 'booking_cancelled' THEN v_category := 'booking_cancellations';
        WHEN 'booking_modified' THEN v_category := 'booking_modifications';
        WHEN 'rental_active' THEN v_category := 'booking_confirmations';
        WHEN 'rental_completed' THEN v_category := 'booking_confirmations';
        WHEN 'payment_success' THEN v_category := 'payment_success';
        WHEN 'payment_failed' THEN v_category := 'payment_failed';
        WHEN 'vehicle_available' THEN v_category := 'feature_announcements';
        ELSE v_category := 'feature_announcements';
    END CASE;

    -- Check if user has this notification type enabled
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'notification_preferences'
    ) THEN
        SELECT is_enabled INTO v_is_enabled
        FROM public.notification_preferences
        WHERE user_id = p_user_id AND category::TEXT = v_category
        LIMIT 1;

        -- Default to true if no preference found
        IF v_is_enabled IS NULL THEN
            v_is_enabled := true;
        END IF;
    END IF;

    -- Only create notification if enabled
    IF v_is_enabled THEN
        INSERT INTO public.app_notifications (
            user_id, notification_type, title, body, reference_id, reference_table
        ) VALUES (
            p_user_id, p_notification_type, p_title, p_body, p_reference_id, p_reference_table
        )
        RETURNING id INTO v_notification_id;
    END IF;

    RETURN v_notification_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Failed to create notification: %', SQLERRM;
        RETURN NULL;
END;
$func$;

-- 7. Trigger function for reservation status changes
CREATE OR REPLACE FUNCTION public.notify_on_reservation_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_user_id UUID;
    v_notification_type public.app_notification_type;
    v_title TEXT;
    v_body TEXT;
BEGIN
    -- Try to find user_id from user_profiles by customer_email
    IF EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'user_profiles'
    ) THEN
        SELECT id INTO v_user_id
        FROM public.user_profiles
        WHERE email = NEW.customer_email
        LIMIT 1;
    END IF;

    IF v_user_id IS NULL THEN
        RETURN NEW;
    END IF;

    -- Determine notification type based on status change
    IF TG_OP = 'INSERT' THEN
        v_notification_type := 'booking_confirmed';
        v_title := 'Booking Confirmed';
        v_body := 'Your booking for ' || NEW.customer_name || ' has been confirmed.';
    ELSIF TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status THEN
        CASE NEW.status::TEXT
            WHEN 'confirmed' THEN
                v_notification_type := 'booking_confirmed';
                v_title := 'Booking Confirmed';
                v_body := 'Your rental booking has been confirmed and is ready.';
            WHEN 'active' THEN
                v_notification_type := 'rental_active';
                v_title := 'Rental Started';
                v_body := 'Your rental is now active. Enjoy your ride!';
            WHEN 'completed' THEN
                v_notification_type := 'rental_completed';
                v_title := 'Rental Completed';
                v_body := 'Your rental has been completed. Thank you for choosing us!';
            WHEN 'cancelled' THEN
                v_notification_type := 'booking_cancelled';
                v_title := 'Booking Cancelled';
                v_body := 'Your booking has been cancelled.';
            ELSE
                RETURN NEW;
        END CASE;
    ELSE
        RETURN NEW;
    END IF;

    PERFORM public.create_notification_if_enabled(
        v_user_id,
        v_notification_type,
        v_title,
        v_body,
        NEW.id,
        'reservations'
    );

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Reservation notification trigger failed: %', SQLERRM;
        RETURN NEW;
END;
$func$;

-- 8. Trigger function for vehicle availability changes
CREATE OR REPLACE FUNCTION public.notify_on_vehicle_availability()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    v_user_record RECORD;
BEGIN
    -- Only notify when vehicle becomes available
    IF TG_OP = 'UPDATE' THEN
        -- Check if is_available column exists and changed to true
        IF OLD.is_available = false AND NEW.is_available = true THEN
            -- Notify all users who have vehicle_available notifications enabled
            IF EXISTS (
                SELECT 1 FROM information_schema.tables
                WHERE table_schema = 'public' AND table_name = 'user_profiles'
            ) THEN
                FOR v_user_record IN
                    SELECT up.id
                    FROM public.user_profiles up
                    WHERE EXISTS (
                        SELECT 1 FROM public.notification_preferences np
                        WHERE np.user_id = up.id
                        AND np.category::TEXT = 'feature_announcements'
                        AND np.is_enabled = true
                    )
                    LIMIT 50
                LOOP
                    PERFORM public.create_notification_if_enabled(
                        v_user_record.id,
                        'vehicle_available'::public.app_notification_type,
                        'Vehicle Now Available',
                        NEW.name || ' (' || COALESCE(NEW.license_plate, 'N/A') || ') is now available for rental.',
                        NEW.id,
                        'vehicles'
                    );
                END LOOP;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Vehicle availability notification trigger failed: %', SQLERRM;
        RETURN NEW;
END;
$func$;

-- 9. Create triggers on reservations table
DROP TRIGGER IF EXISTS trigger_notify_reservation_change ON public.reservations;
CREATE TRIGGER trigger_notify_reservation_change
    AFTER INSERT OR UPDATE ON public.reservations
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_on_reservation_change();

-- 10. Create trigger on vehicles table (only if is_available column exists)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
        AND table_name = 'vehicles'
        AND column_name = 'is_available'
    ) THEN
        DROP TRIGGER IF EXISTS trigger_notify_vehicle_availability ON public.vehicles;
        CREATE TRIGGER trigger_notify_vehicle_availability
            AFTER UPDATE ON public.vehicles
            FOR EACH ROW
            EXECUTE FUNCTION public.notify_on_vehicle_availability();
    END IF;
END $$;
