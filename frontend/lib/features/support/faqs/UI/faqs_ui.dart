import 'package:youbook/features/support/faqs/Data/faqs_data.dart';
import 'package:youbook/features/support/faqs/Logic/faqs_logic.dart';
import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';

class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = FAQsData();
    final logic = FAQsLogic();
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          backgroundColor: cs.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
            onPressed: () => logic.navigateBack(context),
          ),
          centerTitle: true,
          title: Text(
            "FAQs",
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
