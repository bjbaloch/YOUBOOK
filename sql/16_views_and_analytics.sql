 ==========================================
 YOUBOOK Analytics & Dashboard Views
 Production-ready reporting and analytics
 ==========================================
 Views: admin_dashboard_stats, fleet_status, booking_analytics, driver_performance, revenue_reports
 Features: Real-time dashboards, performance metrics, business intelligence
 ==========================================

 ==========================================
 1. ADMIN DASHBOARD STATISTICS VIEW
 ==========================================

 Real-time dashboard metrics for administrators
-- CREATE OR REPLACE VIEW public.admin_dashboard_stats AS
-- SELECT
--     JSON_BUILD_OBJECT(
--         'total_passengers', (SELECT COUNT(*) FROM public.profiles WHERE role = 'passenger'::user_role AND is_active = true),
--         'total_managers', (SELECT COUNT(*) FROM public.profiles WHERE role = 'manager'::user_role AND is_active = true),
--         'total_drivers', (SELECT COUNT(*) FROM public.profiles WHERE role = 'driver'::user_role AND is_active = true),
--         'total_admins', (SELECT COUNT(*) FROM public.profiles WHERE role = 'admin'::user_role AND is_active = true),
--         'pending_applications', (SELECT COUNT(*) FROM public.manager_applications WHERE status = 'pending'),
--         'upcoming_bookings', (SELECT COUNT(*) FROM public.bookings WHERE status = 'confirmed'::booking_status AND travel_date >= CURRENT_DATE),
--         'active_vehicles', (SELECT COUNT(*) FROM public.vehicles WHERE is_active = true),
--         'scheduled_trips', (SELECT COUNT(*) FROM public.schedules WHERE status = 'scheduled'::schedule_status AND departure_time >= CURRENT_DATE),
--         'active_admin_sessions', (SELECT COUNT(*) FROM public.admin_sessions WHERE is_active = true),
--         'unread_notifications', (SELECT COUNT(*) FROM public.admin_notifications WHERE is_read = false),
--         'todays_actions', (SELECT COUNT(*) FROM public.admin_audit_logs WHERE created_at >= CURRENT_DATE),
--         'total_revenue_today', (SELECT COALESCE(SUM(total_price), 0) FROM public.bookings WHERE status = 'completed'::booking_status AND booking_date >= CURRENT_DATE),
--         'total_revenue_month', (SELECT COALESCE(SUM(total_price), 0) FROM public.bookings WHERE status = 'completed'::booking_status AND booking_date >= DATE_TRUNC('month', CURRENT_DATE))
--     ) as dashboard_stats;

 Grant access to authenticated users (will be filtered by RLS)
-- GRANT SELECT ON public.admin_dashboard_stats TO authenticated;

 ==========================================
 2. FLEET STATUS VIEW
 ==========================================

 Real-time fleet status for monitoring
-- CREATE OR REPLACE VIEW public.fleet_status AS
-- SELECT
--     v.id,
--     v.vehicle_number,
--     v.registration_number,
--     v.type,
--     v.capacity,
--     v.fuel_level,
--     vs.status as current_status,
--     vs.driver_id,
--     p.full_name as driver_name,
--     p.phone_number as driver_phone,
--     vl.latitude,
--     vl.longitude,
--     vl.speed,
--     vl.timestamp as last_location_time,
--     s.id as current_schedule_id,
--     s.departure_time,
--     s.status as schedule_status,
--     r.name as current_route,
--     vm.due_date as next_maintenance_date,
--     vm.priority as maintenance_priority,
--     vs.last_communication,
--     vs.is_online,
--     EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - vl.timestamp)) / 60 as minutes_since_update
-- FROM public.vehicles v
-- LEFT JOIN public.vehicle_statuses vs ON v.id = vs.vehicle_id
-- LEFT JOIN public.profiles p ON vs.driver_id = p.id
-- LEFT JOIN public.vehicle_locations vl ON v.id = vl.vehicle_id
--     AND vl.timestamp = (SELECT MAX(timestamp) FROM public.vehicle_locations WHERE vehicle_id = v.id)
-- LEFT JOIN public.schedules s ON v.id = s.vehicle_id
--     AND s.status IN ('scheduled'::schedule_status, 'in_transit'::schedule_status)
--     AND s.departure_time >= CURRENT_DATE
-- LEFT JOIN public.routes r ON s.route_id = r.id
-- LEFT JOIN public.vehicle_maintenance vm ON v.id = vm.vehicle_id
--     AND vm.status = 'scheduled'
--     AND vm.due_date = (SELECT MIN(due_date) FROM public.vehicle_maintenance WHERE vehicle_id = v.id AND status = 'scheduled')
-- WHERE v.is_active = true;

 Grant access to authenticated users
-- GRANT SELECT ON public.fleet_status TO authenticated;

 ==========================================
 3. BOOKING ANALYTICS VIEW
 ==========================================

 Comprehensive booking analytics
-- CREATE OR REPLACE VIEW public.booking_analytics AS
-- SELECT
--     DATE_TRUNC('day', b.booking_date) as booking_date,
--     COUNT(*) as total_bookings,
--     COUNT(CASE WHEN b.status = 'completed'::booking_status THEN 1 END) as completed_bookings,
--     COUNT(CASE WHEN b.status = 'cancelled'::booking_status THEN 1 END) as cancelled_bookings,
--     COUNT(CASE WHEN b.status = 'confirmed'::booking_status THEN 1 END) as confirmed_bookings,
--     COALESCE(SUM(b.total_price), 0) as total_revenue,
--     COALESCE(SUM(CASE WHEN b.status = 'completed'::booking_status THEN b.total_price END), 0) as completed_revenue,
--     COALESCE(AVG(b.total_price), 0) as average_booking_value,
--     COUNT(DISTINCT b.passenger_id) as unique_passengers,
--     COUNT(DISTINCT s.vehicle_id) as vehicles_used,
--     COUNT(DISTINCT s.driver_id) as drivers_used
-- FROM public.bookings b
-- LEFT JOIN public.schedules s ON b.schedule_id = s.id
-- WHERE b.booking_date >= CURRENT_DATE - INTERVAL '30 days'
-- GROUP BY DATE_TRUNC('day', b.booking_date)
-- ORDER BY booking_date DESC;

 Grant access to authenticated users
-- GRANT SELECT ON public.booking_analytics TO authenticated;

 ==========================================
 4. DRIVER PERFORMANCE VIEW
 ==========================================

 Driver performance metrics
-- CREATE OR REPLACE VIEW public.driver_performance AS
-- SELECT
--     d.id,
--     d.user_id,
--     p.full_name,
--     p.phone_number,
--     d.license_number,
--     d.rating,
--     d.rating_count,
--     d.total_trips,
--     d.total_km_driven,
--     d.status,
--     d.is_available,
--     d.last_active_at,
--     EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - d.last_active_at)) / 3600 as hours_since_active,
--     COUNT(CASE WHEN s.status = 'completed'::schedule_status AND s.departure_time >= CURRENT_DATE - INTERVAL '30 days' THEN 1 END) as trips_last_30_days,
--     COUNT(CASE WHEN s.status = 'completed'::schedule_status AND s.departure_time >= CURRENT_DATE - INTERVAL '7 days' THEN 1 END) as trips_last_7_days,
--     COALESCE(AVG(CASE WHEN s.status = 'completed'::schedule_status THEN s.base_fare END), 0) as average_fare_per_trip,
--     COUNT(da.id) as unread_alerts,
--     vs.is_online as currently_online
-- FROM public.drivers d
-- JOIN public.profiles p ON d.user_id = p.id
-- LEFT JOIN public.schedules s ON d.user_id = s.driver_id
-- LEFT JOIN public.driver_alerts da ON d.id = da.driver_id AND da.is_read = false
-- LEFT JOIN public.vehicle_statuses vs ON d.current_vehicle_id = vs.vehicle_id
-- GROUP BY d.id, d.user_id, p.full_name, p.phone_number, d.license_number, d.rating,
--          d.rating_count, d.total_trips, d.total_km_driven, d.status, d.is_available,
--          d.last_active_at, da.id, vs.is_online;

 Grant access to authenticated users
-- GRANT SELECT ON public.driver_performance TO authenticated;

 ==========================================
 5. REVENUE REPORTS VIEW
 ==========================================

 Detailed revenue analytics
-- CREATE OR REPLACE VIEW public.revenue_reports AS
-- SELECT
--     DATE_TRUNC('month', b.booking_date) as month,
--     COUNT(*) as total_bookings,
--     COUNT(CASE WHEN b.status = 'completed'::booking_status THEN 1 END) as completed_bookings,
--     COALESCE(SUM(b.total_price), 0) as gross_revenue,
--     COALESCE(SUM(CASE WHEN b.status = 'completed'::booking_status THEN b.total_price END), 0) as net_revenue,
--     COALESCE(SUM(wt.amount), 0) as wallet_transactions,
--     COALESCE(SUM(CASE WHEN wt.type = 'credit' THEN wt.amount END), 0) as credits,
--     COALESCE(SUM(CASE WHEN wt.type = 'debit' THEN wt.amount END), 0) as debits,
--     COUNT(DISTINCT b.passenger_id) as unique_customers,
--     COUNT(DISTINCT s.vehicle_id) as vehicles_used,
--     COUNT(DISTINCT s.service_id) as services_used,
--     AVG(CASE WHEN b.status = 'completed'::booking_status THEN b.total_price END) as average_transaction_value
-- FROM public.bookings b
-- LEFT JOIN public.schedules s ON b.schedule_id = s.id
-- LEFT JOIN public.wallet_transactions wt ON b.id = wt.reference_id AND wt.reference_type = 'booking'
-- WHERE b.booking_date >= CURRENT_DATE - INTERVAL '12 months'
-- GROUP BY DATE_TRUNC('month', b.booking_date)
-- ORDER BY month DESC;

 Grant access to authenticated users
-- GRANT SELECT ON public.revenue_reports TO authenticated;

 ==========================================
 6. SYSTEM HEALTH VIEW
 ==========================================

 System health and performance metrics
-- CREATE OR REPLACE VIEW public.system_health AS
-- SELECT
--     JSON_BUILD_OBJECT(
--         'database_connections', (SELECT count(*) FROM pg_stat_activity),
--         'active_sessions', (SELECT count(*) FROM public.admin_sessions WHERE is_active = true),
--         'pending_notifications', (SELECT count(*) FROM public.notifications WHERE is_read = false),
--         'unread_admin_notifications', (SELECT count(*) FROM public.admin_notifications WHERE is_read = false),
--         'active_vehicles', (SELECT count(*) FROM public.vehicle_statuses WHERE is_online = true),
--         'maintenance_overdue', (SELECT count(*) FROM public.vehicle_maintenance WHERE due_date < CURRENT_DATE AND status = 'scheduled'),
--         'drivers_available', (SELECT count(*) FROM public.drivers WHERE status = 'active'::driver_status AND is_available = true),
--         'upcoming_schedules', (SELECT count(*) FROM public.schedules WHERE departure_time >= CURRENT_DATE AND departure_time <= CURRENT_DATE + INTERVAL '24 hours'),
--         'bookings_today', (SELECT count(*) FROM public.bookings WHERE travel_date = CURRENT_DATE),
--         'revenue_today', (SELECT COALESCE(sum(total_price), 0) FROM public.bookings WHERE status = 'completed'::booking_status AND booking_date >= CURRENT_DATE),
--         'error_logs_today', (SELECT count(*) FROM public.admin_audit_logs WHERE success = false AND created_at >= CURRENT_DATE)
--     ) as health_metrics;

 Grant access to authenticated users
-- GRANT SELECT ON public.system_health TO authenticated;

 ==========================================
 Analytics Views Setup Complete
 ==========================================
 All YOUBOOK production schema files are now complete!
 Ready for deployment and use with both Flutter apps.
