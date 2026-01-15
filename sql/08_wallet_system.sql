 ==========================================
 YOUBOOK Wallet & Payment System
 Production-ready financial transaction management
 ==========================================
 Tables: wallets, wallet_transactions
 Features: Balance management, transaction history, payment processing
 ==========================================

 ==========================================
 1. WALLETS TABLE
 ==========================================

 Wallets table for user balances
-- CREATE TABLE IF NOT EXISTS public.wallets (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     balance DECIMAL(12,2) DEFAULT 0.00 NOT NULL,
--     total_credited DECIMAL(12,2) DEFAULT 0.00 NOT NULL,
--     total_debited DECIMAL(12,2) DEFAULT 0.00 NOT NULL,
--     is_active BOOLEAN DEFAULT true NOT NULL,
--     auto_reload_enabled BOOLEAN DEFAULT false NOT NULL,
--     auto_reload_amount DECIMAL(8,2) DEFAULT 0.00,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL,
--     UNIQUE(user_id)
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON public.wallets(user_id);
-- CREATE INDEX IF NOT EXISTS idx_wallets_balance ON public.wallets(balance);
-- CREATE INDEX IF NOT EXISTS idx_wallets_is_active ON public.wallets(is_active);

 ==========================================
 2. WALLET TRANSACTIONS TABLE
 ==========================================

 Wallet transactions for audit trail
-- CREATE TABLE IF NOT EXISTS public.wallet_transactions (
--     id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
--     wallet_id UUID REFERENCES public.wallets(id) ON DELETE CASCADE NOT NULL,
--     amount DECIMAL(10,2) NOT NULL,
--     type TEXT CHECK (type IN ('credit', 'debit')) NOT NULL,
--     description TEXT NOT NULL,
--     reference_type TEXT,  -- 'booking', 'refund', 'topup', 'commission'
--     reference_id UUID,  -- Reference to booking, etc.
--     balance_before DECIMAL(12,2) NOT NULL,
--     balance_after DECIMAL(12,2) NOT NULL,
--     payment_method TEXT,  -- For credits: card, bank_transfer, etc.
--     external_reference TEXT,  -- Payment gateway reference
--     processed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,  -- Admin who processed
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, now()) NOT NULL
-- );

 Add indexes for performance
-- CREATE INDEX IF NOT EXISTS idx_wallet_transactions_wallet_id ON public.wallet_transactions(wallet_id);
-- CREATE INDEX IF NOT EXISTS idx_wallet_transactions_type ON public.wallet_transactions(type);
-- CREATE INDEX IF NOT EXISTS idx_wallet_transactions_reference_type ON public.wallet_transactions(reference_type);
-- CREATE INDEX IF NOT EXISTS idx_wallet_transactions_reference_id ON public.wallet_transactions(reference_id);
-- CREATE INDEX IF NOT EXISTS idx_wallet_transactions_created_at ON public.wallet_transactions(created_at DESC);

 ==========================================
 3. UPDATE TIMESTAMP TRIGGER
 ==========================================

 Update timestamp trigger for wallets
-- DROP TRIGGER IF EXISTS update_wallets_updated_at ON public.wallets;
-- CREATE TRIGGER update_wallets_updated_at
--     BEFORE UPDATE ON public.wallets
--     FOR EACH ROW EXECUTE PROCEDURE public.update_updated_at_column();

 ==========================================
 Wallet System Setup Complete
 ==========================================
 Next: Run 09_notifications.sql to create notification system
