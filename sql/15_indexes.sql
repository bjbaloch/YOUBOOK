 ==========================================
 0. SUPPORT: helper trigger functions
 ==========================================

 schedules: sync departure_date and departure_hour
-- CREATE OR REPLACE FUNCTION public._sync_schedules_datetime_cols()
-- RETURNS trigger
-- LANGUAGE plpgsql
-- SECURITY DEFINER
-- AS $$
-- BEGIN
--   IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
--     IF NEW.departure_time IS NOT NULL THEN
--       -- use UTC; change if needed
--       NEW.departure_date  := (NEW.departure_time AT TIME ZONE 'UTC')::date;
--       NEW.departure_hour  := EXTRACT(HOUR FROM (NEW.departure_time AT TIME ZONE 'UTC'))::smallint;
--     ELSE
--       NEW.departure_date := NULL;
--       NEW.departure_hour := NULL;
--     END IF;
--   END IF;
--   RETURN NEW;
-- END;
-- $$;

-- DROP TRIGGER IF EXISTS trg_sync_schedules_datetime_cols ON public.schedules;
-- CREATE TRIGGER trg_sync_schedules_datetime_cols
-- BEFORE INSERT OR UPDATE ON public.schedules
-- FOR EACH ROW EXECUTE FUNCTION public._sync_schedules_datetime_cols();

 bookings: sync booking_date_day and booking_week
-- CREATE OR REPLACE FUNCTION public._sync_bookings_date_cols()
-- RETURNS trigger
-- LANGUAGE plpgsql
-- SECURITY DEFINER
-- AS $$
-- BEGIN
--   IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
--     IF NEW.booking_date IS NOT NULL THEN
--       NEW.booking_date_day := (NEW.booking_date AT TIME ZONE 'UTC')::date;
--       -- ISO week number (1..53)
--       NEW.booking_week := EXTRACT(ISOWEEK FROM (NEW.booking_date AT TIME ZONE 'UTC'))::smallint;
--     ELSE
--       NEW.booking_date_day := NULL;
--       NEW.booking_week := NULL;
--     END IF;
--   END IF;
--   RETURN NEW;
-- END;
-- $$;

-- DROP TRIGGER IF EXISTS trg_sync_bookings_date_cols ON public.bookings;
-- CREATE TRIGGER trg_sync_bookings_date_cols
-- BEFORE INSERT OR UPDATE ON public.bookings
-- FOR EACH ROW EXECUTE FUNCTION public._sync_bookings_date_cols();

 schedules: sync travel_dow if you need DOW from travel_date
-- CREATE OR REPLACE FUNCTION public._sync_schedules_travel_dow()
-- RETURNS trigger
-- LANGUAGE plpgsql
-- SECURITY DEFINER
-- AS $$
-- BEGIN
--   IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
--     IF NEW.travel_date IS NOT NULL THEN
--       -- DOW: 0 (Sunday) - 6 (Saturday) per PostgreSQL EXTRACT(DOW ...)
--       NEW.travel_dow := EXTRACT(DOW FROM NEW.travel_date)::smallint;
--     ELSE
--       NEW.travel_dow := NULL;
--     END IF;
--   END IF;
--   RETURN NEW;
-- END;
-- $$;

-- DROP TRIGGER IF EXISTS trg_sync_schedules_travel_dow ON public.schedules;
-- CREATE TRIGGER trg_sync_schedules_travel_dow
-- BEFORE INSERT OR UPDATE ON public.schedules
-- FOR EACH ROW EXECUTE FUNCTION public._sync_schedules_travel_dow();

 bookings: sync travel_date_day if used (optional; included for parity)
-- CREATE OR REPLACE FUNCTION public._sync_bookings_travel_date_day()
-- RETURNS trigger
-- LANGUAGE plpgsql
-- SECURITY DEFINER
-- AS $$
-- BEGIN
--   IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
--     IF NEW.travel_date IS NOT NULL THEN
--       NEW.travel_date_day := NEW.travel_date::date;
--     ELSE
--       NEW.travel_date_day := NULL;
--     END IF;
--   END IF;
--   RETURN NEW;
-- END;
-- $$;

-- DROP TRIGGER IF EXISTS trg_sync_bookings_travel_date_day ON public.bookings;
-- CREATE TRIGGER trg_sync_bookings_travel_date_day
-- BEFORE INSERT OR UPDATE ON public.bookings
-- FOR EACH ROW EXECUTE FUNCTION public._sync_bookings_travel_date_day();


 ==========================================
 0b. Add materialized columns (if not exists) and populate
 ==========================================

 schedules materialized cols
-- ALTER TABLE public.schedules
--   ADD COLUMN IF NOT EXISTS departure_date date,
--   ADD COLUMN IF NOT EXISTS departure_hour smallint,
--   ADD COLUMN IF NOT EXISTS travel_dow smallint;

-- UPDATE public.schedules
-- SET departure_date = (departure_time AT TIME ZONE 'UTC')::date,
--     departure_hour = EXTRACT(HOUR FROM (departure_time AT TIME ZONE 'UTC'))::smallint,
--     travel_dow = EXTRACT(DOW FROM travel_date)::smallint
-- WHERE departure_time IS NOT NULL OR travel_date IS NOT NULL;

 bookings materialized cols
-- ALTER TABLE public.bookings
--   ADD COLUMN IF NOT EXISTS booking_date_day date,
--   ADD COLUMN IF NOT EXISTS booking_week smallint,
--   ADD COLUMN IF NOT EXISTS travel_date_day date;

-- UPDATE public.bookings
-- SET booking_date_day = (booking_date AT TIME ZONE 'UTC')::date,
--     booking_week = EXTRACT(ISOWEEK FROM (booking_date AT TIME ZONE 'UTC'))::smallint,
--     travel_date_day = travel_date::date
-- WHERE booking_date IS NOT NULL OR travel_date IS NOT NULL;


 ==========================================
 1. ADVANCED BOOKING INDEXES
 ==========================================

 Composite index for booking searches by passenger and date
-- CREATE INDEX IF NOT EXISTS idx_bookings_passenger_date_status ON public.bookings(passenger_id, travel_date, status);

 Composite index for schedule bookings lookup
-- CREATE INDEX IF NOT EXISTS idx_bookings_schedule_passenger ON public.bookings(schedule_id, passenger_id);

 Partial index for unpaid bookings (smaller, faster queries)
-- CREATE INDEX IF NOT EXISTS idx_bookings_unpaid ON public.bookings(schedule_id, total_price)
-- WHERE is_paid = false AND status = 'confirmed'::booking_status;

 Partial index for active bookings
-- CREATE INDEX IF NOT EXISTS idx_bookings_active ON public.bookings(travel_date, status)
-- WHERE status IN ('confirmed'::booking_status, 'completed'::booking_status);

 Partial index for high-value bookings (note: use materialized date column if needed)
-- CREATE INDEX IF NOT EXISTS idx_bookings_high_value ON public.bookings(total_price DESC, travel_date)
-- WHERE total_price > 1000 AND status = 'completed'::booking_status;


 ==========================================
 2. SCHEDULE PERFORMANCE INDEXES
 ==========================================

 Composite index for schedule availability queries
-- CREATE INDEX IF NOT EXISTS idx_schedules_date_route_status ON public.schedules(travel_date, route_id, status);

 Composite index for driver schedules
-- CREATE INDEX IF NOT EXISTS idx_schedules_driver_date ON public.schedules(driver_id, travel_date, departure_time);

 Partial index for active schedules only
-- CREATE INDEX IF NOT EXISTS idx_schedules_active_search ON public.schedules(route_id, departure_time, available_seats)
-- WHERE is_active = true AND status = 'scheduled'::schedule_status AND available_seats > 0;

 Functional index replaced by index on materialized departure_date
-- CREATE INDEX IF NOT EXISTS idx_schedules_departure_date ON public.schedules(departure_date);

 Optional index on departure_hour (replaces EXTRACT(HOUR ...))
-- CREATE INDEX IF NOT EXISTS idx_schedules_departure_hour ON public.schedules(departure_hour);

 Optional index on travel day of week (replaces EXTRACT(DOW ...))
-- CREATE INDEX IF NOT EXISTS idx_schedules_day_of_week ON public.schedules(travel_dow);


 ==========================================
 3. VEHICLE AND FLEET INDEXES
 ==========================================

 Composite index for vehicle searches by manager
-- CREATE INDEX IF NOT EXISTS idx_vehicles_manager_type_status ON public.vehicles(manager_id, type, status);

 Partial index for active vehicles
-- CREATE INDEX IF NOT EXISTS idx_vehicles_active_location ON public.vehicles(latitude, longitude, status)
-- WHERE is_active = true AND status = 'active'::vehicle_status;

 Composite index for driver-vehicle assignments
-- CREATE INDEX IF NOT EXISTS idx_vehicles_current_driver_active ON public.vehicles(current_driver_id, is_active, status);


 ==========================================
 4. WALLET AND TRANSACTION INDEXES
 ==========================================

 Composite index for wallet transaction history
-- CREATE INDEX IF NOT EXISTS idx_wallet_transactions_wallet_date ON public.wallet_transactions(wallet_id, created_at DESC);

 Partial index for recent transactions (last 90 days)
 Note: Partial predicate to limit rows by date would require a fixed threshold; keeping generic here
-- CREATE INDEX IF NOT EXISTS idx_wallet_transactions_recent ON public.wallet_transactions(wallet_id, created_at DESC, amount);

 Index for transaction type filtering
-- CREATE INDEX IF NOT EXISTS idx_wallet_transactions_type_date ON public.wallet_transactions(type, created_at DESC);


 ==========================================
 5. NOTIFICATION PERFORMANCE INDEXES
 ==========================================

 Composite index for user notifications
-- CREATE INDEX IF NOT EXISTS idx_notifications_user_unread ON public.notifications(user_id, is_read, created_at DESC);

 Partial index for unread notifications
-- CREATE INDEX IF NOT EXISTS idx_notifications_unread_priority ON public.notifications(created_at DESC, priority DESC)
-- WHERE is_read = false;


 ==========================================
 6. LOCATION AND GPS INDEXES
 ==========================================

 Time-series optimized index for GPS data
-- CREATE INDEX IF NOT EXISTS idx_vehicle_locations_vehicle_time_desc ON public.vehicle_locations(vehicle_id, timestamp DESC);

 Index for location queries within time range
-- CREATE INDEX IF NOT EXISTS idx_vehicle_locations_time_range ON public.vehicle_locations(vehicle_id, timestamp DESC, is_moving);


 ==========================================
 7. ADMIN AND AUDIT INDEXES
 ==========================================

 Composite index for admin audit logs
-- CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_action_date ON public.admin_audit_logs(action, created_at DESC);

 Index for resource-based audit queries
-- CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_resource_action ON public.admin_audit_logs(resource_type, resource_id, action);

 Partial index for failed operations
-- CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_failures ON public.admin_audit_logs(created_at DESC, action)
-- WHERE success = false;


 ==========================================
 8. CHAT AND COMMUNICATION INDEXES
 ==========================================

 Composite index for conversation messages
-- CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_time ON public.chat_messages(conversation_id, created_at DESC);

 Index for unread messages in conversations
-- CREATE INDEX IF NOT EXISTS idx_chat_messages_unread ON public.chat_messages(conversation_id, created_at DESC)
-- WHERE is_read = false;


 ==========================================
 9. MAINTENANCE AND ALERT INDEXES
 ==========================================

 Composite index for maintenance scheduling
-- CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_vehicle_status ON public.vehicle_maintenance(vehicle_id, status, due_date);

 Partial index for overdue maintenance
-- CREATE INDEX IF NOT EXISTS idx_vehicle_maintenance_overdue ON public.vehicle_maintenance(due_date, vehicle_id)
-- WHERE status = 'scheduled';

 Index for driver alerts by priority
-- CREATE INDEX IF NOT EXISTS idx_driver_alerts_priority_time ON public.driver_alerts(driver_id, priority DESC, created_at DESC);


 ==========================================
 10. ANALYTICS QUERY INDEXES
 ==========================================

 Index for booking analytics date ranges (use materialized booking_date_day)
-- CREATE INDEX IF NOT EXISTS idx_bookings_analytics_date ON public.bookings(booking_date_day, status);

 Index for fleet analytics queries
-- CREATE INDEX IF NOT EXISTS idx_schedules_fleet_analytics ON public.schedules(travel_date, status, vehicle_id);

 Index for revenue analytics (use materialized booking_date_day)
-- CREATE INDEX IF NOT EXISTS idx_bookings_revenue_analytics ON public.bookings(booking_date_day, status, total_price);


 ==========================================
 11. FUNCTIONAL INDEXES FOR COMMON QUERIES
 ==========================================

 Replaced EXTRACT-based functional indexes with materialized columns above
 CREATE INDEX IF NOT EXISTS idx_schedules_departure_hour ON public.schedules(departure_hour);
 CREATE INDEX IF NOT EXISTS idx_schedules_day_of_week ON public.schedules(travel_dow);
 CREATE INDEX IF NOT EXISTS idx_bookings_week_of_year ON public.bookings(booking_week);


 ==========================================
 12. PARTIAL INDEXES FOR DATA FILTERING
 ==========================================

 Partial index for long-distance routes
-- CREATE INDEX IF NOT EXISTS idx_routes_long_distance ON public.routes(distance_km DESC)
-- WHERE distance_km > 500 AND is_active = true;

 Partial index for premium vehicles
-- CREATE INDEX IF NOT EXISTS idx_vehicles_premium ON public.vehicles(manager_id, capacity, type)
-- WHERE type IN ('luxury_bus'::vehicle_type) AND is_active = true;