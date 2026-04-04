-- Update role system: Super_Admin, Admin, User roles with correct emails
-- Super_Admin: phongwut.w@gmail.com, gittisakwannakeeree@gmail.com
-- Admin: nongsandyza@gmail.com
-- User: mtdzfc@gmail.com and all others

-- Ensure profiles table exists
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    role TEXT NOT NULL DEFAULT 'User',
    full_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure role and email columns exist (idempotent)
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS role TEXT NOT NULL DEFAULT 'User';

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS email TEXT;

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();

-- Ensure role column supports Admin role
ALTER TABLE public.profiles
DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE public.profiles
ADD CONSTRAINT profiles_role_check
CHECK (role IN ('Super_Admin', 'Admin', 'User', 'Visitor'));

-- Index for role lookups
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);

-- Update the role assignment function with new email lists
CREATE OR REPLACE FUNCTION public.handle_new_user_role()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_email TEXT;
    assigned_role TEXT;
BEGIN
    user_email := LOWER(TRIM(NEW.email));

    -- Determine role based on email
    IF user_email IN (
        'phongwut.w@gmail.com',
        'gittisakwannakeeree@gmail.com'
    ) THEN
        assigned_role := 'Super_Admin';
    ELSIF user_email IN (
        'nongsandyza@gmail.com'
    ) THEN
        assigned_role := 'Admin';
    ELSE
        assigned_role := 'User';
    END IF;

    INSERT INTO public.profiles (id, email, role, created_at, updated_at)
    VALUES (NEW.id, user_email, assigned_role, NOW(), NOW())
    ON CONFLICT (id) DO UPDATE
        SET
            email = EXCLUDED.email,
            role = EXCLUDED.role,
            updated_at = NOW();

    RETURN NEW;
END;
$$;

-- Drop existing trigger if any, then create new one
DROP TRIGGER IF EXISTS on_auth_user_created_role ON auth.users;
CREATE TRIGGER on_auth_user_created_role
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user_role();

-- Update login role function
CREATE OR REPLACE FUNCTION public.handle_user_login_role()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    user_email TEXT;
    assigned_role TEXT;
BEGIN
    IF NEW.email_confirmed_at IS NOT NULL AND OLD.email_confirmed_at IS NULL THEN
        user_email := LOWER(TRIM(NEW.email));

        IF user_email IN (
            'phongwut.w@gmail.com',
            'gittisakwannakeeree@gmail.com'
        ) THEN
            assigned_role := 'Super_Admin';
        ELSIF user_email IN (
            'nongsandyza@gmail.com'
        ) THEN
            assigned_role := 'Admin';
        ELSE
            assigned_role := 'User';
        END IF;

        INSERT INTO public.profiles (id, email, role, created_at, updated_at)
        VALUES (NEW.id, user_email, assigned_role, NOW(), NOW())
        ON CONFLICT (id) DO UPDATE
            SET
                email = EXCLUDED.email,
                role = EXCLUDED.role,
                updated_at = NOW();
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_updated_role ON auth.users;
CREATE TRIGGER on_auth_user_updated_role
    AFTER UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_user_login_role();

-- Update existing known users' roles
UPDATE public.profiles
SET role = 'Super_Admin', updated_at = NOW()
WHERE email IN ('phongwut.w@gmail.com', 'gittisakwannakeeree@gmail.com');

UPDATE public.profiles
SET role = 'Admin', updated_at = NOW()
WHERE email IN ('nongsandyza@gmail.com');

UPDATE public.profiles
SET role = 'User', updated_at = NOW()
WHERE email IN ('mtdzfc@gmail.com');

-- RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_read_own_profile" ON public.profiles;
CREATE POLICY "users_read_own_profile"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (id = auth.uid());

DROP POLICY IF EXISTS "users_update_own_profile" ON public.profiles;
CREATE POLICY "users_update_own_profile"
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

DROP POLICY IF EXISTS "users_insert_own_profile" ON public.profiles;
CREATE POLICY "users_insert_own_profile"
    ON public.profiles
    FOR INSERT
    TO authenticated
    WITH CHECK (id = auth.uid());

-- Add Admin read policy for profiles
DROP POLICY IF EXISTS "admin_read_all_profiles" ON public.profiles;
CREATE POLICY "admin_read_all_profiles"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (
        id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid()
            AND p.role IN ('Super_Admin', 'Admin')
        )
    );
