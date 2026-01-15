import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/models/user.dart';
import '../../../../../screens/passenger/Home/Data/passenger_home_data.dart';
import '../../../../../screens/passenger/Home/UI/passenger_home_ui.dart';
import '../../../../../screens/manager/Home/Data/manager_home_data.dart';
import '../../../../../screens/manager/Home/UI/manager_home_ui.dart';
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
      builder: (context, authProvider, child) {
        return _AccountPageContent(currentUser: authProvider.user);
      },
    );
  }
}

class _AccountPageContent extends StatefulWidget {
  final UserModel? currentUser;

  const _AccountPageContent({this.currentUser});

  @override
  State<_AccountPageContent> createState() => _AccountPageUIState();
}

class _AccountPageUIState extends State<_AccountPageContent> {
  final AccountLogic _logic = AccountLogic();
  AccountData _data = AccountData();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _loading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final data = await _logic.loadUser(authProvider.user);
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: const Size.fromHeight(45),
      child: AppBar(
        toolbarHeight: 45,
        backgroundColor: cs.primary,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
          onPressed: () async {
            // Get current user's role from database
            try {
              final currentUser = Supabase.instance.client.auth.currentUser;
              if (currentUser != null) {
                final profileResponse = await Supabase.instance.client
                    .from('profiles')
                    .select('role')
                    .eq('id', currentUser.id)
                    .single();

                final role = profileResponse['role'] as String?;
                Widget targetScreen;

                if (role == 'manager') {
                  targetScreen = const ManagerHomeUI(data: ManagerHomeData());
                } else {
                  targetScreen = const PassengerHomeUI(
                    data: PassengerHomeData(),
                  );
                }

                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => targetScreen),
                  );
                }
              }
            } catch (e) {
              // Fallback to passenger home on error
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        const PassengerHomeUI(data: PassengerHomeData()),
                  ),
                );
              }
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Account',
          style: TextStyle(color: cs.onPrimary, fontSize: 20),
        ),
      ),
    );
  }

  Widget _profileHeaderCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cs.onPrimary,
            backgroundImage:
                (_data.avatarUrl != null && _data.avatarUrl!.isNotEmpty)
                ? NetworkImage(_data.avatarUrl!)
                : null,
            child: (_data.avatarUrl == null || _data.avatarUrl!.isEmpty)
                ? Icon(Icons.person, color: cs.primary, size: 50)
                : null,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.person,
            text: _data.fullName ?? 'Full Name',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.badge,
            text: _data.cnic ?? 'CNIC',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.phone,
            text: _data.phone ?? 'Phone number',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.email_outlined,
            text: _data.email ?? 'Email',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.location_on,
            text: _data.address ?? 'Address',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.location_city,
            text: _data.city ?? 'City',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.map_outlined,
            text: _data.stateProvince ?? 'State/Province',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          _roField(
            context,
            icon: Icons.flag_outlined,
            text: _data.country ?? 'Country',
            isPrimaryOn: true,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePageUI(),
                      ),
                    )
                    .then((_) => _loadUser());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.secondary,
                foregroundColor: cs.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
              ),
              child: const Text('Edit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roField(
    BuildContext context, {
    required IconData icon,
    required String text,
    bool isPrimaryOn = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isPrimaryOn ? cs.onPrimary : cs.onSurface).withOpacity(0.55),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: (isPrimaryOn ? cs.onPrimary : cs.onSurface).withOpacity(0.9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isPrimaryOn ? cs.onPrimary : cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? customColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(14),
      elevation: 4,
      shadowColor: cs.onSurface.withOpacity(0.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: customColor ?? cs.onSurface.withOpacity(0.85)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: customColor ?? cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurface.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: _appBar(context),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 18),
                child: Column(
                  children: [
                    _profileHeaderCard(context),
                    const SizedBox(height: 12),
                    _actionTile(
                      icon: Icons.phone_iphone_rounded,
                      label: 'Change Phone number',
                      onTap: () => ChangePhoneDialogUI.show(context),
                    ),
                    const SizedBox(height: 10),
                    _actionTile(
                      icon: Icons.alternate_email_rounded,
                      label: 'Change Email Address',
                      onTap: () => ChangeEmailDialogUI.show(context),
                    ),
                    const SizedBox(height: 10),
                    _actionTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPageUI(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _actionTile(
                      icon: Icons.logout_rounded,
                      label: 'Log out',
                      customColor: cs.error,
                      onTap: () => LogoutDialog.show(
                        context,
                        currentScreen: 'passenger',
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
