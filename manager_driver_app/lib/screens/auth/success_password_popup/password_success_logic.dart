part of password_success_popup;

class SuccessPopup extends StatefulWidget {
  const SuccessPopup({super.key});

  @override
  State<SuccessPopup> createState() => _SuccessPopupState();
}

class _SuccessPopupState extends State<SuccessPopup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showPasswordSuccessDialog(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Transparent scaffold — dialog sits on top
    return const Scaffold(backgroundColor: Colors.transparent);
  }
}
