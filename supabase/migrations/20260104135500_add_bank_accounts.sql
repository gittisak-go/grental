-- Location: supabase/migrations/20260104135500_add_bank_accounts.sql
-- Schema Analysis: Existing reservations and vehicles tables
-- Integration Type: Addition (NEW_MODULE)
-- Dependencies: None (standalone bank information table)

-- Create bank accounts table for payment information
CREATE TABLE public.bank_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bank_name TEXT NOT NULL,
    account_number TEXT NOT NULL,
    account_name TEXT NOT NULL,
    branch TEXT,
    account_type TEXT DEFAULT 'savings',
    is_active BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create rental terms table
CREATE TABLE public.rental_terms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX idx_bank_accounts_is_active ON public.bank_accounts(is_active);
CREATE INDEX idx_rental_terms_category ON public.rental_terms(category);
CREATE INDEX idx_rental_terms_display_order ON public.rental_terms(display_order);

-- Enable RLS
ALTER TABLE public.bank_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rental_terms ENABLE ROW LEVEL SECURITY;

-- RLS policies - Public read access for bank info and terms
CREATE POLICY "public_can_read_bank_accounts"
ON public.bank_accounts
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "public_can_read_rental_terms"
ON public.rental_terms
FOR SELECT
TO public
USING (is_active = true);

-- Auto-update timestamp trigger
CREATE OR REPLACE FUNCTION public.update_bank_accounts_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_update_bank_accounts_updated_at
BEFORE UPDATE ON public.bank_accounts
FOR EACH ROW
EXECUTE FUNCTION public.update_bank_accounts_updated_at();

CREATE OR REPLACE FUNCTION public.update_rental_terms_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_update_rental_terms_updated_at
BEFORE UPDATE ON public.rental_terms
FOR EACH ROW
EXECUTE FUNCTION public.update_rental_terms_updated_at();

-- Insert bank account data (Rungroj Car Rental)
DO $$
BEGIN
    INSERT INTO public.bank_accounts (bank_name, account_number, account_name, branch, account_type, notes)
    VALUES
        ('ธนาคารกสิกรไทย', '123-4-56789-0', 'บริษัท รุ่งโรจน์คาร์เร้นท์ จำกัด', 'สาขาอุดรธานี', 'ออมทรัพย์', 'บัญชีหลักสำหรับการชำระค่าเช่ารถ'),
        ('ธนาคารไทยพาณิชย์', '987-6-54321-0', 'บริษัท รุ่งโรจน์คาร์เร้นท์ จำกัด', 'สาขาอุดรธานี', 'กระแสรายวัน', 'บัญชีสำรอง');
END $$;

-- Insert rental terms and conditions
DO $$
BEGIN
    INSERT INTO public.rental_terms (title, content, category, display_order)
    VALUES
        ('ไม่ต้องมีบัตรเครดิต', 'เช่ารถกับเราง่ายๆ ไม่ต้องมีบัตรเครดิต เพียงแค่มีบัตรประชาชนและใบขับขี่', 'highlight', 1),
        ('รับ-ส่งฟรีถึงมือ', 'บริการรับ-ส่งรถฟรีทั้งสนามบินอุดรธานี และในตัวเมือง สะดวก รวดเร็ว ไม่ต้องรอนาน', 'highlight', 2),
        ('รถใหม่ สะอาด มั่นใจ', 'รถทุกคันผ่านการตรวจเช็คอย่างละเอียดก่อนส่งมอบ แอร์เย็นฉ่ำ พร้อมลุยทุกเส้นทาง', 'highlight', 3),
        ('บริการด้วยใจ', 'ทีมงานใจดี พร้อมให้คำปรึกษา ตอบทุกคำถาม บริการตลอด 24 ชั่วโมง', 'highlight', 4),
        ('เงื่อนไขการชำระเงิน', 'ชำระเงินมัดจำ 30% เมื่อจองรถ ชำระส่วนที่เหลือเมื่อรับรถ รับชำระเงินสด หรือโอนเข้าบัญชี', 'payment', 5),
        ('ค่ามัดจำความเสียหาย', 'มัดจำความเสียหาย 3,000 บาท (คืนเต็มจำนวนหากไม่มีความเสียหาย)', 'deposit', 6),
        ('เชื้อเพลิง', 'ส่งมอบรถพร้อมน้ำมันเต็มถัง คืนรถเต็มถัง หรือชำระค่าเติมเต็มตามที่ใช้', 'fuel', 7),
        ('การยกเลิก', 'ยกเลิกก่อน 48 ชม. คืนเงินมัดจำเต็มจำนวน ยกเลิกภายใน 48 ชม. หักค่าบริการ 500 บาท', 'cancellation', 8);
END $$;