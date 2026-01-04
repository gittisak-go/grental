-- Create vehicles table for car rental management
CREATE TABLE IF NOT EXISTS public.vehicles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    year INTEGER NOT NULL CHECK (year >= 1900 AND year <= EXTRACT(YEAR FROM CURRENT_DATE) + 1),
    price_per_day DECIMAL(10, 2) NOT NULL CHECK (price_per_day > 0),
    transmission TEXT NOT NULL CHECK (transmission IN ('Manual', 'Automatic', 'Semi-Automatic')),
    seats INTEGER NOT NULL CHECK (seats >= 2 AND seats <= 12),
    fuel_type TEXT NOT NULL CHECK (fuel_type IN ('Petrol', 'Diesel', 'Electric', 'Hybrid')),
    image_url TEXT NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_vehicles_brand ON public.vehicles(brand);
CREATE INDEX IF NOT EXISTS idx_vehicles_is_available ON public.vehicles(is_available);
CREATE INDEX IF NOT EXISTS idx_vehicles_price ON public.vehicles(price_per_day);
CREATE INDEX IF NOT EXISTS idx_vehicles_created_at ON public.vehicles(created_at DESC);

-- Enable Row Level Security
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users (admins)
CREATE POLICY "Allow authenticated users to read vehicles"
    ON public.vehicles
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Allow authenticated users to insert vehicles"
    ON public.vehicles
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "Allow authenticated users to update vehicles"
    ON public.vehicles
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow authenticated users to delete vehicles"
    ON public.vehicles
    FOR DELETE
    TO authenticated
    USING (true);

-- Create policy for anonymous users (public read-only)
CREATE POLICY "Allow anonymous users to read available vehicles"
    ON public.vehicles
    FOR SELECT
    TO anon
    USING (is_available = true);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_vehicles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function before update
CREATE TRIGGER trigger_update_vehicles_updated_at
    BEFORE UPDATE ON public.vehicles
    FOR EACH ROW
    EXECUTE FUNCTION public.update_vehicles_updated_at();

-- Insert sample vehicles data
INSERT INTO public.vehicles (brand, model, year, price_per_day, transmission, seats, fuel_type, image_url, is_available, description) VALUES
('Toyota', 'Camry', 2023, 1500.00, 'Automatic', 5, 'Hybrid', 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800', true, 'Comfortable sedan perfect for business trips and family outings'),
('Honda', 'Civic', 2022, 1200.00, 'Manual', 5, 'Petrol', 'https://images.unsplash.com/photo-1590362891991-f776e747a588?w=800', true, 'Sporty and fuel-efficient compact car'),
('BMW', '3 Series', 2023, 2500.00, 'Automatic', 5, 'Diesel', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800', true, 'Luxury sedan with premium features and performance'),
('Mercedes-Benz', 'E-Class', 2023, 3000.00, 'Automatic', 5, 'Hybrid', 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800', true, 'Executive class vehicle with advanced technology'),
('Mazda', 'CX-5', 2022, 1800.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1617531653520-bd4f396a4e01?w=800', true, 'Stylish SUV with excellent handling'),
('Ford', 'Ranger', 2023, 2200.00, 'Manual', 5, 'Diesel', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800', true, 'Powerful pickup truck for adventures'),
('Tesla', 'Model 3', 2023, 2800.00, 'Automatic', 5, 'Electric', 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800', true, 'Cutting-edge electric vehicle with autopilot'),
('Nissan', 'Altima', 2022, 1400.00, 'Automatic', 5, 'Petrol', 'https://images.unsplash.com/photo-1542362567-b07e54358753?w=800', true, 'Reliable mid-size sedan'),
('Hyundai', 'Tucson', 2023, 1600.00, 'Automatic', 5, 'Hybrid', 'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?w=800', true, 'Modern compact SUV with great features'),
('Volkswagen', 'Passat', 2022, 1700.00, 'Automatic', 5, 'Diesel', 'https://images.unsplash.com/photo-1622116211883-e6f5d1ca4dd4?w=800', false, 'European elegance and comfort');

COMMENT ON TABLE public.vehicles IS 'Stores vehicle information for car rental management system';
COMMENT ON COLUMN public.vehicles.brand IS 'Vehicle brand/manufacturer';
COMMENT ON COLUMN public.vehicles.model IS 'Vehicle model name';
COMMENT ON COLUMN public.vehicles.year IS 'Manufacturing year';
COMMENT ON COLUMN public.vehicles.price_per_day IS 'Daily rental price in Thai Baht';
COMMENT ON COLUMN public.vehicles.transmission IS 'Transmission type: Manual, Automatic, or Semi-Automatic';
COMMENT ON COLUMN public.vehicles.seats IS 'Number of seats (2-12)';
COMMENT ON COLUMN public.vehicles.fuel_type IS 'Fuel type: Petrol, Diesel, Electric, or Hybrid';
COMMENT ON COLUMN public.vehicles.image_url IS 'URL to vehicle image';
COMMENT ON COLUMN public.vehicles.is_available IS 'Availability status for rental';
COMMENT ON COLUMN public.vehicles.description IS 'Additional vehicle description';