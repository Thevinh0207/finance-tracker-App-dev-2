import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../Model/User.dart';
import '../Model/UserSettings.dart';
import '../Repository/UserSettingsRepository.dart';
import 'loginPage.dart';

class ProfileSettingsPage extends StatefulWidget {
  final User user;
  const ProfileSettingsPage({super.key, required this.user});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final UserSettingsRepository _repo = UserSettingsRepository();
  UserSettings? _settings;
  bool _loading = true;

  bool get _darkMode => _settings?.darkMode ?? false;
  bool get _twoFactorEnabled => _settings?.twoFactorEnabled ?? false;
  String get _language => _settings?.language ?? 'English';

  static const _languages = <String>[
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Vietnamese',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await _repo.getOrCreate(widget.user.userID);
    if (!mounted) return;
    setState(() {
      _settings = s;
      _loading = false;
    });
  }

  Future<void> _update(UserSettings next) async {
    if (!mounted) return;
    setState(() => _settings = next);
    try {
      await _repo.save(next);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await fb.FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => loginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFF4F6FA),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              SizedBox(height: 24),
              _buildSection('Account', [
                _NavItem(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () {},
                ),
                _NavItem(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () {},
                ),
                _ToggleItem(
                  icon: Icons.shield_outlined,
                  label: 'Two-Factor Authentication',
                  value: _twoFactorEnabled,
                  onChanged: (v) =>
                      _update(_settings!.copyWith(twoFactorEnabled: v)),
                ),
              ]),
              SizedBox(height: 16),
              _buildSection('Preferences', [
                _NavItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {},
                ),
                _ToggleItem(
                  icon: Icons.color_lens_outlined,
                  label: 'Dark Mode',
                  value: _darkMode,
                  onChanged: (v) =>
                      _update(_settings!.copyWith(darkMode: v)),
                ),
                _DropdownItem(
                  icon: Icons.language_outlined,
                  label: 'Language',
                  value: _language,
                  options: _languages,
                  onChanged: (v) {
                    if (v != null) {
                      _update(_settings!.copyWith(language: v));
                    }
                  },
                ),
              ]),
              SizedBox(height: 16),
              _buildSection('Support', [
                _NavItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {},
                ),
                _NavItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                _NavItem(
                  icon: Icons.info_outline,
                  label: 'About',
                  onTap: () {},
                ),
              ]),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE53935),
                  minimumSize: Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProfileHeader() {
    final user = widget.user;
    final initials = _initials(user.firstName, user.lastName);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90D9), Color(0xFF1A56C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0] : '';
    final l = last.isNotEmpty ? last[0] : '';
    final out = '$f$l'.toUpperCase();
    return out.isEmpty ? '?' : out;
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFF4A90D9), size: 22),
            SizedBox(width: 18),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4A90D9), size: 22),
          SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF4A90D9),
          ),
        ],
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF4A90D9), size: 22),
          SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              borderRadius: BorderRadius.circular(10),
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: [
                for (final opt in options)
                  DropdownMenuItem(value: opt, child: Text(opt)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
