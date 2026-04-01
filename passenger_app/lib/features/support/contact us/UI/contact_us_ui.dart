import 'package:youbook/features/support/contact us/Data/contact_us_data.dart';
import 'package:youbook/features/support/contact us/Logic/contact_us_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youbook/core/theme/app_colors.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  IconData _getIconForContactType(String type) {
    switch (type) {
      case 'phone':
        return Icons.phone;
      case 'whatsapp':
        return Icons.message; // WhatsApp icon
      case 'email':
        return Icons.email;
      default:
        return Icons.contact_support;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ContactUsData();
    final logic = ContactUsLogic();
    final cs = Theme.of(context).colorScheme;

    Widget contactCard(Map<String, String> contact) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        color: cs.surface,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconForContactType(contact['type']!),
                    size: 28,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    contact['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textWhite : AppColors.textBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                contact['description']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppColors.textWhite : AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 18, color: AppColors.blue),
                  const SizedBox(width: 6),
                  Text(contact['detail']!, style: const TextStyle(color: AppColors.blue)),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: AppColors.textWhite,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    switch (contact['type']) {
                      case 'phone':
                        logic.launchPhone(data.phoneNumber);
                        break;
                      case 'whatsapp':
                        logic.launchWhatsApp(data.phoneNumber);
                        break;
                      case 'email':
                        logic.launchEmail(data.email);
                        break;
                    }
                  },
                  child: Text(contact['buttonText']!, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        toolbarHeight: 45,
        backgroundColor: cs.primary,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
          onPressed: () => logic.navigateBack(context),
        ),
        centerTitle: true,
        title: Text(
          "Contact Us",
          style: TextStyle(
            color: cs.onPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 6),
            child: Text(
              "Contact to our support team directly.",
              style: TextStyle(color: cs.onSurface),
            ),
          ),
          ...data.contacts.map(contactCard).toList(),
        ],
      ),
    );
  }
}
