import 'package:youbook/features/support/terms_conditions/Data/terms_conditions_data.dart';
import 'package:youbook/features/support/terms_conditions/Logic/terms_conditions_logic.dart';
import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = TermsConditionsData();
    final logic = TermsConditionsLogic();

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          backgroundColor: cs.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () => logic.handleBackPress(context),
          ),
          centerTitle: true,
          title: Text(
            "Terms & Conditions",
            style: TextStyle(
              fontSize: 20,
              color: cs.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            data.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? AppColors.textWhite : AppColors.textBlack,
            ),
          ),
        ),
      ),
    );
  }
}
