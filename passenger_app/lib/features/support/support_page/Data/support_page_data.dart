import 'package:flutter/material.dart';
import 'package:youbook/core/images/app_images.dart';

class HelpSupportData {
  // List of support tiles with labels, icons, and optional callbacks
  final List<SupportTileItem> supportTiles = [
    SupportTileItem(label: "Contact Us", asset: AppImages.contact),
    SupportTileItem(label: "FAQs", asset: AppImages.faq),
    SupportTileItem(label: "Terms & Conditions", asset: AppImages.terms),
    SupportTileItem(label: "Privacy Policy", asset: AppImages.privacy),
    SupportTileItem(label: "About App", asset: AppImages.about),
    SupportTileItem(label: "Invite Friend", asset: AppImages.invite),
    SupportTileItem(label: "Rate App", asset: AppImages.rate),
    SupportTileItem(label: "Feedback", asset: AppImages.feedback),
  ];
}

class SupportTileItem {
  final String label;
  final String asset;
  VoidCallback? onTap;

  SupportTileItem({required this.label, required this.asset, this.onTap});
}
