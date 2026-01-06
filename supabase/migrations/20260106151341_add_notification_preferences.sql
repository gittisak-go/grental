-- Location: supabase/migrations/20260106151341_add_notification_preferences.sql
-- Schema Analysis: Existing user_profiles, reservations, payment_transactions tables
-- Integration Type: Addition - New notification preferences module
-- Dependencies: user_profiles table

-- 1. Create notification category enum
CREATE TYPE public.notification_category AS ENUM (
    'booking_confirmations',
    'booking_modifications',
    'booking_cancellations',
    'payment_success',
    'payment_failed',
    'payment_refunds',
    'driver_arrival',
    'driver_pickup',
    'driver_route_updates',
    'marketing_offers',
    'marketing_promotions',
    'feature_announcements'
);

-- 2. Create notification delivery method enum
CREATE TYPE public.notification_delivery_method AS ENUM ('push', 'sms', 'email');

-- 3. Create notification_preferences table
CREATE TABLE public.notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE NOT NULL,
    category public.notification_category NOT NULL,
    is_enabled BOOLEAN DEFAULT true NOT NULL,
    delivery_methods public.notification_delivery_method[] DEFAULT ARRAY['push']::public.notification_delivery_method[],
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE(user_id, category)
);

-- 4. Create indexes
CREATE INDEX idx_notification_preferences_user_id ON public.notification_preferences(user_id);
CREATE INDEX idx_notification_preferences_category ON public.notification_preferences(category);
CREATE INDEX idx_notification_preferences_enabled ON public.notification_preferences(is_enabled);

-- 5. Enable RLS
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;

-- 6. Create RLS policies (Pattern 2: Simple User Ownership)
CREATE POLICY "users_manage_own_notification_preferences"
ON public.notification_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 7. Create trigger function for updated_at
CREATE OR REPLACE FUNCTION public.update_notification_preferences_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 8. Create trigger
CREATE TRIGGER set_notification_preferences_updated_at
    BEFORE UPDATE ON public.notification_preferences
    FOR EACH ROW
    EXECUTE FUNCTION public.update_notification_preferences_updated_at();

-- 9. Create function to initialize default preferences for new users
CREATE OR REPLACE FUNCTION public.initialize_notification_preferences()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Insert default notification preferences for all categories
    INSERT INTO public.notification_preferences (user_id, category, is_enabled, delivery_methods)
    VALUES
        (NEW.id, 'booking_confirmations'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
        (NEW.id, 'booking_modifications'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
        (NEW.id, 'booking_cancellations'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
        (NEW.id, 'payment_success'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
        (NEW.id, 'payment_failed'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
        (NEW.id, 'payment_refunds'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
        (NEW.id, 'driver_arrival'::public.notification_category, true, ARRAY['push']::public.notification_delivery_method[]),
        (NEW.id, 'driver_pickup'::public.notification_category, true, ARRAY['push']::public.notification_delivery_method[]),
        (NEW.id, 'driver_route_updates'::public.notification_category, true, ARRAY['push']::public.notification_delivery_method[]),
        (NEW.id, 'marketing_offers'::public.notification_category, false, ARRAY['email']::public.notification_delivery_method[]),
        (NEW.id, 'marketing_promotions'::public.notification_category, false, ARRAY['email']::public.notification_delivery_method[]),
        (NEW.id, 'feature_announcements'::public.notification_category, true, ARRAY['push']::public.notification_delivery_method[]);
    
    RETURN NEW;
END;
$$;

-- 10. Create trigger to auto-initialize preferences for new users
CREATE TRIGGER initialize_user_notification_preferences
    AFTER INSERT ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.initialize_notification_preferences();

-- 11. Mock data for existing users
DO $$
DECLARE
    existing_user_record RECORD;
BEGIN
    -- Initialize preferences for existing users who don't have them
    FOR existing_user_record IN 
        SELECT id FROM public.user_profiles
    LOOP
        -- Check if preferences already exist for this user
        IF NOT EXISTS (
            SELECT 1 FROM public.notification_preferences 
            WHERE user_id = existing_user_record.id
        ) THEN
            INSERT INTO public.notification_preferences (user_id, category, is_enabled, delivery_methods)
            VALUES
                (existing_user_record.id, 'booking_confirmations'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
                (existing_user_record.id, 'booking_modifications'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
                (existing_user_record.id, 'booking_cancellations'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
                (existing_user_record.id, 'payment_success'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
                (existing_user_record.id, 'payment_failed'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
                (existing_user_record.id, 'payment_refunds'::public.notification_category, true, ARRAY['push', 'email']::public.notification_delivery_method[]),
                (existing_user_record.id, 'driver_arrival'::public.notification_category, true, ARRAY['push']::public.notification_delivery_method[]),
                (existing_user_record.id, 'driver_pickup'::public.notification_category, true, ARRAY['push']::public.notification_delivery_method[]),
                (existing_user_record.id, 'driver_route_updates'::public.notification_category, true, ARRAY['push']::public.notification_delivery_method[]),
                (existing_user_record.id, 'marketing_offers'::public.notification_category, false, ARRAY['email']::public.notification_delivery_method[]),
                (existing_user_record.id, 'marketing_promotions'::public.notification_category, false, ARRAY['email']::public.notification_delivery_method[]),
                (existing_user_record.id, 'feature_announcements'::public.notification_category, true, ARRAY['push']::public.notification_delivery_method[]);
        END IF;
    END LOOP;
END $$;