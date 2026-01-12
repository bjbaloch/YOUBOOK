import 'package:youbook/features/support/support_page/UI/help_support_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class ContactUsLogic {
  Future<void> launchPhone(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber");
    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Future<void> launchEmail(String email) async {
    final Uri emailUrl = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support Request&body=Hello Support Team,',
    );
    if (!await launchUrl(emailUrl)) {
      throw 'Could not launch $emailUrl';
    }
  }

  void navigateBack(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HelpSupportPage()),
    );
  }
}
