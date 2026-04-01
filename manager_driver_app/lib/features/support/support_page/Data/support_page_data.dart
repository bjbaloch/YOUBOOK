import 'package:flutter/material.dart';

class HelpSupportData {
  // List of support tiles with labels, icons, and optional callbacks
  final List<SupportTileItem> supportTiles = [
    SupportTileItem(label: "Contact Us", icon: Icons.contact_support),
    SupportTileItem(label: "FAQs", icon: Icons.help),
    SupportTileItem(label: "Terms & Conditions", icon: Icons.description),
    SupportTileItem(label: "Privacy Policy", icon: Icons.security),
    SupportTileItem(label: "About App", icon: Icons.info),
    SupportTileItem(label: "Invite Friend", icon: Icons.group_add),
    SupportTileItem(label: "Rate App", icon: Icons.star),
    SupportTileItem(label: "Feedback", icon: Icons.feedback),
  ];
}

class SupportTileItem {
  final String label;
  final IconData icon;
  VoidCallback? onTap;

  SupportTileItem({required this.label, required this.icon, this.onTap});
}
