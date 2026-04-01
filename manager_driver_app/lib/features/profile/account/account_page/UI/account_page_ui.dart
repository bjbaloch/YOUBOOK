import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../account_page/Data/account_page_data.dart';
import '../../account_page/Logic/account_page_logic.dart';
import '../../edit_profile/UI/update_profile_ui.dart';
import '../../../change_phone_number/change_pn_page/UI/change_phone_dialog_ui.dart';
import '../../../change_email/change_email_page/UI/change_email_dialog_ui.dart';
import '../../../change_password/change_password_page/UI/change_password_page_ui.dart';
import '../../../../../core/widgets/logout_dialog.dart';

class AccountPageUI extends StatelessWidget {
  const AccountPageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) => const _AccountPageContent(),
    );
  }
}

class _AccountPageContent extends StatefulWidget {
  const _AccountPageContent();

  @override
  State<_AccountPageContent> createState() => _AccountPageUIState();
}

class _AccountPageUIState extends State<_AccountPageContent>
    with SingleTickerProviderStateMixin {
  final AccountLogic _logic = AccountLogic();
  AccountData _data = AccountData();
  bool _loading = true;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _loadUser();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    AccountData data;
    if (user != null) {
      data = AccountData(
        fullName: user.fullName,
        email: user.email,
        phone: null,
        cnic: null,
        avatarUrl: null,
      );
    } else {
      data = await _logic.loadUser(null);
    }
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
    _animCtrl.forward(from: 0);
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(ColorScheme cs) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: AppBar(
        toolbarHeight: 56,
        backgroundColor: cs.primary,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: cs.onPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Account',
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Manage your profile',
              style: TextStyle(
                color: cs.onPrimary.withOpacity(0.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Header ─────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(ColorScheme cs) {
    final initials = _data.initials;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          // Avatar with ring
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: cs.onPrimary.withOpacity(0.6), width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: cs.onPrimary.withOpacity(0.2),
                  backgroundImage:
                      (_data.avatarUrl != null && _data.avatarUrl!.isNotEmpty)
                          ? NetworkImage(_data.avatarUrl!)
                          : null,
                  child: (_data.avatarUrl == null || _data.avatarUrl!.isEmpty)
                      ? Text(
                          initials,
                          style: TextStyle(
                            color: cs.onPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.onPrimary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _data.displayName,
            style: TextStyle(
              color: cs.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _data.email ?? '',
            style: TextStyle(
              color: cs.onPrimary.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          // Edit Profile button
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (_) => const EditProfilePageUI()))
                .then((_) => _loadUser()),
            icon: Icon(Icons.edit_rounded, size: 16, color: cs.onPrimary),
            label: Text(
              'Edit Profile',
              style: TextStyle(
                  color: cs.onPrimary, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.onPrimary.withOpacity(0.6)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Info Card ───────────────────────────────────────────────────────────────
  Widget _buildInfoCard(ColorScheme cs) {
    final fields = [
      _InfoRow(icon: Icons.badge_rounded, label: 'CNIC', value: _data.cnic),
      _InfoRow(icon: Icons.phone_rounded, label: 'Phone', value: _data.phone),
      _InfoRow(
          icon: Icons.location_on_rounded,
          label: 'Address',
          value: _data.address),
      _InfoRow(
          icon: Icons.location_city_rounded,
          label: 'City',
          value: _data.city),
      _InfoRow(
          icon: Icons.map_rounded,
          label: 'State / Province',
          value: _data.stateProvince),
      _InfoRow(
          icon: Icons.flag_rounded, label: 'Country', value: _data.country),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.onBackground.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(fields.length, (i) {
          final f = fields[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(f.icon, color: cs.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.label,
                            style: TextStyle(
                              color: cs.onSurface.withOpacity(0.5),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            (f.value != null && f.value!.isNotEmpty)
                                ? f.value!
                                : '—',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < fields.length - 1)
                Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 16,
                  color: cs.onSurface.withOpacity(0.07),
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Section Label ────────────────────────────────────────────────────────────
  Widget _sectionLabel(String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: cs.onBackground.withOpacity(0.45),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ── Action Tile ──────────────────────────────────────────────────────────────
  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    bool isLast = false,
    required ColorScheme cs,
  }) {
    final color = iconColor ?? cs.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isLast ? Radius.zero : Radius.zero,
        bottom: isLast ? const Radius.circular(18) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: iconColor ?? cs.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurface.withOpacity(0.35), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(ColorScheme cs) {
    final actions = [
      _ActionItem(
        icon: Icons.phone_iphone_rounded,
        label: 'Change Phone Number',
        onTap: () => ChangePhoneDialogUI.show(context),
      ),
      _ActionItem(
        icon: Icons.alternate_email_rounded,
        label: 'Change Email Address',
        onTap: () => ChangeEmailDialogUI.show(context),
      ),
      _ActionItem(
        icon: Icons.lock_outline_rounded,
        label: 'Change Password',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChangePasswordPageUI()),
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.onBackground.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(actions.length, (i) {
          final a = actions[i];
          return Column(
            children: [
              _actionTile(
                icon: a.icon,
                label: a.label,
                onTap: a.onTap,
                isLast: i == actions.length - 1,
                cs: cs,
              ),
              if (i < actions.length - 1)
                Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 16,
                  color: cs.onSurface.withOpacity(0.07),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutCard(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.onBackground.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _actionTile(
          icon: Icons.logout_rounded,
          label: 'Log out',
          iconColor: cs.error,
          onTap: () => LogoutDialog.show(context),
          isLast: true,
          cs: cs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: _buildAppBar(cs),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildHeroHeader(cs),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel('Profile Info', cs),
                            _buildInfoCard(cs),
                            const SizedBox(height: 20),
                            _sectionLabel('Settings', cs),
                            _buildActionsCard(cs),
                            const SizedBox(height: 20),
                            _sectionLabel('Session', cs),
                            _buildLogoutCard(cs),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Data helpers ──────────────────────────────────────────────────────────────
class _InfoRow {
  final IconData icon;
  final String label;
  final String? value;
  const _InfoRow({required this.icon, required this.label, this.value});
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionItem(
      {required this.icon, required this.label, required this.onTap});
}
