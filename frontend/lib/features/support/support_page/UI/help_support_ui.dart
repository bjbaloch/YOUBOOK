import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youbook/screens/manager/Home/Data/manager_home_data.dart';
import 'package:youbook/screens/manager/Home/UI/manager_home_ui.dart';
import 'package:youbook/features/support/support_page/Data/support_page_data.dart';
import 'package:youbook/features/support/support_page/Logic/support_page_logic.dart';
import 'package:youbook/features/support/terms_conditions/UI/terms_conditions_ui.dart';
import 'package:youbook/features/support/privacy_policy/UI/privacy_policy_ui.dart';
import 'package:youbook/features/support/faqs/UI/faqs_ui.dart';
import 'package:youbook/features/support/about_app/UI/about_app_ui.dart';
import 'package:youbook/features/support/contact us/UI/contact_us_ui.dart';
import 'package:youbook/features/support/feedback/feedback_popup/UI/feedback_popup_ui.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  Widget _supportTile(
    BuildContext context,
    String label,
    String assetPath,
    VoidCallback? onTap,
  ) {
    final cs = Theme.of(context).colorScheme;

    // Map asset paths to appropriate icons
    IconData getIconForAsset(String asset) {
      if (asset.contains('contact')) return Icons.phone;
      if (asset.contains('faq')) return Icons.question_answer;
      if (asset.contains('terms')) return Icons.description;
      if (asset.contains('privacy')) return Icons.security;
      if (asset.contains('about')) return Icons.info;
      if (asset.contains('invite')) return Icons.share;
      if (asset.contains('rate')) return Icons.star;
      if (asset.contains('feedback')) return Icons.feedback;
      return Icons.help; // Default icon
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  getIconForAsset(assetPath),
                  color: cs.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: cs.onSurface, fontSize: 15),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = HelpSupportData();
    final logic = HelpSupportLogic();

    // Assign proper navigation for tiles
    data.supportTiles[0].onTap = () => Navigator.of(context)
        .push(logic.smoothRoute(const ContactUsPage()));
    data.supportTiles[1].onTap =
        () => Navigator.of(context).push(logic.smoothRoute(const FAQsPage()));
    data.supportTiles[2].onTap = () => Navigator.of(context)
        .push(logic.smoothRoute(const TermsAndConditionsPage()));
    data.supportTiles[3].onTap = () => Navigator.of(context)
        .push(logic.smoothRoute(const PrivacyPolicyPage()));
    data.supportTiles[4].onTap =
        () => Navigator.of(context).push(logic.smoothRoute(const AboutAppPage()));
    data.supportTiles[7].onTap = () => showFeedbackPopup(context);

    return WillPopScope(
      onWillPop: () => logic.handleBackPress(context),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            toolbarHeight: 45,
            backgroundColor: cs.primary,
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () =>
                  Navigator.of(context).pushReplacement(logic.smoothRoute(const ManagerHomeUI(data: const ManagerHomeData()))),
            ),
            centerTitle: true,
            title: Text(
              "Help & Support",
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "We are here to help you !",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 10),
              ...data.supportTiles
                  .map((tile) => _supportTile(context, tile.label, tile.asset, tile.onTap))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder classes for support pages (Contact Us now implemented)
