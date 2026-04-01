part of manager_waiting_screen;

Widget _buildManagerWaitingUI(_ManagerWaitingScreenState state) {
  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.lightSeaGreen,
      elevation: 0,
      toolbarHeight: 56,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: OutlinedButton.icon(
            onPressed: () => SystemNavigator.pop(),
            icon: const Icon(Icons.exit_to_app_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Quit App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accentOrange, width: 1.5),
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.lightSeaGreen, AppColors.accentOrange],
            ),
          ),
        ),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          children: [
            // ── Hero section ──────────────────────────────────────
            _buildHeroSection(),

            const SizedBox(height: 24),

            // ── Success badge ─────────────────────────────────────
            _buildSuccessBadge(),

            const SizedBox(height: 24),

            // ── Timeline steps ────────────────────────────────────
            _buildTimelineCard(),

            const SizedBox(height: 24),

            // ── Support card ──────────────────────────────────────
            _buildSupportCard(state),

            const SizedBox(height: 28),

            // ── Check Status button ───────────────────────────────
            _buildCheckStatusButton(state),
          ],
        ),
      ),
    ),
  );
}

// ── Hero section ──────────────────────────────────────────────────────────────

Widget _buildHeroSection() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.lightSeaGreen,
          AppColors.lightSeaGreen.withOpacity(0.82),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.lightSeaGreen.withOpacity(0.35),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        // Animated-looking icon stack
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentOrange.withOpacity(0.18),
                border: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 34,
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Title
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: 0.2,
            ),
            children: [
              TextSpan(
                text: 'Application\n',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Under Review',
                style: TextStyle(color: AppColors.accentOrange),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Subtitle
        Text(
          'Your manager application has been submitted and is being reviewed by our team.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.85),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 10),

        Text(
          'You will receive an email notification within 48 hours once your application is approved. Please check your email regularly.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.65),
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ── Success badge ─────────────────────────────────────────────────────────────

Widget _buildSuccessBadge() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF16A34A).withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF16A34A),
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Application submitted successfully!',
            style: TextStyle(
              color: Color(0xFF15803D),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Timeline card ─────────────────────────────────────────────────────────────

Widget _buildTimelineCard() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: AppColors.lightSeaGreen.withOpacity(0.07),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.lightSeaGreen.withOpacity(0.12),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.lightSeaGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: AppColors.lightSeaGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'What happens next?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            children: [
              _buildTimelineStep(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF16A34A),
                iconBg: const Color(0xFFDCFCE7),
                title: 'Application Submitted',
                subtitle: 'Your details have been received by our team.',
                isDone: true,
                isLast: false,
              ),
              _buildTimelineStep(
                icon: Icons.manage_search_rounded,
                iconColor: AppColors.accentOrange,
                iconBg: const Color(0xFFFFF3CD),
                title: 'Under Review',
                subtitle: 'Our team is verifying your business information.',
                isDone: false,
                isLast: false,
                isActive: true,
              ),
              _buildTimelineStep(
                icon: Icons.mark_email_read_rounded,
                iconColor: AppColors.lightSeaGreen,
                iconBg: AppColors.lightSeaGreen.withOpacity(0.1),
                title: 'Email Notification',
                subtitle: 'You\'ll be notified within 48 hours.',
                isDone: false,
                isLast: false,
              ),
              _buildTimelineStep(
                icon: Icons.rocket_launch_rounded,
                iconColor: const Color(0xFF7C3AED),
                iconBg: const Color(0xFFEDE9FE),
                title: 'Get Started',
                subtitle: 'Access your manager dashboard after approval.',
                isDone: false,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTimelineStep({
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  required String title,
  required String subtitle,
  required bool isDone,
  required bool isLast,
  bool isActive = false,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Icon + line
      Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: iconColor, width: 2)
                  : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: iconColor.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          if (!isLast)
            Container(
              width: 2,
              height: 36,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDone
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFE5E7EB),
                    const Color(0xFFE5E7EB),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),

      const SizedBox(width: 14),

      // Text
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 20, top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? const Color(0xFF1A1A2E)
                          : isDone
                              ? const Color(0xFF374151)
                              : const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'In Progress',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDone || isActive
                      ? const Color(0xFF6B7280)
                      : const Color(0xFFB0B8C1),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ── Support card ──────────────────────────────────────────────────────────────

Widget _buildSupportCard(_ManagerWaitingScreenState state) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
          decoration: BoxDecoration(
            color: AppColors.lightSeaGreen.withOpacity(0.07),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.lightSeaGreen.withOpacity(0.12),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.lightSeaGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.support_agent_rounded,
                  color: AppColors.lightSeaGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
          child: Text(
            'Have any question or for more information contact to our support team.',
            style: TextStyle(
              fontSize: 13,
              color: const Color(0xFF6B7280),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          child: Column(
            children: [
              // Email
              _buildContactTile(
                icon: Icons.email_rounded,
                iconColor: AppColors.lightSeaGreen,
                iconBg: AppColors.lightSeaGreen.withOpacity(0.1),
                label: 'Email Us',
                value: 'youbook210@gmail.com',
                onTap: () async {
                  if (!kIsWeb) HapticFeedback.lightImpact();
                  try {
                    await launchUrl(
                      Uri.parse(
                        'mailto:youbook210@gmail.com?subject=YOUBOOK Manager Application Support&body=Hello YOUBOOK Support Team,%0A%0AI need assistance with my manager application.%0A%0ABest regards,',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (_) {
                    if (state.mounted) {
                      SnackBarUtils.showSnackBar(
                        state.context,
                        'Could not open email app. Please try manually.',
                        type: SnackBarType.error,
                      );
                    }
                  }
                },
              ),

              const SizedBox(height: 10),

              // WhatsApp
              _buildContactTile(
                icon: Icons.phone_rounded,
                iconColor: const Color(0xFF25D366),
                iconBg: const Color(0xFFDCFCE7),
                label: 'WhatsApp',
                value: '03171292355',
                onTap: () async {
                  if (!kIsWeb) HapticFeedback.lightImpact();
                  try {
                    await launchUrl(
                      Uri.parse('https://wa.me/923171292355'),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (_) {
                    if (state.mounted) {
                      SnackBarUtils.showSnackBar(
                        state.context,
                        'Could not open WhatsApp. Please try manually.',
                        type: SnackBarType.error,
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildContactTile({
  required IconData icon,
  required Color iconColor,
  required Color iconBg,
  required String label,
  required String value,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.lightSeaGreen.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.lightSeaGreen,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Check Status button ───────────────────────────────────────────────────────

Widget _buildCheckStatusButton(_ManagerWaitingScreenState state) {
  return SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: state._isLoading ? null : state._checkVerificationStatus,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentOrange,
        disabledBackgroundColor: AppColors.accentOrange.withOpacity(0.5),
        elevation: 3,
        shadowColor: AppColors.accentOrange.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: state._isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'Check Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
    ),
  );
}
