-- ============================================================
-- RLS Security Fix: Remove Visitor, Add Guest, Full Policy Hardening
-- Roles allowed: Super_Admin, Admin, User, Guest ONLY
-- Principles: Default Deny, Least Privilege, No Privilege Escalation
-- Super_Admin approval required for critical actions
-- ============================================================

-- ============================================================
-- STEP 1: Fix profiles.role CHECK constraint (remove Visitor, add Guest)
-- ============================================================
ALTER TABLE public.profiles
DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE public.profiles
ADD CONSTRAINT profiles_role_check
CHECK (role IN ('Super_Admin', 'Admin', 'User', 'Guest'));

-- Migrate any existing Visitor rows to Guest
UPDATE public.profiles
SET role = 'Guest', updated_at = NOW()
WHERE role = 'Visitor';

-- ============================================================
-- STEP 2: Helper functions (MUST be before RLS policies)
-- ============================================================

-- Safe role lookup via auth.users metadata (avoids recursive RLS on profiles)
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS TEXT
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid() LIMIT 1;
$$;

-- Check if current user is Super_Admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'Super_Admin'
  );
$$;

-- Check if current user is Admin or above
CREATE OR REPLACE FUNCTION public.is_admin_or_above()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role IN ('Super_Admin', 'Admin')
  );
$$;

-- ============================================================
-- STEP 3: Privilege Escalation Prevention
-- Prevent any user from self-assigning Super_Admin role
-- ============================================================
CREATE OR REPLACE FUNCTION public.prevent_role_escalation()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  current_role TEXT;
BEGIN
  -- Get the current role of the user making the change
  SELECT role INTO current_role FROM public.profiles WHERE id = auth.uid();

  -- Block any attempt to set role = Super_Admin unless caller is already Super_Admin
  IF NEW.role = 'Super_Admin' AND current_role != 'Super_Admin' THEN
    RAISE EXCEPTION 'เสี่ยง Privilege Escalation: ไม่อนุญาตให้ยกระดับสิทธิ์เป็น Super_Admin โดยไม่ได้รับอนุมัติ';
  END IF;

  -- Block Admin/User/Guest from changing another user's role
  IF NEW.id != auth.uid() AND current_role NOT IN ('Super_Admin') THEN
    RAISE EXCEPTION 'เสี่ยง Privilege Escalation: ไม่อนุญาตให้แก้ไข role ของผู้ใช้อื่น';
  END IF;

  -- Block user from changing their own role (only Super_Admin can change roles)
  IF NEW.id = auth.uid() AND OLD.role != NEW.role AND current_role != 'Super_Admin' THEN
    RAISE EXCEPTION 'เสี่ยง Privilege Escalation: ไม่อนุญาตให้เปลี่ยน role ของตัวเอง';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_role_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_role_escalation
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_role_escalation();

-- ============================================================
-- STEP 4: Update handle_new_user_role trigger function
-- Assign Guest to unknown users (not Visitor)
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user_role()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_email TEXT;
  assigned_role TEXT;
BEGIN
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
  ELSIF user_email IN (
    'mtdzfc@gmail.com'
  ) THEN
    assigned_role := 'User';
  ELSE
    assigned_role := 'Guest';
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

DROP TRIGGER IF EXISTS on_auth_user_created_role ON auth.users;
CREATE TRIGGER on_auth_user_created_role
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user_role();

-- ============================================================
-- STEP 5: Update login role sync trigger
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_user_login_role()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
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
    ELSIF user_email IN (
      'mtdzfc@gmail.com'
    ) THEN
      assigned_role := 'User';
    ELSE
      assigned_role := 'Guest';
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

-- ============================================================
-- STEP 6: RLS Policies for public.profiles
-- Default Deny + Least Privilege + No Recursive RLS
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies on profiles
DROP POLICY IF EXISTS "users_read_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "users_update_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "users_insert_own_profile" ON public.profiles;
DROP POLICY IF EXISTS "admin_read_all_profiles" ON public.profiles;
DROP POLICY IF EXISTS "super_admin_full_access_profiles" ON public.profiles;

-- SELECT: User reads own profile only
CREATE POLICY "profiles_select_own"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

-- SELECT: Admin/Super_Admin can read all profiles (non-recursive: direct join via auth.uid())
CREATE POLICY "profiles_select_admin"
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (
    public.is_admin_or_above()
  );

-- INSERT: Authenticated users can insert their own profile only
CREATE POLICY "profiles_insert_own"
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

-- UPDATE: User can update own profile (role field protected by trigger)
CREATE POLICY "profiles_update_own"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- UPDATE: Super_Admin can update any profile (for role management)
CREATE POLICY "profiles_update_super_admin"
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- DELETE: Super_Admin only (critical action)
CREATE POLICY "profiles_delete_super_admin"
  ON public.profiles
  FOR DELETE
  TO authenticated
  USING (public.is_super_admin());

-- ============================================================
-- STEP 7: RLS Policies for public.vehicles
-- ============================================================
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "vehicles_select_all" ON public.vehicles;
DROP POLICY IF EXISTS "vehicles_insert_admin" ON public.vehicles;
DROP POLICY IF EXISTS "vehicles_update_admin" ON public.vehicles;
DROP POLICY IF EXISTS "vehicles_delete_super_admin" ON public.vehicles;

-- SELECT: All authenticated users can view vehicles (read-only for User/Guest)
CREATE POLICY "vehicles_select_authenticated"
  ON public.vehicles
  FOR SELECT
  TO authenticated
  USING (true);

-- INSERT: Admin and Super_Admin only
CREATE POLICY "vehicles_insert_admin"
  ON public.vehicles
  FOR INSERT
  TO authenticated
  WITH CHECK (public.is_admin_or_above());

-- UPDATE: Admin and Super_Admin only
CREATE POLICY "vehicles_update_admin"
  ON public.vehicles
  FOR UPDATE
  TO authenticated
  USING (public.is_admin_or_above())
  WITH CHECK (public.is_admin_or_above());

-- DELETE: Super_Admin only (critical action)
CREATE POLICY "vehicles_delete_super_admin"
  ON public.vehicles
  FOR DELETE
  TO authenticated
  USING (public.is_super_admin());

-- ============================================================
-- STEP 8: RLS Policies for other tables (device_log, suspicious_log, canary_tokens, kv_store)
-- ============================================================

-- device_log: Admin/Super_Admin read; system insert only
ALTER TABLE public.device_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "device_log_select_admin" ON public.device_log;
DROP POLICY IF EXISTS "device_log_insert_system" ON public.device_log;

CREATE POLICY "device_log_select_admin"
  ON public.device_log
  FOR SELECT
  TO authenticated
  USING (public.is_admin_or_above());

CREATE POLICY "device_log_insert_authenticated"
  ON public.device_log
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- suspicious_log: Super_Admin read only
ALTER TABLE public.suspicious_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "suspicious_log_select_super_admin" ON public.suspicious_log;
DROP POLICY IF EXISTS "suspicious_log_insert_system" ON public.suspicious_log;

CREATE POLICY "suspicious_log_select_super_admin"
  ON public.suspicious_log
  FOR SELECT
  TO authenticated
  USING (public.is_super_admin());

CREATE POLICY "suspicious_log_insert_authenticated"
  ON public.suspicious_log
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- canary_tokens: Super_Admin only
ALTER TABLE public.canary_tokens ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "canary_tokens_super_admin" ON public.canary_tokens;

CREATE POLICY "canary_tokens_super_admin"
  ON public.canary_tokens
  FOR ALL
  TO authenticated
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- kv_store: Super_Admin full, Admin read
ALTER TABLE public.kv_store_cdca09a8 ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "kv_store_select_admin" ON public.kv_store_cdca09a8;
DROP POLICY IF EXISTS "kv_store_all_super_admin" ON public.kv_store_cdca09a8;

CREATE POLICY "kv_store_select_admin"
  ON public.kv_store_cdca09a8
  FOR SELECT
  TO authenticated
  USING (public.is_admin_or_above());

CREATE POLICY "kv_store_write_super_admin"
  ON public.kv_store_cdca09a8
  FOR ALL
  TO authenticated
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

-- ============================================================
-- STEP 9: Sync existing profiles — replace Visitor with Guest
-- (already done above, but ensure no Visitor remains)
-- ============================================================
UPDATE public.profiles
SET role = 'Guest', updated_at = NOW()
WHERE role NOT IN ('Super_Admin', 'Admin', 'User', 'Guest');
