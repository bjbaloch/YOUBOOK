
-- CREATE OR REPLACE FUNCTION public.create_booking(
--     p_passenger_id UUID,
--     p_schedule_id UUID,
--     p_seat_numbers TEXT[],
--     p_pickup_location JSONB DEFAULT NULL,
--     p_special_requests TEXT DEFAULT NULL
-- )
-- RETURNS TABLE (
--     booking_id UUID,
--     total_price DECIMAL(8,2),
--     status booking_status,
--     message TEXT
-- ) AS $$
-- DECLARE
--     v_schedule_record RECORD;
--     v_vehicle_capacity INTEGER;
--     v_available_seats INTEGER;
--     v_seat_count INTEGER := array_length(p_seat_numbers, 1);
--     v_base_fare DECIMAL(8,2);
--     v_total_price DECIMAL(8,2);
--     v_booking_id UUID;
--     v_seat_number TEXT;
-- BEGIN
--     -- Get schedule details
--     SELECT s.*, v.capacity as vehicle_capacity
--     INTO v_schedule_record
--     FROM public.schedules s
--     JOIN public.vehicles v ON s.vehicle_id = v.id
--     WHERE s.id = p_schedule_id AND s.is_active = true;

--     IF NOT FOUND THEN
--         RETURN QUERY SELECT NULL::UUID, NULL::DECIMAL, NULL::booking_status, 'Schedule not found or inactive'::TEXT;
--         RETURN;
--     END IF;

--     -- Check if schedule is in the future
--     IF v_schedule_record.departure_time <= CURRENT_TIMESTAMP THEN
--         RETURN QUERY SELECT NULL::UUID, NULL::DECIMAL, NULL::booking_status, 'Cannot book past schedules'::TEXT;
--         RETURN;
--     END IF;

--     -- Calculate available seats
--     SELECT public.calculate_available_seats(p_schedule_id) INTO v_available_seats;

--     IF v_available_seats < v_seat_count THEN
--         RETURN QUERY SELECT NULL::UUID, NULL::DECIMAL, NULL::booking_status, 'Not enough seats available'::TEXT;
--         RETURN;
--     END IF;

--     -- Check if requested seats are available
--     FOREACH v_seat_number IN ARRAY p_seat_numbers LOOP
--         IF NOT EXISTS (
--             SELECT 1 FROM public.seats
--             WHERE vehicle_id = v_schedule_record.vehicle_id
--               AND seat_number = v_seat_number
--               AND is_available = true
--               AND NOT EXISTS (
--                   SELECT 1 FROM public.booking_seats bs
--                   WHERE bs.seat_id = seats.id
--                     AND bs.schedule_id = p_schedule_id
--               )
--         ) THEN
--             RETURN QUERY SELECT NULL::UUID, NULL::DECIMAL, NULL::booking_status, format('Seat %s is not available', v_seat_number)::TEXT;
--             RETURN;
--         END IF;
--     END LOOP;

--     -- Calculate total price
--     v_base_fare := v_schedule_record.base_fare;
--     v_total_price := v_base_fare * v_seat_count;

--     -- Create booking
--     INSERT INTO public.bookings (
--         passenger_id, schedule_id, travel_date, total_price, status,
--         pickup_location, special_requests
--     ) VALUES (
--         p_passenger_id, p_schedule_id, v_schedule_record.travel_date, v_total_price, 'confirmed'::booking_status,
--         p_pickup_location, p_special_requests
--     ) RETURNING id INTO v_booking_id;

--     -- Assign seats
--     FOREACH v_seat_number IN ARRAY p_seat_numbers LOOP
--         INSERT INTO public.booking_seats (
--             booking_id, schedule_id, seat_id, seat_number
--         ) SELECT
--             v_booking_id, p_schedule_id, s.id, v_seat_number
--         FROM public.seats s
--         WHERE s.vehicle_id = v_schedule_record.vehicle_id
--           AND s.seat_number = v_seat_number;
--     END LOOP;

--     -- Update schedule available seats
--     UPDATE public.schedules
--     SET available_seats = public.calculate_available_seats(p_schedule_id)
--     WHERE id = p_schedule_id;

--     RETURN QUERY SELECT v_booking_id, v_total_price, 'confirmed'::booking_status, 'Booking created successfully'::TEXT;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to cancel a booking
-- CREATE OR REPLACE FUNCTION public.cancel_booking(
--     p_booking_id UUID,
--     p_cancelled_by UUID DEFAULT NULL
-- )
-- RETURNS TABLE (
--     success BOOLEAN,
--     refund_amount DECIMAL(8,2),
--     message TEXT
-- ) AS $$
-- DECLARE
--     v_booking_record RECORD;
--     v_cancellation_policy_hours INTEGER := 2; -- Configurable
--     v_refund_percentage DECIMAL(5,2) := 0.8; -- 80% refund
--     v_refund_amount DECIMAL(8,2) := 0;
-- BEGIN
--     -- Get booking details
--     SELECT * INTO v_booking_record
--     FROM public.bookings
--     WHERE id = p_booking_id AND status = 'confirmed'::booking_status;

--     IF NOT FOUND THEN
--         RETURN QUERY SELECT false, 0::DECIMAL, 'Booking not found or not cancellable'::TEXT;
--         RETURN;
--     END IF;

--     -- Check cancellation policy (e.g., 2 hours before departure)
--     IF EXISTS (
--         SELECT 1 FROM public.schedules s
--         WHERE s.id = v_booking_record.schedule_id
--           AND s.departure_time <= CURRENT_TIMESTAMP + INTERVAL '1 hour' * v_cancellation_policy_hours
--     ) THEN
--         RETURN QUERY SELECT false, 0::DECIMAL, 'Cannot cancel booking within 2 hours of departure'::TEXT;
--         RETURN;
--     END IF;

--     -- Calculate refund
--     v_refund_amount := v_booking_record.total_price * v_refund_percentage;

--     -- Update booking status
--     UPDATE public.bookings
--     SET status = 'cancelled'::booking_status, updated_at = CURRENT_TIMESTAMP
--     WHERE id = p_booking_id;

--     -- Release seats
--     UPDATE public.seats
--     SET is_available = true, is_locked = false, locked_until = NULL, updated_at = CURRENT_TIMESTAMP
--     WHERE id IN (
--         SELECT seat_id FROM public.booking_seats WHERE booking_id = p_booking_id
--     );

--     -- Update schedule available seats
--     UPDATE public.schedules
--     SET available_seats = public.calculate_available_seats(v_booking_record.schedule_id)
--     WHERE id = v_booking_record.schedule_id;

--     -- Process refund to wallet if payment was made
--     IF v_booking_record.is_paid THEN
--         INSERT INTO public.wallet_transactions (
--             wallet_id, amount, type, description, reference_type, reference_id
--         ) SELECT
--             w.id, v_refund_amount, 'credit', 'Booking cancellation refund', 'booking', p_booking_id
--         FROM public.wallets w
--         WHERE w.user_id = v_booking_record.passenger_id;

--         UPDATE public.wallets
--         SET balance = balance + v_refund_amount, updated_at = CURRENT_TIMESTAMP
--         WHERE user_id = v_booking_record.passenger_id;
--     END IF;

--     -- Log admin action
--     PERFORM public.log_admin_action(
--         COALESCE(p_cancelled_by, v_booking_record.passenger_id),
--         'booking_cancel',
--         'booking',
--         p_booking_id,
--         jsonb_build_object('original_price', v_booking_record.total_price),
--         jsonb_build_object('refund_amount', v_refund_amount),
--         jsonb_build_object('cancelled_at', CURRENT_TIMESTAMP)
--     );

--     RETURN QUERY SELECT true, v_refund_amount, 'Booking cancelled successfully'::TEXT;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  ==========================================
--  2. WALLET MANAGEMENT FUNCTIONS
--  ==========================================

--  Function to process wallet transaction
-- CREATE OR REPLACE FUNCTION public.process_wallet_transaction(
--     p_user_id UUID,
--     p_amount DECIMAL(10,2),
--     p_type TEXT, -- 'credit', 'debit'
--     p_description TEXT,
--     p_reference_type TEXT DEFAULT NULL,
--     p_reference_id UUID DEFAULT NULL,
--     p_payment_method TEXT DEFAULT NULL,
--     p_processed_by UUID DEFAULT NULL
-- )
-- RETURNS TABLE (
--     transaction_id UUID,
--     new_balance DECIMAL(12,2),
--     success BOOLEAN,
--     message TEXT
-- ) AS $$
-- DECLARE
--     v_wallet_id UUID;
--     v_current_balance DECIMAL(12,2);
--     v_new_balance DECIMAL(12,2);
--     v_transaction_id UUID;
-- BEGIN
--     -- Get or create wallet
--     SELECT id, balance INTO v_wallet_id, v_current_balance
--     FROM public.wallets
--     WHERE user_id = p_user_id;

--     IF NOT FOUND THEN
--         INSERT INTO public.wallets (user_id) VALUES (p_user_id)
--         RETURNING id INTO v_wallet_id;
--         v_current_balance := 0;
--     END IF;

--     -- Calculate new balance
--     IF p_type = 'credit' THEN
--         v_new_balance := v_current_balance + p_amount;
--     ELSIF p_type = 'debit' THEN
--         IF v_current_balance < p_amount THEN
--             RETURN QUERY SELECT NULL::UUID, v_current_balance, false, 'Insufficient balance'::TEXT;
--             RETURN;
--         END IF;
--         v_new_balance := v_current_balance - p_amount;
--     ELSE
--         RETURN QUERY SELECT NULL::UUID, v_current_balance, false, 'Invalid transaction type'::TEXT;
--         RETURN;
--     END IF;

--     -- Create transaction record
--     INSERT INTO public.wallet_transactions (
--         wallet_id, amount, type, description, reference_type, reference_id,
--         balance_before, balance_after, payment_method, processed_by
--     ) VALUES (
--         v_wallet_id, p_amount, p_type, p_description, p_reference_type, p_reference_id,
--         v_current_balance, v_new_balance, p_payment_method, p_processed_by
--     ) RETURNING id INTO v_transaction_id;

--     -- Update wallet balance
--     UPDATE public.wallets
--     SET balance = v_new_balance,
--         total_credited = CASE WHEN p_type = 'credit' THEN total_credited + p_amount ELSE total_credited END,
--         total_debited = CASE WHEN p_type = 'debit' THEN total_debited + p_amount ELSE total_debited END,
--         updated_at = CURRENT_TIMESTAMP
--     WHERE id = v_wallet_id;

--     RETURN QUERY SELECT v_transaction_id, v_new_balance, true, 'Transaction processed successfully'::TEXT;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  ==========================================
--  3. SCHEDULE MANAGEMENT FUNCTIONS
--  ==========================================

--  Function to create a schedule with automatic seat generation
-- CREATE OR REPLACE FUNCTION public.create_schedule(
--     p_vehicle_id UUID,
--     p_route_id UUID,
--     p_driver_id UUID,
--     p_departure_time TIMESTAMP WITH TIME ZONE,
--     p_arrival_time TIMESTAMP WITH TIME ZONE,
--     p_travel_date DATE,
--     p_base_fare DECIMAL(8,2),
--     p_service_id UUID DEFAULT NULL
-- )
-- RETURNS TABLE (
--     schedule_id UUID,
--     available_seats INTEGER,
--     message TEXT
-- ) AS $$
-- DECLARE
--     v_vehicle_capacity INTEGER;
--     v_schedule_id UUID;
--     v_available_seats INTEGER;
-- BEGIN
--     -- Get vehicle capacity
--     SELECT capacity INTO v_vehicle_capacity
--     FROM public.vehicles
--     WHERE id = p_vehicle_id AND is_active = true;

--     IF NOT FOUND THEN
--         RETURN QUERY SELECT NULL::UUID, NULL::INTEGER, 'Vehicle not found or inactive'::TEXT;
--         RETURN;
--     END IF;

--     -- Check for schedule conflicts
--     IF EXISTS (
--         SELECT 1 FROM public.schedules
--         WHERE vehicle_id = p_vehicle_id
--           AND travel_date = p_travel_date
--           AND (
--               (departure_time <= p_departure_time AND arrival_time > p_departure_time) OR
--               (departure_time < p_arrival_time AND arrival_time >= p_arrival_time) OR
--               (departure_time >= p_departure_time AND arrival_time <= p_arrival_time)
--           )
--     ) THEN
--         RETURN QUERY SELECT NULL::UUID, NULL::INTEGER, 'Schedule conflicts with existing schedule'::TEXT;
--         RETURN;
--     END IF;

--     -- Create schedule
--     INSERT INTO public.schedules (
--         vehicle_id, route_id, driver_id, service_id,
--         departure_time, arrival_time, travel_date,
--         base_fare, total_seats
--     ) VALUES (
--         p_vehicle_id, p_route_id, p_driver_id, p_service_id,
--         p_departure_time, p_arrival_time, p_travel_date,
--         p_base_fare, v_vehicle_capacity
--     ) RETURNING id INTO v_schedule_id;

--     -- Calculate available seats
--     SELECT public.calculate_available_seats(v_schedule_id) INTO v_available_seats;

--     -- Update available seats
--     UPDATE public.schedules
--     SET available_seats = v_available_seats
--     WHERE id = v_schedule_id;

--     RETURN QUERY SELECT v_schedule_id, v_available_seats, 'Schedule created successfully'::TEXT;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  ==========================================
--  4. DRIVER MANAGEMENT FUNCTIONS
--  ==========================================

-- Function to create a driver user (RPC for manager to create driver accounts)
CREATE OR REPLACE FUNCTION public.create_driver_user(
    p_email TEXT,
    p_password TEXT,
    p_name TEXT,
    p_manager_id UUID
)
RETURNS TABLE (
    auth_user_id UUID,
    driver_id UUID,
    temp_password TEXT,
    message TEXT
) AS $$
DECLARE
    v_auth_user_record RECORD;
    v_driver_id UUID;
    v_temp_password TEXT := p_password;
BEGIN
    -- Create auth user with admin privileges
    SELECT * INTO v_auth_user_record
    FROM auth.admin.create_user(
        email => p_email,
        password => p_password,
        email_confirm => true,
        user_metadata => jsonb_build_object(
            'full_name', p_name,
            'role', 'driver'
        )
    );

    -- Insert profile (this will be done by trigger, but let's ensure it exists)
    INSERT INTO public.profiles (
        id,
        email,
        full_name,
        role,
        manager_id,
        is_active
    ) VALUES (
        v_auth_user_record.id,
        p_email,
        p_name,
        'driver'::user_role,
        p_manager_id,
        true
    ) ON CONFLICT (id) DO UPDATE SET
        full_name = EXCLUDED.full_name,
        role = EXCLUDED.role,
        manager_id = EXCLUDED.manager_id,
        updated_at = now();

    -- Create driver record
    INSERT INTO public.drivers (
        company_id,
        auth_user_id,
        email,
        name,
        phone,
        license_number,
        current_status
    ) VALUES (
        p_manager_id,
        v_auth_user_record.id,
        p_email,
        p_name,
        '',
        '',
        'Idle'::driver_status
    ) RETURNING id INTO v_driver_id;

    RETURN QUERY SELECT v_auth_user_record.id, v_driver_id, v_temp_password, 'Driver account created successfully.'::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- -- Function to create a driver account with auth user (legacy - keep for compatibility)
-- CREATE OR REPLACE FUNCTION public.create_driver_account(
--     p_company_id UUID,
--     p_email TEXT,
--     p_name TEXT,
--     p_phone TEXT,
--     p_license_number TEXT,
--     p_temp_password TEXT
-- )
-- RETURNS TABLE (
--     driver_id UUID,
--     auth_user_id UUID,
--     temp_password TEXT,
--     message TEXT
-- ) AS $$
-- DECLARE
--     v_auth_user_record RECORD;
--     v_driver_id UUID;
-- BEGIN
--     -- Create auth user with admin privileges
--     SELECT * INTO v_auth_user_record
--     FROM auth.admin.create_user(
--         email => p_email,
--         password => p_temp_password,
--         email_confirm => true,
--         user_metadata => jsonb_build_object(
--             'full_name', p_name,
--             'phone', p_phone,
--             'role', 'driver'
--         )
--     );

--     -- Create driver record
--     INSERT INTO public.drivers (
--         company_id,
--         auth_user_id,
--         email,
--         name,
--         phone,
--         license_number,
--         current_status
--     ) VALUES (
--         p_company_id,
--         v_auth_user_record.id,
--         p_email,
--         p_name,
--         p_phone,
--         p_license_number,
--         'Idle'
--     ) RETURNING id INTO v_driver_id;

--     RETURN QUERY SELECT v_driver_id, v_auth_user_record.id, p_temp_password, 'Driver account created successfully.'::TEXT;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  ==========================================
--  5. NOTIFICATION FUNCTIONS
--  ==========================================

--  Function to send booking confirmation notification
-- CREATE OR REPLACE FUNCTION public.send_booking_confirmation(p_booking_id UUID)
-- RETURNS BOOLEAN AS $$
-- DECLARE
--     v_booking_record RECORD;
--     v_user_email TEXT;
--     v_schedule_info TEXT;
-- BEGIN
--     -- Get booking details
--     SELECT
--         b.*,
--         p.full_name,
--         p.email,
--         s.departure_time,
--         s.arrival_time,
--         r.name as route_name,
--         v.registration_number
--     INTO v_booking_record
--     FROM public.bookings b
--     JOIN public.profiles p ON b.passenger_id = p.id
--     JOIN public.schedules s ON b.schedule_id = s.id
--     JOIN public.routes r ON s.route_id = r.id
--     JOIN public.vehicles v ON s.vehicle_id = v.id
--     WHERE b.id = p_booking_id;

--     IF NOT FOUND THEN
--         RETURN false;
--     END IF;

--     -- Format schedule info
--     v_schedule_info := format('%s to %s on %s at %s',
--         v_booking_record.route_name,
--         'Destination', -- You might want to add end location to routes
--         v_booking_record.travel_date,
--         v_booking_record.departure_time::TIME
--     );

--     -- Send notification
--     PERFORM public.create_notification(
--         v_booking_record.passenger_id,
--         'Booking Confirmed',
--         format('Your booking for %s has been confirmed. Vehicle: %s, Total: PKR %s',
--             v_schedule_info, v_booking_record.registration_number, v_booking_record.total_price),
--         'success'::notification_type,
--         'medium'::priority_level,
--         jsonb_build_object('booking_id', p_booking_id, 'type', 'booking_confirmation')
--     );

--     RETURN true;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  ==========================================
--  5. MAINTENANCE TRIGGERS
--  ==========================================

--  Trigger to create maintenance notification when due date approaches
-- CREATE OR REPLACE FUNCTION public.check_maintenance_due_dates()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     -- Check if maintenance is due within 7 days
--     IF NEW.due_date <= CURRENT_DATE + INTERVAL '7 days' AND NEW.status = 'scheduled' THEN
--         -- Create admin notification
--         INSERT INTO public.admin_notifications (
--             title, message, type, priority, category, action_url, auto_generated
--         ) VALUES (
--             'Vehicle Maintenance Due',
--             format('Vehicle %s maintenance due on %s', NEW.vehicle_id, NEW.due_date),
--             'warning'::notification_type,
--             'medium'::priority_level,
--             'operations',
--             '/admin/vehicles',
--             true
--         );
--     END IF;

--     -- Check if maintenance is overdue
--     IF NEW.due_date < CURRENT_DATE AND NEW.status = 'scheduled' THEN
--         -- Create high priority notification
--         INSERT INTO public.admin_notifications (
--             title, message, type, priority, category, action_url, auto_generated
--         ) VALUES (
--             'Vehicle Maintenance Overdue',
--             format('Vehicle %s maintenance is overdue since %s', NEW.vehicle_id, NEW.due_date),
--             'error'::notification_type,
--             'high'::priority_level,
--             'operations',
--             '/admin/vehicles',
--             true
--         );
--     END IF;

--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

--  Create trigger for maintenance due date checking
-- -- DROP TRIGGER IF EXISTS trigger_maintenance_notifications ON public.vehicle_maintenance;
-- -- CREATE TRIGGER trigger_maintenance_notifications
-- --     AFTER INSERT OR UPDATE ON public.vehicle_maintenance
-- --     FOR EACH ROW EXECUTE PROCEDURE public.check_maintenance_due_dates();

--  ==========================================
--  6. CLEANUP FUNCTIONS
--  ==========================================

--  Function to cleanup expired data
-- -- CREATE OR REPLACE FUNCTION public.cleanup_expired_data()
-- -- RETURNS TABLE (
-- --     notifications_cleaned INTEGER,
-- --     sessions_cleaned INTEGER,
-- --     locks_released INTEGER
-- -- ) AS $$
-- -- DECLARE
-- --     v_notifications_cleaned INTEGER := 0;
-- --     v_sessions_cleaned INTEGER := 0;
-- --     v_locks_released INTEGER := 0;
-- -- BEGIN
-- --     -- Clean expired notifications
-- --     DELETE FROM public.notifications
-- --     WHERE expires_at IS NOT NULL AND expires_at < CURRENT_TIMESTAMP;
-- --     GET DIAGNOSTICS v_notifications_cleaned = ROW_COUNT;

-- --     -- Clean expired admin sessions
-- --     UPDATE public.admin_sessions
-- --     SET is_active = false, logout_time = CURRENT_TIMESTAMP
-- --     WHERE is_active = true AND expires_at < CURRENT_TIMESTAMP;
-- --     GET DIAGNOSTICS v_sessions_cleaned = ROW_COUNT;

-- --     -- Release expired seat locks
-- --     UPDATE public.seats
-- --     SET is_locked = false, locked_until = NULL, updated_at = CURRENT_TIMESTAMP
-- --     WHERE is_locked = true AND locked_until < CURRENT_TIMESTAMP;
-- --     GET DIAGNOSTICS v_locks_released = ROW_COUNT;

-- --     RETURN QUERY SELECT v_notifications_cleaned, v_sessions_cleaned, v_locks_released;
-- -- END;
-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;

--  ==========================================
--  Functions and Triggers Setup Complete
--  ==========================================
--  Next: Run 15_indexes.sql for additional performance optimizations
