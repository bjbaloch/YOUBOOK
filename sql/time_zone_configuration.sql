-- =========================================
--  YOUBOOK Time Zone Configuration
--  Automatic time zone handling for the app
--  Fixes "isoweek" and other timestamp issues
-- =========================================

-- =========================================
--  1. TIME ZONE SETUP
-- =========================================

-- Set default timezone for the database session
-- This ensures consistent time zone handling across all queries
SET timezone = 'Asia/Karachi';

-- Alternative: Use UTC as base but provide conversion functions
-- SET timezone = 'UTC';

-- =========================================
--  2. TIME ZONE UTILITY FUNCTIONS
-- =========================================

-- Function to get current timestamp in app timezone
CREATE OR REPLACE FUNCTION public.now_in_app_timezone()
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
    RETURN NOW() AT TIME ZONE 'Asia/Karachi';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to convert timestamp to app timezone
CREATE OR REPLACE FUNCTION public.to_app_timezone(ts TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
    RETURN ts AT TIME ZONE 'Asia/Karachi';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to convert timestamp from app timezone to UTC
CREATE OR REPLACE FUNCTION public.from_app_timezone(ts TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
    RETURN ts AT TIME ZONE 'UTC';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =========================================
--  3. DATE EXTRACTION FUNCTIONS (TIME ZONE AWARE)
-- =========================================

-- Function to extract ISO week from timestamp (time zone aware)
CREATE OR REPLACE FUNCTION public.extract_isoweek(ts TIMESTAMP WITH TIME ZONE)
RETURNS INTEGER AS $$
BEGIN
    -- Convert to app timezone first, then extract ISO week
    RETURN EXTRACT(ISOWEEK FROM ts AT TIME ZONE 'Asia/Karachi');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to extract ISO year from timestamp (time zone aware)
CREATE OR REPLACE FUNCTION public.extract_isoyear(ts TIMESTAMP WITH TIME ZONE)
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(ISOYEAR FROM ts AT TIME ZONE 'Asia/Karachi');
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to get start of ISO week for a timestamp
CREATE OR REPLACE FUNCTION public.isoweek_start(ts TIMESTAMP WITH TIME ZONE)
RETURNS DATE AS $$
DECLARE
    app_ts TIMESTAMP WITH TIME ZONE;
BEGIN
    app_ts := ts AT TIME ZONE 'Asia/Karachi';
    RETURN DATE_TRUNC('week', app_ts)::DATE - INTERVAL '1 day' * ((EXTRACT(DOW FROM app_ts) + 6) % 7);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to get end of ISO week for a timestamp
CREATE OR REPLACE FUNCTION public.isoweek_end(ts TIMESTAMP WITH TIME ZONE)
RETURNS DATE AS $$
BEGIN
    RETURN public.isoweek_start(ts) + INTERVAL '6 days';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =========================================
--  4. SCHEDULE TIME FUNCTIONS
-- =========================================

-- Function to get schedules for current ISO week
CREATE OR REPLACE FUNCTION public.get_schedules_current_isoweek()
RETURNS TABLE (
    id UUID,
    vehicle_id UUID,
    route_id UUID,
    departure_time TIMESTAMP WITH TIME ZONE,
    arrival_time TIMESTAMP WITH TIME ZONE,
    travel_date DATE,
    base_fare DECIMAL(8,2),
    available_seats INTEGER,
    status schedule_status
) AS $$
DECLARE
    week_start DATE;
    week_end DATE;
BEGIN
    week_start := public.isoweek_start(NOW());
    week_end := public.isoweek_end(NOW());

    RETURN QUERY
    SELECT
        s.id,
        s.vehicle_id,
        s.route_id,
        s.departure_time,
        s.arrival_time,
        s.travel_date,
        s.base_fare,
        s.available_seats,
        s.status
    FROM public.schedules s
    WHERE s.travel_date BETWEEN week_start AND week_end
      AND s.is_active = true
    ORDER BY s.departure_time;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get schedules by ISO week number and year
CREATE OR REPLACE FUNCTION public.get_schedules_by_isoweek(week_num INTEGER, year_num INTEGER)
RETURNS TABLE (
    id UUID,
    vehicle_id UUID,
    route_id UUID,
    departure_time TIMESTAMP WITH TIME ZONE,
    arrival_time TIMESTAMP WITH TIME ZONE,
    travel_date DATE,
    base_fare DECIMAL(8,2),
    available_seats INTEGER,
    status schedule_status
) AS $$
DECLARE
    target_date DATE;
BEGIN
    -- Calculate a date in the target ISO week
    target_date := DATE_TRUNC('year', MAKE_DATE(year_num, 1, 4))::DATE +
                   INTERVAL '1 day' * ((week_num - 1) * 7 - EXTRACT(DOW FROM DATE_TRUNC('year', MAKE_DATE(year_num, 1, 4)))::INTEGER + 1);

    RETURN QUERY
    SELECT
        s.id,
        s.vehicle_id,
        s.route_id,
        s.departure_time,
        s.arrival_time,
        s.travel_date,
        s.base_fare,
        s.available_seats,
        s.status
    FROM public.schedules s
    WHERE s.travel_date >= public.isoweek_start(target_date::TIMESTAMP WITH TIME ZONE)
      AND s.travel_date <= public.isoweek_end(target_date::TIMESTAMP WITH TIME ZONE)
      AND s.is_active = true
    ORDER BY s.departure_time;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================
--  5. BOOKING TIME FUNCTIONS
-- =========================================

-- Function to get bookings for current ISO week
CREATE OR REPLACE FUNCTION public.get_bookings_current_isoweek()
RETURNS TABLE (
    id UUID,
    passenger_id UUID,
    schedule_id UUID,
    travel_date DATE,
    total_price DECIMAL(8,2),
    status booking_status,
    booking_date TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    week_start DATE;
    week_end DATE;
BEGIN
    week_start := public.isoweek_start(NOW());
    week_end := public.isoweek_end(NOW());

    RETURN QUERY
    SELECT
        b.id,
        b.passenger_id,
        b.schedule_id,
        b.travel_date,
        b.total_price,
        b.status,
        b.booking_date
    FROM public.bookings b
    WHERE b.travel_date BETWEEN week_start AND week_end
    ORDER BY b.booking_date DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================
--  6. ANALYTICS FUNCTIONS WITH TIME ZONES
-- =========================================

-- Function to get weekly booking analytics
CREATE OR REPLACE FUNCTION public.get_weekly_booking_analytics(weeks_back INTEGER DEFAULT 0)
RETURNS TABLE (
    isoweek INTEGER,
    isoyear INTEGER,
    week_start DATE,
    week_end DATE,
    total_bookings BIGINT,
    total_revenue DECIMAL(10,2),
    confirmed_bookings BIGINT,
    cancelled_bookings BIGINT
) AS $$
DECLARE
    target_date DATE;
BEGIN
    -- Calculate target date (current date minus weeks)
    target_date := CURRENT_DATE - INTERVAL '7 days' * weeks_back;

    RETURN QUERY
    SELECT
        public.extract_isoweek(b.booking_date) as isoweek,
        public.extract_isoyear(b.booking_date) as isoyear,
        public.isoweek_start(b.booking_date) as week_start,
        public.isoweek_end(b.booking_date) as week_end,
        COUNT(*) as total_bookings,
        COALESCE(SUM(b.total_price), 0) as total_revenue,
        COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
        COUNT(CASE WHEN b.status = 'cancelled' THEN 1 END) as cancelled_bookings
    FROM public.bookings b
    WHERE b.booking_date >= public.isoweek_start(target_date::TIMESTAMP WITH TIME ZONE)
      AND b.booking_date < public.isoweek_start((target_date + INTERVAL '7 days')::TIMESTAMP WITH TIME ZONE)
    GROUP BY
        public.extract_isoweek(b.booking_date),
        public.extract_isoyear(b.booking_date),
        public.isoweek_start(b.booking_date),
        public.isoweek_end(b.booking_date)
    ORDER BY isoyear DESC, isoweek DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =========================================
--  7. TRIGGER FOR AUTOMATIC TIME ZONE HANDLING
-- =========================================

-- Function to ensure timestamps are stored in UTC but queries work in app timezone
CREATE OR REPLACE FUNCTION public.handle_timestamp_timezone()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure created_at and updated_at are in UTC
    IF TG_OP = 'INSERT' THEN
        NEW.created_at := TIMEZONE('UTC', NEW.created_at);
        NEW.updated_at := TIMEZONE('UTC', NEW.updated_at);
    ELSIF TG_OP = 'UPDATE' THEN
        NEW.updated_at := TIMEZONE('UTC', NOW());
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================================
--  8. GRANT PERMISSIONS
-- =========================================

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION public.now_in_app_timezone() TO authenticated;
GRANT EXECUTE ON FUNCTION public.to_app_timezone(TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.from_app_timezone(TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.extract_isoweek(TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.extract_isoyear(TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.isoweek_start(TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.isoweek_end(TIMESTAMP WITH TIME ZONE) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_schedules_current_isoweek() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_schedules_by_isoweek(INTEGER, INTEGER) TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_bookings_current_isoweek() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_weekly_booking_analytics(INTEGER) TO authenticated;

-- =========================================
--  Time Zone Configuration Complete
-- =========================================
--  This file ensures all timestamp operations use proper time zones
--  and provides time zone-aware ISO week functions.
--
--  To use in your app:
--  - Call functions like public.extract_isoweek(timestamp_field)
--  - Use public.get_schedules_current_isoweek() for weekly queries
--  - All timestamps are stored in UTC but converted to Asia/Karachi for display
-- =========================================
