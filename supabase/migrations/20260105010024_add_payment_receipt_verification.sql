-- Location: supabase/migrations/20260105010024_add_payment_receipt_verification.sql
-- Schema Analysis: Existing payment_transactions table with payment tracking
-- Integration Type: Extension - adding receipt verification fields
-- Dependencies: payment_transactions, payment_status enum

-- Add receipt verification columns to payment_transactions
ALTER TABLE public.payment_transactions
ADD COLUMN IF NOT EXISTS receipt_url TEXT,
ADD COLUMN IF NOT EXISTS receipt_uploaded_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS verification_notes TEXT,
ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS verified_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL;

-- Add index for receipt verification queries
CREATE INDEX IF NOT EXISTS idx_payment_transactions_receipt_uploaded 
ON public.payment_transactions(receipt_uploaded_at) 
WHERE receipt_url IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_payment_transactions_verified_at 
ON public.payment_transactions(verified_at);

-- Create function to notify on payment status changes
CREATE OR REPLACE FUNCTION public.notify_payment_status_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Notify when payment status changes to processing or completed
    IF (TG_OP = 'UPDATE' AND NEW.payment_status != OLD.payment_status) THEN
        PERFORM pg_notify(
            'payment_status_change',
            json_build_object(
                'transaction_id', NEW.id,
                'reservation_id', NEW.reservation_id,
                'user_id', NEW.user_id,
                'old_status', OLD.payment_status,
                'new_status', NEW.payment_status,
                'receipt_url', NEW.receipt_url,
                'verification_notes', NEW.verification_notes,
                'timestamp', NOW()
            )::text
        );
    END IF;
    
    -- Notify when receipt is uploaded
    IF (TG_OP = 'UPDATE' AND NEW.receipt_url IS NOT NULL AND OLD.receipt_url IS NULL) THEN
        PERFORM pg_notify(
            'payment_receipt_uploaded',
            json_build_object(
                'transaction_id', NEW.id,
                'reservation_id', NEW.reservation_id,
                'user_id', NEW.user_id,
                'receipt_url', NEW.receipt_url,
                'timestamp', NOW()
            )::text
        );
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create trigger for payment status notifications
DROP TRIGGER IF EXISTS trigger_notify_payment_status_change ON public.payment_transactions;
CREATE TRIGGER trigger_notify_payment_status_change
    AFTER UPDATE ON public.payment_transactions
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_payment_status_change();

-- Function to update payment with receipt
CREATE OR REPLACE FUNCTION public.update_payment_receipt(
    transaction_uuid UUID,
    receipt_image_url TEXT
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.payment_transactions
    SET 
        receipt_url = receipt_image_url,
        receipt_uploaded_at = NOW(),
        payment_status = 'processing'::public.payment_status
    WHERE id = transaction_uuid
    AND user_id = auth.uid();
END;
$$;

-- Function to verify payment receipt (admin only)
CREATE OR REPLACE FUNCTION public.verify_payment_receipt(
    transaction_uuid UUID,
    verification_note TEXT,
    is_approved BOOLEAN
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Check if user is admin
    IF NOT EXISTS (
        SELECT 1 FROM public.admin_roles ar
        WHERE ar.user_id = auth.uid() 
        AND ar.is_active = true
    ) THEN
        RAISE EXCEPTION 'Only administrators can verify payment receipts';
    END IF;
    
    UPDATE public.payment_transactions
    SET 
        verification_notes = verification_note,
        verified_at = NOW(),
        verified_by = auth.uid(),
        payment_status = CASE 
            WHEN is_approved THEN 'completed'::public.payment_status
            ELSE 'failed'::public.payment_status
        END
    WHERE id = transaction_uuid;
    
    -- Update reservation status if payment is completed
    IF is_approved THEN
        UPDATE public.reservations
        SET status = 'confirmed'::public.reservation_status
        WHERE id = (
            SELECT reservation_id 
            FROM public.payment_transactions 
            WHERE id = transaction_uuid
        );
    END IF;
END;
$$;

-- Add RLS policy for receipt upload
CREATE POLICY "users_can_upload_own_receipts"
ON public.payment_transactions
FOR UPDATE
TO authenticated
USING (user_id = auth.uid() AND receipt_url IS NULL)
WITH CHECK (user_id = auth.uid());

-- Add RLS policy for admin receipt verification
CREATE POLICY "admins_can_verify_receipts"
ON public.payment_transactions
FOR UPDATE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.admin_roles ar
        WHERE ar.user_id = auth.uid() 
        AND ar.is_active = true
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.admin_roles ar
        WHERE ar.user_id = auth.uid() 
        AND ar.is_active = true
    )
);