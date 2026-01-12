import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../Logic/topup_logic.dart';

class TopupAccountsPage extends StatefulWidget {
  const TopupAccountsPage({super.key});

  @override
  State<TopupAccountsPage> createState() => _TopupAccountsPageState();
}

class _TopupAccountsPageState extends State<TopupAccountsPage> {
  final TopupLogic logic = TopupLogic();

  @override
  void initState() {
    super.initState();
    logic.data.amountController.addListener(() => logic.updateTopupAmount(() => setState(() {})));
  }

  @override
  void dispose() {
    logic.data.amountController.removeListener(() => logic.updateTopupAmount(() => setState(() {})));
    logic.data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = logic.data;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          backgroundColor: AppColors.lightSeaGreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textWhite),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Topup Accounts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textWhite),
          ),
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                children: [
                  Icon(Icons.payment, size: 42, color: AppColors.accentOrange),
                  const SizedBox(height: 8),
                  Text(
                    'Select Payment Method',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onBackground),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Topup your Youbook Wallet with your payment methods.',
                style: TextStyle(fontSize: 14, color: cs.onBackground.withOpacity(0.8)),
              ),
              const SizedBox(height: 10),

              // Amount input
              TextFormField(
                controller: data.amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppColors.textBlack : AppColors.dialogBg,
                  labelText: 'Enter amount',
                  labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.8)),
                  prefixText: 'Rs. ',
                  errorText: data.amountError,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: AppColors.accentOrange, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: cs.onSurface.withOpacity(0.3), width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Payment Methods',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onBackground),
              ),
              const SizedBox(height: 16),

              _buildPaymentMethodTile(context, 'Easypaisa', 'assets/topup_accounts/easypaisa.png'),
              const SizedBox(height: 16),
              _buildPaymentMethodTile(context, 'JazzCash', 'assets/topup_accounts/jazzcash_logo.png'),
              const SizedBox(height: 16),
              _buildPaymentMethodTile(context, 'Debit / Visa Card', 'assets/topup_accounts/visa_card.png'),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(BuildContext context, String method, String logoAssetPath) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = logic.data;
    final bool isSelected = data.selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () => logic.handlePaymentTap(context, method, () => setState(() {})),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1D1F) : AppColors.dialogBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.accentOrange : cs.onSurface.withOpacity(0.2), width: isSelected ? 2.0 : 1.0),
          boxShadow: [
            if (isSelected)
              BoxShadow(color: AppColors.accentOrange.withOpacity(0.25), blurRadius: 6, spreadRadius: 2),
            BoxShadow(
              color: isDark ? AppColors.textBlack.withOpacity(0.1) : AppColors.grey.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  logoAssetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to first letter if image fails to load
                    return Center(
                      child: Text(
                        method.substring(0, 1),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Text(
                method,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.circleGreen : cs.onSurface
                ),
              ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.check_circle, color: AppColors.circleGreen, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
