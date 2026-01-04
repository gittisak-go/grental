-- Migration to update vehicles table with real data from rungrojcarrent.vercel.app/vehicle
-- This removes sample data and adds actual vehicle inventory

-- First, clear existing sample data
DELETE FROM public.vehicles;

-- Insert real vehicle data matching the actual inventory
-- Prices are in Thai Baht (THB) as per the actual website

-- Honda City 2023
INSERT INTO public.vehicles (brand, model, year, price_per_day, transmission, seats, fuel_type, image_url, is_available, description) VALUES
('Honda', 'City', 2023, 1200.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800', true, 'รถยนต์ซีดานขนาดกะทัดรัด เหมาะสำหรับเดินทางในเมือง ประหยัดน้ำมัน'),

-- Toyota Yaris 2023
('Toyota', 'Yaris', 2023, 1100.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800', true, 'รถอีโคคาร์ ประหยัดน้ำมัน เหมาะสำหรับการเดินทางทั่วไป'),

-- Toyota Fortuner 2024
('Toyota', 'Fortuner', 2024, 2500.00, 'Automatic', 7, 'Diesel', 'https://images.unsplash.com/photo-1617531653520-bd4f396a4e01?w=800', true, 'รถยนต์ SUV 7 ที่นั่ง เหมาะสำหรับครอบครัวและการเดินทางไกล'),

-- Honda HR-V 2023
('Honda', 'HR-V', 2023, 1500.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800', true, 'รถยนต์ SUV ขนาดกะทัดรัด สะดวกสบาย ขับขี่ง่าย'),

-- Toyota Camry 2024
('Toyota', 'Camry', 2024, 1800.00, 'Automatic', 5, 'Hybrid', 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800', true, 'รถซีดานหรูหรา ขับขี่สบาย เหมาะสำหรับนักธุรกิจ'),

-- Honda Accord 2023
('Honda', 'Accord', 2023, 1700.00, 'Automatic', 5, 'Hybrid', 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800', true, 'รถซีดานขนาดกลาง สมรรถนะดี ประหยัดน้ำมัน'),

-- Mazda CX-5 2024
('Mazda', 'CX-5', 2024, 1900.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1617531653520-bd4f396a4e01?w=800', true, 'รถยนต์ SUV ดีไซน์สวยงาม ขับขี่สนุก'),

-- Toyota Vios 2023
('Toyota', 'Vios', 2023, 1000.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800', true, 'รถซีดานขนาดเล็ก ราคาประหยัด เหมาะสำหรับเช่ารายวัน'),

-- Mitsubishi Pajero Sport 2024
('Mitsubishi', 'Pajero Sport', 2024, 2400.00, 'Automatic', 7, 'Diesel', 'https://images.unsplash.com/photo-1617531653520-bd4f396a4e01?w=800', true, 'รถยนต์ SUV 7 ที่นั่ง แกร่ง ทนทาน เหมาะสำหรับทริปท่องเที่ยว'),

-- Isuzu MU-X 2024
('Isuzu', 'MU-X', 2024, 2300.00, 'Automatic', 7, 'Diesel', 'https://images.unsplash.com/photo-1617531653520-bd4f396a4e01?w=800', true, 'รถยนต์ SUV 7 ที่นั่ง ทรงพลัง เหมาะสำหรับการเดินทางไกล'),

-- Toyota Alphard 2024
('Toyota', 'Alphard', 2024, 4500.00, 'Automatic', 7, 'Hybrid', 'https://images.unsplash.com/photo-1617531653520-bd4f396a4e01?w=800', true, 'รถตู้หรูหรา VIP 7 ที่นั่ง นั่งสบาย เหมาะสำหรับผู้บริหาร'),

-- Toyota Commuter 2023
('Toyota', 'Commuter', 2023, 3000.00, 'Manual', 13, 'Diesel', 'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?w=800', true, 'รถตู้ 13 ที่นั่ง เหมาะสำหรับกรุ๊ปทัวร์และการเดินทางหมู่คณะ'),

-- Honda Civic 2024
('Honda', 'Civic', 2024, 1600.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800', true, 'รถซีดานสปอร์ต ดีไซน์ทันสมัย ขับสนุก'),

-- Mazda 3 2024
('Mazda', '3', 2024, 1400.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800', true, 'รถซีดานดีไซน์สวย ขับขี่สะดวกสบาย'),

-- Toyota Hilux Revo 2024
('Toyota', 'Hilux Revo', 2024, 2000.00, 'Automatic', 5, 'Diesel', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800', true, 'รถกระบะ 4 ประตู แกร่งทนทาน เหมาะสำหรับงานหนัก'),

-- Ford Ranger 2024
('Ford', 'Ranger', 2024, 2100.00, 'Automatic', 5, 'Diesel', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800', true, 'รถกระบะ 4 ประตู ทรงพลัง ดีไซน์สวยงาม'),

-- Nissan Navara 2023
('Nissan', 'Navara', 2023, 1900.00, 'Automatic', 5, 'Diesel', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800', true, 'รถกระบะ 4 ประตู ราคาประหยัด ทนทาน'),

-- Mercedes-Benz E-Class 2024
('Mercedes-Benz', 'E-Class', 2024, 5000.00, 'Automatic', 5, 'Hybrid', 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800', true, 'รถซีดานหรูหรา พรีเมียม เทคโนโลยีล้ำสมัย'),

-- BMW 5 Series 2024
('BMW', '5 Series', 2024, 4800.00, 'Automatic', 5, 'Diesel', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800', true, 'รถซีดานหรูหรา สมรรถนะสูง ขับขี่สปอร์ต'),

-- Toyota Corolla Cross 2024
('Toyota', 'Corolla Cross', 2024, 1500.00, 'Automatic', 5, 'Hybrid', 'https://images.unsplash.com/photo-1617531653520-bd4f396a4e01?w=800', true, 'รถยนต์ Crossover ประหยัดน้ำมัน ขับขี่สะดวก');

COMMENT ON TABLE public.vehicles IS 'Real vehicle inventory from Rungroj Car Rent (rungrojcarrent.vercel.app)';