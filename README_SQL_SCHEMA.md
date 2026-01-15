# YOUBOOK Production Database Schema

## 📋 Overview

This is a comprehensive, production-ready PostgreSQL schema for the YOUBOOK transportation platform. The schema supports both the Flutter admin app and passenger app with full data integrity, security, and scalability for millions of users.

## 🗂️ File Structure

```
sql/
├── 00_extensions_and_setup.sql     # Extensions, custom types, configuration
├── 01_core_users.sql               # profiles, manager_applications
├── 02_services.sql                 # transport/accommodation/rental services
├── 03_routes.sql                   # geographic routes and locations
├── 04_vehicles.sql                 # fleet management, seats, maintenance
├── 05_drivers.sql                  # driver profiles, licenses, ratings
├── 06_schedules.sql                # trip schedules, availability
├── 07_bookings.sql                 # passenger bookings, seat assignments
├── 08_wallet_system.sql            # payments, transactions, balances
├── 09_notifications.sql            # push notifications, FCM tokens
├── 10_fleet_management.sql         # GPS tracking, analytics
├── 11_communication.sql            # chat, conversation reports
├── 12_admin_system.sql             # sessions, audit logs, settings
├── 13_security_policies.sql        # Row Level Security (RLS) policies
├── 14_functions_and_triggers.sql   # automation functions
├── 15_indexes.sql                  # performance optimization

└── 17_views_and_analytics.sql      # dashboards, reporting views
```

## 🚀 Quick Setup

### Prerequisites
- Supabase PostgreSQL database
- Admin access to SQL Editor

### Installation Steps

1. **Run files in order** (numbers indicate execution sequence):
```bash
# Connect to your Supabase SQL Editor and run each file
psql -h your-db-host -U postgres -d postgres -f sql/00_extensions_and_setup.sql
psql -h your-db-host -U postgres -d postgres -f sql/01_core_users.sql
# ... continue with all files in numerical order
```

2. **Alternative: Run all at once** (if your client supports it):
```bash
cat sql/*.sql | psql -h your-db-host -U postgres -d postgres
```

## 📊 Database Tables Summary

### Core System (23 Tables)
- **Users & Auth**: `profiles`, `manager_applications`
- **Services**: `services`, `routes`, `vehicles`, `seats`
- **Operations**: `drivers`, `schedules`, `bookings`, `booking_seats`
- **Financial**: `wallets`, `wallet_transactions`
- **Communication**: `notifications`, `user_fcm_tokens`, `chat_conversations`, `chat_messages`
- **Admin**: `admin_sessions`, `admin_audit_logs`, `admin_notifications`, `admin_settings`
- **Fleet**: `vehicle_locations`, `vehicle_status`, `vehicle_maintenance`, `driver_alerts`

### Key Features

#### ✅ **Currently Working Features:**
- **Row Level Security (RLS)** on all tables
- **Optimized indexes** for million-user scale
- **Foreign key constraints** for data integrity
- **Audit trails** for admin actions
- **Real-time user signup** with automatic profile creation
- **Multi-role system** (passenger, manager, driver, admin)
- **Booking system** with seat locking and payments
- **Wallet system** with transaction history
- **Communication system** with chat and notifications
- **Analytics dashboards** for business insights

#### ❌ **Advanced Features (Add Later):**
- Real-time GPS tracking for vehicles
- Vehicle maintenance scheduling and alerts
- Driver alerts and notification system
- Advanced fleet analytics and reporting

#### 👥 User Management
- **Multi-role system**: passenger, manager, driver, admin
- **Automatic profile creation** from auth.users
- **Manager applications** workflow
- **Secure user data** with RLS policies

#### 🚗 Fleet Management
- **Vehicle tracking** with GPS coordinates
- **Seat management** with availability locking
- **Maintenance scheduling** and tracking
- **Driver assignments** and performance ratings

#### 🎫 Booking System
- **Real-time availability** calculation
- **Seat locking** for booking process
- **Payment integration** with wallet system
- **Manifest generation** for drivers

#### 💰 Financial System
- **Wallet balances** with transaction history
- **Automated commission** calculations
- **Payment gateway** integration ready
- **Audit trail** for all transactions

## 🔧 Configuration

### Environment Variables Required
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### Admin Setup
1. **Real-time User Signup**: Users signup through Flutter apps using Supabase Auth
2. **Create First Admin**: Signup with `"is_admin": true` in user metadata to create admin
3. **Automatic Profile Creation**: System creates profiles via database triggers
4. **Access Admin Panel**: Login and access admin features at `/admin`
5. **Configure Settings**: Use `admin_settings` table for system configuration

## 📈 Scalability Features

### Million-User Ready
- **UUID primary keys** (no sequential ID bottlenecks)
- **Partitioned indexes** for large tables
- **Connection pooling** ready
- **Read replicas** support

### Performance Optimizations
- **GIN indexes** for JSONB fields
- **Partial indexes** for active records
- **Composite indexes** for common queries
- **Function-based indexes** for computed fields

## 🔍 Monitoring & Analytics

### Included Views
- `admin_dashboard_stats` - Real-time dashboard metrics
- `fleet_status` - Live vehicle and driver status
- `booking_analytics` - Revenue and booking trends

### Key Metrics Tracked
- User registration and activity
- Booking conversion rates
- Fleet utilization
- Revenue and commission tracking
- Driver performance ratings

## 🛠️ Maintenance

### Regular Tasks
1. **Update statistics**: `ANALYZE` on large tables weekly
2. **Archive old data**: Move completed bookings to archive tables
3. **Clean audit logs**: Rotate logs based on retention policy
4. **Update indexes**: Reindex based on query patterns

### Backup Strategy
- **Daily automated backups** via Supabase
- **Point-in-time recovery** for critical data
- **Encrypted backups** for sensitive user data

## 🐛 Troubleshooting

### Common Issues

1. **RLS blocking queries**: Check user authentication and role assignments
2. **Foreign key violations**: Ensure data dependencies are met
3. **Performance issues**: Check query plans and add missing indexes

### Debug Queries
```sql
-- Check RLS policies
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';

-- View active connections
SELECT * FROM pg_stat_activity;

-- Check table sizes
SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del
FROM pg_stat_user_tables;
```

## 📞 Support

For issues with this schema:
1. Check the [Supabase documentation](https://supabase.com/docs)
2. Review PostgreSQL logs for errors
3. Validate data consistency with included views

## ✅ Compatibility

- **PostgreSQL 13+** (Supabase compatible)
- **PostGIS** ready for advanced location features
- **Flutter apps** fully compatible
- **REST API** ready for backend integration

---

**Last Updated**: January 2026
**Version**: 1.0.0
**Database**: Supabase PostgreSQL</content>
