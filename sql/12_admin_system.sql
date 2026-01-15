 ==========================================
 YOUBOOK Admin System
 Production-ready administrative features
 ==========================================
 Tables: admin_sessions, admin_audit_logs, admin_notifications, admin_settings
 Features: Session management, audit trails, system settings, admin notifications
 ==========================================

 ==========================================
 1. ADMIN SESSIONS TABLE
 ==========================================

 Admin login sessions for security tracking
-- CREATE TABLE IF NOT EXISTS public.admin_sessions (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     admin_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     session_token TEXT UNIQUE NOT NULL,
--     ip_address INET,
--     user_agent TEXT,
--     device_info JSONB DEFAULT '{}'::jsonb,
--     login_time TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     last_activity TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     logout_time TIMESTAMP WITH TIME ZONE,
--     is_active BOOLEAN DEFAULT true NOT NULL,
--     expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_admin_sessions_admin_id ON public.admin_sessions(admin_id);
-- CREATE INDEX IF NOT EXISTS idx_admin_sessions_session_token ON public.admin_sessions(session_token);
-- CREATE INDEX IF NOT EXISTS idx_admin_sessions_is_active ON public.admin_sessions(is_active);
-- CREATE INDEX IF NOT EXISTS idx_admin_sessions_expires_at ON public.admin_sessions(expires_at);

 ==========================================
 2. ADMIN AUDIT LOGS TABLE
 ==========================================

 Comprehensive audit trail for admin actions
-- CREATE TABLE IF NOT EXISTS public.admin_audit_logs (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     admin_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     action TEXT NOT NULL,  -- login, logout, user_create, user_update, booking_cancel, etc.
--     resource_type TEXT,  -- user, booking, vehicle, driver, etc.
--     resource_id UUID,  -- ID of the affected resource
--     old_values JSONB DEFAULT '{}'::jsonb,  -- Previous values for updates
--     new_values JSONB DEFAULT '{}'::jsonb,  -- New values for updates/creates
--     details JSONB DEFAULT '{}'::jsonb,  -- Additional context
--     ip_address INET,
--     user_agent TEXT,
--     session_id UUID REFERENCES public.admin_sessions(id) ON DELETE SET NULL,
--     success BOOLEAN DEFAULT true NOT NULL,
--     error_message TEXT,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_admin_id ON public.admin_audit_logs(admin_id);
-- CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_action ON public.admin_audit_logs(action);
-- CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_resource_type ON public.admin_audit_logs(resource_type);
-- CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_resource_id ON public.admin_audit_logs(resource_id);
-- CREATE INDEX IF NOT EXISTS idx_admin_audit_logs_created_at ON public.admin_audit_logs(created_at DESC);

 ==========================================
 3. ADMIN NOTIFICATIONS TABLE
 ==========================================

 System notifications for administrators
-- CREATE TABLE IF NOT EXISTS public.admin_notifications (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     title TEXT NOT NULL,
--     message TEXT NOT NULL,
--     type notification_type DEFAULT 'info'::notification_type NOT NULL,
--     priority priority_level DEFAULT 'medium'::priority_level NOT NULL,
--     category TEXT DEFAULT 'system',  -- system, security, finance, operations
--     action_url TEXT,  -- URL to navigate to when clicked
--     action_label TEXT,  -- Button text for action
--     is_read BOOLEAN DEFAULT false NOT NULL,
--     read_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
--     read_at TIMESTAMP WITH TIME ZONE,
--     expires_at TIMESTAMP WITH TIME ZONE,
--     auto_generated BOOLEAN DEFAULT false NOT NULL,  -- Whether created by system triggers
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_admin_notifications_type ON public.admin_notifications(type);
-- CREATE INDEX IF NOT EXISTS idx_admin_notifications_priority ON public.admin_notifications(priority DESC);
-- CREATE INDEX IF NOT EXISTS idx_admin_notifications_is_read ON public.admin_notifications(is_read);
-- CREATE INDEX IF NOT EXISTS idx_admin_notifications_expires_at ON public.admin_notifications(expires_at);
-- CREATE INDEX IF NOT EXISTS idx_admin_notifications_created_at ON public.admin_notifications(created_at DESC);

 ==========================================
 4. ADMIN SETTINGS TABLE
 ==========================================

 System-wide configuration settings
-- CREATE TABLE IF NOT EXISTS public.admin_settings (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     setting_key TEXT UNIQUE NOT NULL,
--     setting_value JSONB,
--     setting_type TEXT DEFAULT 'string',  -- string, number, boolean, json
--     description TEXT,
--     category TEXT DEFAULT 'general',  -- general, security, finance, notifications, etc.
--     is_system BOOLEAN DEFAULT false NOT NULL,  -- System settings cannot be deleted
--     is_public BOOLEAN DEFAULT false NOT NULL,  -- Whether clients can read this setting
--     validation_rules JSONB DEFAULT '{}'::jsonb,  -- Validation constraints
--     updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_admin_settings_setting_key ON public.admin_settings(setting_key);
-- CREATE INDEX IF NOT EXISTS idx_admin_settings_category ON public.admin_settings(category);
-- CREATE INDEX IF NOT EXISTS idx_admin_settings_is_system ON public.admin_settings(is_system);

 ==========================================
 5. UPDATE TIMESTAMP TRIGGERS
 ==========================================

 Update timestamp triggers
-- DROP TRIGGER IF EXISTS update_admin_sessions_updated_at ON public.admin_sessions;
-- CREATE TRIGGER update_admin_sessions_updated_at
--     BEFORE UPDATE ON public.admin_sessions
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_admin_notifications_updated_at ON public.admin_notifications;
-- CREATE TRIGGER update_admin_notifications_updated_at
--     BEFORE UPDATE ON public.admin_notifications
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_admin_settings_updated_at ON public.admin_settings;
-- CREATE TRIGGER update_admin_settings_updated_at
--     BEFORE UPDATE ON public.admin_settings
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

 ==========================================
 6. FUNCTIONS FOR ADMIN MANAGEMENT
 ==========================================

 Function to log admin actions
-- CREATE OR REPLACE FUNCTION public.log_admin_action(
--     p_admin_id UUID,
--     p_action TEXT,
--     p_resource_type TEXT DEFAULT NULL,
--     p_resource_id UUID DEFAULT NULL,
--     p_old_values JSONB DEFAULT '{}'::jsonb,
--     p_new_values JSONB DEFAULT '{}'::jsonb,
--     p_details JSONB DEFAULT '{}'::jsonb,
--     p_ip_address INET DEFAULT NULL,
--     p_user_agent TEXT DEFAULT NULL,
--     p_session_id UUID DEFAULT NULL,
--     p_success BOOLEAN DEFAULT true,
--     p_error_message TEXT DEFAULT NULL
-- )
-- RETURNS UUID AS $$
-- DECLARE
--     log_id UUID;
-- BEGIN
--     INSERT INTO public.admin_audit_logs (
--         admin_id, action, resource_type, resource_id, old_values, new_values,
--         details, ip_address, user_agent, session_id, success, error_message
--     ) VALUES (
--         p_admin_id, p_action, p_resource_type, p_resource_id, p_old_values, p_new_values,
--         p_details, p_ip_address, p_user_agent, p_session_id, p_success, p_error_message
--     ) RETURNING id INTO log_id;

--     RETURN log_id;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 Function to get setting value
-- CREATE OR REPLACE FUNCTION public.get_admin_setting(p_setting_key TEXT)
-- RETURNS JSONB AS $$
-- DECLARE
--     setting_value JSONB;
-- BEGIN
--     SELECT setting_value INTO setting_value
--     FROM public.admin_settings
--     WHERE setting_key = p_setting_key AND is_public = true;

--     RETURN setting_value;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 ==========================================
 Admin System Setup Complete
 ==========================================
 Next: Run 14_functions_and_triggers.sql for additional automation functions
