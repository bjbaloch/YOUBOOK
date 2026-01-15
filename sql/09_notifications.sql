 ==========================================
 YOUBOOK Notifications System
 Production-ready notification and push messaging
 ==========================================
 Tables: notifications, user_fcm_tokens
 Features: In-app notifications, FCM push notifications, message queuing
 ==========================================

 ==========================================
 1. NOTIFICATIONS TABLE
 ==========================================

 Notifications table for in-app messaging
-- CREATE TABLE IF NOT EXISTS public.notifications (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     title TEXT NOT NULL,
--     message TEXT NOT NULL,
--     type notification_type DEFAULT 'info'::notification_type NOT NULL,
--     data JSONB DEFAULT '{}'::jsonb,  -- Additional notification data
--     action_url TEXT,  -- URL to navigate to when clicked
--     action_data JSONB DEFAULT '{}'::jsonb,  -- Data for action handling
--     priority priority_level DEFAULT 'medium'::priority_level NOT NULL,
--     is_read BOOLEAN DEFAULT false NOT NULL,
--     is_sent BOOLEAN DEFAULT false NOT NULL,  -- Whether push notification was sent
--     sent_at TIMESTAMP WITH TIME ZONE,
--     expires_at TIMESTAMP WITH TIME ZONE,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
-- CREATE INDEX IF NOT EXISTS idx_notifications_type ON public.notifications(type);
-- CREATE INDEX IF NOT EXISTS idx_notifications_priority ON public.notifications(priority DESC);
-- CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);
-- CREATE INDEX IF NOT EXISTS idx_notifications_is_sent ON public.notifications(is_sent);
-- CREATE INDEX IF NOT EXISTS idx_notifications_expires_at ON public.notifications(expires_at);
-- CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

 ==========================================
 2. USER FCM TOKENS TABLE
 ==========================================

 FCM tokens for push notifications
-- CREATE TABLE IF NOT EXISTS public.user_fcm_tokens (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     fcm_token TEXT NOT NULL,
--     device_info JSONB DEFAULT '{}'::jsonb,  -- device model, OS version, etc.
--     app_version TEXT,
--     is_active BOOLEAN DEFAULT true NOT NULL,
--     last_used_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()),
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(user_id, fcm_token)
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON public.user_fcm_tokens(user_id);
-- CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_fcm_token ON public.user_fcm_tokens(fcm_token);
-- CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_is_active ON public.user_fcm_tokens(is_active);
-- CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_last_used_at ON public.user_fcm_tokens(last_used_at DESC);

 ==========================================
 3. UPDATE TIMESTAMP TRIGGERS
 ==========================================

 Update timestamp triggers
-- DROP TRIGGER IF EXISTS update_notifications_updated_at ON public.notifications;
-- CREATE TRIGGER update_notifications_updated_at
--     BEFORE UPDATE ON public.notifications
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_user_fcm_tokens_updated_at ON public.user_fcm_tokens;
-- CREATE TRIGGER update_user_fcm_tokens_updated_at
--     BEFORE UPDATE ON public.user_fcm_tokens
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

 ==========================================
 4. FUNCTIONS FOR NOTIFICATION MANAGEMENT
 ==========================================

 Function to create and send notification
-- CREATE OR REPLACE FUNCTION public.create_notification(
--     p_user_id UUID,
--     p_title TEXT,
--     p_message TEXT,
--     p_type notification_type DEFAULT 'info'::notification_type,
--     p_priority priority_level DEFAULT 'medium'::priority_level,
--     p_data JSONB DEFAULT '{}'::jsonb,
--     p_action_url TEXT DEFAULT NULL,
--     p_expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
-- )
-- RETURNS UUID AS $$
-- DECLARE
--     notification_id UUID;
-- BEGIN
--     -- Insert notification
--     INSERT INTO public.notifications (
--         user_id, title, message, type, priority, data, action_url, expires_at
--     ) VALUES (
--         p_user_id, p_title, p_message, p_type, p_priority, p_data, p_action_url, p_expires_at
--     ) RETURNING id INTO notification_id;

--     -- TODO: Trigger push notification sending via external service

--     RETURN notification_id;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 Function to mark notification as read
-- CREATE OR REPLACE FUNCTION public.mark_notification_read(p_notification_id UUID)
-- RETURNS BOOLEAN AS $$
-- BEGIN
--     UPDATE public.notifications
--     SET is_read = true, updated_at = TIMEZONE('utc'::text, now())
--     WHERE id = p_notification_id;

--     RETURN FOUND;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 Function to clean up expired notifications
-- CREATE OR REPLACE FUNCTION public.cleanup_expired_notifications()
-- RETURNS INTEGER AS $$
-- DECLARE
--     deleted_count INTEGER;
-- BEGIN
--     DELETE FROM public.notifications
--     WHERE expires_at IS NOT NULL AND expires_at < TIMEZONE('utc'::text, now());

--     GET DIAGNOSTICS deleted_count = ROW_COUNT;
--     RETURN deleted_count;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 ==========================================
 Notifications Setup Complete
 ==========================================
 Next: Run 10_fleet_management.sql to create GPS tracking and analytics
