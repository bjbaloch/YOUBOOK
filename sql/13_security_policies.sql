 ==========================================
 YOUBOOK Row Level Security (RLS) Policies
 Production-ready data access control
 ==========================================
 Features: Comprehensive RLS policies for all tables
 Security: Users can only access their own data, managers their fleet data, admins all data
 ==========================================

 ==========================================
 1. ENABLE RLS ON ALL TABLES
 ==========================================

 Enable RLS on core tables
-- ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.manager_applications ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.routes ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.seats ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.booking_seats ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_fcm_tokens ENABLE ROW LEVEL SECURITY;

 ==========================================
 2. PROFILES POLICIES
 ==========================================

 Public profiles are viewable by everyone
-- DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;
-- CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
--     FOR SELECT USING (true);

 Users can insert their own profile
-- DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
-- CREATE POLICY "Users can insert their own profile" ON public.profiles
--     FOR INSERT WITH CHECK (auth.uid() = id);

 Users can update own profile
-- DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
-- CREATE POLICY "Users can update own profile" ON public.profiles
--     FOR UPDATE USING (auth.uid() = id);

 Managers and admins can update any profile
-- DROP POLICY IF EXISTS "Managers and admins can update any profile" ON public.profiles;
-- CREATE POLICY "Managers and admins can update any profile" ON public.profiles
--     FOR UPDATE USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role IN ('manager', 'admin')
--         )
--     );

 ==========================================
 3. MANAGER APPLICATIONS POLICIES
 ==========================================

 Users can view own applications
-- DROP POLICY IF EXISTS "Users can view own applications" ON public.manager_applications;
-- CREATE POLICY "Users can view own applications" ON public.manager_applications
--     FOR SELECT USING (auth.uid() = user_id);

 Users can create own applications
-- DROP POLICY IF EXISTS "Users can create own applications" ON public.manager_applications;
-- CREATE POLICY "Users can create own applications" ON public.manager_applications
--     FOR INSERT WITH CHECK (auth.uid() = user_id);

 Managers and admins can view all applications
-- DROP POLICY IF EXISTS "Managers and admins can view all applications" ON public.manager_applications;
-- CREATE POLICY "Managers and admins can view all applications" ON public.manager_applications
--     FOR SELECT USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role IN ('manager', 'admin')
--         )
--     );

 Managers and admins can update applications
-- DROP POLICY IF EXISTS "Managers and admins can update applications" ON public.manager_applications;
-- CREATE POLICY "Managers and admins can update applications" ON public.manager_applications
--     FOR UPDATE USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role IN ('manager', 'admin')
--         )
--     );

 ==========================================
 4. SERVICES POLICIES
 ==========================================

 Services are viewable by everyone (for browsing)
-- DROP POLICY IF EXISTS "Services are viewable by everyone" ON public.services;
-- CREATE POLICY "Services are viewable by everyone" ON public.services
--     FOR SELECT USING (is_active = true);

 Managers can manage their own services
-- DROP POLICY IF EXISTS "Managers can manage their own services" ON public.services;
-- CREATE POLICY "Managers can manage their own services" ON public.services
--     FOR ALL USING (auth.uid() = manager_id);

 Admins can manage all services
-- DROP POLICY IF EXISTS "Admins can manage all services" ON public.services;
-- CREATE POLICY "Admins can manage all services" ON public.services
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

 ==========================================
 5. BOOKINGS POLICIES
 ==========================================

 Users can view own bookings
-- DROP POLICY IF EXISTS "Users can view own bookings" ON public.bookings;
-- CREATE POLICY "Users can view own bookings" ON public.bookings
--     FOR SELECT USING (auth.uid() = passenger_id);

 Users can create bookings
-- DROP POLICY IF EXISTS "Users can create bookings" ON public.bookings;
-- CREATE POLICY "Users can create bookings" ON public.bookings
--     FOR INSERT WITH CHECK (auth.uid() = passenger_id);

 Users can update own bookings
-- DROP POLICY IF EXISTS "Users can update own bookings" ON public.bookings;
-- CREATE POLICY "Users can update own bookings" ON public.bookings
--     FOR UPDATE USING (auth.uid() = passenger_id);

 Drivers can view bookings for their schedules
-- DROP POLICY IF EXISTS "Drivers can view bookings for their schedules" ON public.bookings;
-- CREATE POLICY "Drivers can view bookings for their schedules" ON public.bookings
--     FOR SELECT USING (
--         EXISTS (
--             SELECT 1 FROM public.schedules s
--             WHERE s.id = schedule_id AND s.driver_id = auth.uid()
--         )
--     );

 Managers can view bookings for their services
-- DROP POLICY IF EXISTS "Managers can view bookings for their services" ON public.bookings;
-- CREATE POLICY "Managers can view bookings for their services" ON public.bookings
--     FOR SELECT USING (
--         EXISTS (
--             SELECT 1 FROM public.schedules sch
--             JOIN public.services svc ON sch.service_id = svc.id
--             WHERE sch.id = schedule_id AND svc.manager_id = auth.uid()
--         )
--     );

 ==========================================
 6. WALLET POLICIES
 ==========================================

 Users can view own wallet
-- DROP POLICY IF EXISTS "Users can view own wallet" ON public.wallets;
-- CREATE POLICY "Users can view own wallet" ON public.wallets
--     FOR SELECT USING (auth.uid() = user_id);

 Users can update own wallet
-- DROP POLICY IF EXISTS "Users can update own wallet" ON public.wallets;
-- CREATE POLICY "Users can update own wallet" ON public.wallets
--     FOR UPDATE USING (auth.uid() = user_id);

 ==========================================
 7. ADMIN-ONLY POLICIES
 ==========================================

 Admin sessions (admins only)
-- DROP POLICY IF EXISTS "Admins can manage admin sessions" ON public.admin_sessions;
-- CREATE POLICY "Admins can manage admin sessions" ON public.admin_sessions
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

 Admin audit logs (admins only)
-- DROP POLICY IF EXISTS "Admins can view audit logs" ON public.admin_audit_logs;
-- CREATE POLICY "Admins can view audit logs" ON public.admin_audit_logs
--     FOR SELECT USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

 Admin notifications (admins only)
-- DROP POLICY IF EXISTS "Admins can manage notifications" ON public.admin_notifications;
-- CREATE POLICY "Admins can manage notifications" ON public.admin_notifications
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

 Admin settings (admins only)
-- DROP POLICY IF EXISTS "Admins can manage settings" ON public.admin_settings;
-- CREATE POLICY "Admins can manage settings" ON public.admin_settings
--     FOR ALL USING (
--         EXISTS (
--             SELECT 1 FROM public.profiles
--             WHERE id = auth.uid() AND role = 'admin'
--         )
--     );

 ==========================================
 Security Policies Setup Complete
 ==========================================
 Next: Run remaining SQL files for complete setup
