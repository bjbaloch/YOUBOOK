 ==========================================
 YOUBOOK Communication System
 Production-ready chat and messaging
 ==========================================
 Tables: chat_conversations, chat_messages, conversation_reports
 Features: Real-time messaging, conversation management, content moderation
 ==========================================

 ==========================================
 1. CHAT CONVERSATIONS TABLE
 ==========================================

 Conversations between passengers and drivers
-- CREATE TABLE IF NOT EXISTS public.chat_conversations (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     participant1_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     participant2_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     conversation_type TEXT DEFAULT 'passenger_driver',  -- passenger_driver, support, group
--     last_message TEXT,
--     last_activity TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     is_active BOOLEAN DEFAULT true NOT NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(participant1_id, participant2_id)
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_chat_conversations_participant1_id ON public.chat_conversations(participant1_id);
-- CREATE INDEX IF NOT EXISTS idx_chat_conversations_participant2_id ON public.chat_conversations(participant2_id);
-- CREATE INDEX IF NOT EXISTS idx_chat_conversations_last_activity ON public.chat_conversations(last_activity DESC);
-- CREATE INDEX IF NOT EXISTS idx_chat_conversations_is_active ON public.chat_conversations(is_active);

 ==========================================
 2. CHAT MESSAGES TABLE
 ==========================================

 Individual messages within conversations
-- CREATE TABLE IF NOT EXISTS public.chat_messages (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     conversation_id UUID REFERENCES public.chat_conversations(id) ON DELETE CASCADE NOT NULL,
--     sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     message TEXT NOT NULL,
--     message_type TEXT DEFAULT 'text',  -- text, image, location, file
--     media_url TEXT,  -- For images/files
--     metadata JSONB DEFAULT '{}'::jsonb,  -- Additional message data
--     is_read BOOLEAN DEFAULT false NOT NULL,
--     read_at TIMESTAMP WITH TIME ZONE,
--     is_deleted BOOLEAN DEFAULT false NOT NULL,
--     reply_to_message_id UUID REFERENCES public.chat_messages(id) ON DELETE SET NULL,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_id ON public.chat_messages(conversation_id);
-- CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON public.chat_messages(sender_id);
-- CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON public.chat_messages(created_at DESC);
-- CREATE INDEX IF NOT EXISTS idx_chat_messages_is_read ON public.chat_messages(is_read);
-- CREATE INDEX IF NOT EXISTS idx_chat_messages_reply_to_message_id ON public.chat_messages(reply_to_message_id);

 ==========================================
 3. CONVERSATION REPORTS TABLE
 ==========================================

 Reports for inappropriate content or behavior
-- CREATE TABLE IF NOT EXISTS public.conversation_reports (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     conversation_id UUID REFERENCES public.chat_conversations(id) ON DELETE CASCADE NOT NULL,
--     reporter_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     reported_user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     report_type TEXT NOT NULL,  -- harassment, spam, inappropriate_content, other
--     reason TEXT NOT NULL,
--     description TEXT,
--     message_id UUID REFERENCES public.chat_messages(id) ON DELETE SET NULL,  -- Specific message being reported
--     status TEXT DEFAULT 'pending',  -- pending, under_review, resolved, dismissed
--     reviewed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
--     review_notes TEXT,
--     action_taken TEXT,  -- warning, ban, message_deleted, conversation_closed
--     reviewed_at TIMESTAMP WITH TIME ZONE,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_conversation_reports_conversation_id ON public.conversation_reports(conversation_id);
-- CREATE INDEX IF NOT EXISTS idx_conversation_reports_reporter_id ON public.conversation_reports(reporter_id);
-- CREATE INDEX IF NOT EXISTS idx_conversation_reports_status ON public.conversation_reports(status);
-- CREATE INDEX IF NOT EXISTS idx_conversation_reports_created_at ON public.conversation_reports(created_at DESC);

 ==========================================
 4. UPDATE TIMESTAMP TRIGGERS
 ==========================================

 Update timestamp triggers
-- DROP TRIGGER IF EXISTS update_chat_conversations_updated_at ON public.chat_conversations;
-- CREATE TRIGGER update_chat_conversations_updated_at
--     BEFORE UPDATE ON public.chat_conversations
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

-- DROP TRIGGER IF EXISTS update_conversation_reports_updated_at ON public.conversation_reports;
-- CREATE TRIGGER update_conversation_reports_updated_at
--     BEFORE UPDATE ON public.conversation_reports
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

 ==========================================
 5. FUNCTIONS FOR CHAT MANAGEMENT
 ==========================================

 Function to send a message and update conversation
-- CREATE OR REPLACE FUNCTION public.send_chat_message(
--     p_conversation_id UUID,
--     p_sender_id UUID,
--     p_receiver_id UUID,
--     p_message TEXT,
--     p_message_type TEXT DEFAULT 'text',
--     p_media_url TEXT DEFAULT NULL,
--     p_reply_to_message_id UUID DEFAULT NULL
-- )
-- RETURNS UUID AS $$
-- DECLARE
--     message_id UUID;
-- BEGIN
--     -- Insert the message
--     INSERT INTO public.chat_messages (
--         conversation_id, sender_id, receiver_id, message, message_type,
--         media_url, reply_to_message_id
--     ) VALUES (
--         p_conversation_id, p_sender_id, p_receiver_id, p_message, p_message_type,
--         p_media_url, p_reply_to_message_id
--     ) RETURNING id INTO message_id;

--     -- Update conversation's last message and activity
--     UPDATE public.chat_conversations
--     SET last_message = p_message,
--         last_activity = TIMEZONE('utc'::text, now()),
--         updated_at = TIMEZONE('utc'::text, now())
--     WHERE id = p_conversation_id;

--     RETURN message_id;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 Function to mark messages as read
-- CREATE OR REPLACE FUNCTION public.mark_messages_read(
--     p_conversation_id UUID,
--     p_user_id UUID
-- )
-- RETURNS INTEGER AS $$
-- DECLARE
--     messages_read INTEGER;
-- BEGIN
--     UPDATE public.chat_messages
--     SET is_read = true,
--         read_at = TIMEZONE('utc'::text, now())
--     WHERE conversation_id = p_conversation_id
--       AND receiver_id = p_user_id
--       AND is_read = false;

--     GET DIAGNOSTICS messages_read = ROW_COUNT;
--     RETURN messages_read;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

 ==========================================
 Communication Setup Complete
 ==========================================
 Next: Run 12_admin_system.sql to create admin management system
