import 'package:flutter/material.dart';
import '../../../../screens/passenger/Home/UI/passenger_home_ui.dart';
import '../../../../screens/passenger/Home/Data/passenger_home_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../topup_wallet/UI/topup_ui.dart';
import '../Logic/yb_wallet_logic.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletLogic logic = WalletLogic();

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PassengerHomeUI(data: PassengerHomeData()),
      ),
    );
    return false; // Prevents default back action
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = logic.data;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: AppColors.lightSeaGreen,
          toolbarHeight: 45,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textWhite,
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PassengerHomeUI(data: PassengerHomeData())),
            ),
          ),
          title: const Text(
            "Welcome to YouBook Wallet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Wallet Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9B44), Color(0xFFFF6433)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Wallet Balance",
                      style: TextStyle(
                        color: AppColors.hintWhite,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      logic.getFormattedBalance(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // Top-up Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.lightSeaGreen
                        : Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: data.isLoading
                      ? null
                      : () => logic.startTopUp(context, () async {
                          if (!mounted) return;
                          await Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const TopupAccountsPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(0.0, 1.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeOutCubic;
                                    final tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 500,
                              ),
                            ),
                          );
                        }, () => setState(() {})),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: data.isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.textWhite,
                            ),
                          )
                        : const Text(
                            "Add / Top-up YouBook Wallet",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton("Transaction History", 0, cs),
                  _buildTabButton("Pending", 1, cs),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Divider(
                  thickness: 1,
                  color: isDark
                      ? AppColors.textWhite.withOpacity(0.15)
                      : AppColors.textBlack.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: 20),

              // Transaction List
              Expanded(
                child: _buildTransactionList(cs, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, ColorScheme cs) {
    final data = logic.data;
    return GestureDetector(
      onTap: () => logic.selectTab(index, () => setState(() {})),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: data.selectedTab == index
                  ? cs.onSurface
                  : cs.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 3),
          if (data.selectedTab == index)
            SizedBox(
              width: label == "Pending" ? 60 : 70,
              child: const Divider(thickness: 3, color: AppColors.accentOrange),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(ColorScheme cs, bool isDark) {
    final items = logic.data.getFilteredItems();

    if (items.isEmpty) {
      return Center(
        child: Text(
          logic.data.selectedTab == 0
              ? "No transactions yet."
              : "No pending items.",
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.6),
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildTransactionCard(item, cs, isDark);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> item, ColorScheme cs, bool isDark) {
    final isCredit = item['type'] == 'credit';
    final amount = item['amount'] as double;
    final description = item['description'] as String;
    final date = item['date'] as DateTime;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCredit ? AppColors.successGreen.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isCredit ? Icons.add : Icons.remove,
                color: isCredit ? AppColors.successGreen : AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isCredit ? '+' : '-'}PKR ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isCredit ? AppColors.successGreen : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
