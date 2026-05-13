import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: Column(
        children: [
          // Gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [GColor.primarycolor, GColor.secondarycolor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Background Display
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _IconCircle(
                              icon: Icons.wallpaper_rounded,
                              color: GColor.primarycolor,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Background Display',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: GColor.primarytext,
                                  ),
                                ),
                                Text(
                                  'View only - Background image preview',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: GColor.secondarytext,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: GColor.backgroundcolor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF7B2D8B),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'ॐ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Current Background Theme',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: GColor.secondarytext,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'View Only',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Account
                  _SectionLabel(label: 'Account'),
                  const SizedBox(height: 8),
                  _SectionCard(
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: Icons.person_outline,
                          iconColor: GColor.primarycolor,
                          title: 'Profile Settings',
                          subtitle: 'Update your personal information',
                          onTap: () {},
                        ),
                        _RowDivider(),
                        _SettingRow(
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFF7B2D8B),
                          title: 'Privacy & Security',
                          subtitle: 'Manage your privacy settings',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preferences
                  _SectionLabel(label: 'Preferences'),
                  const SizedBox(height: 8),
                  _SectionCard(
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFF5B9EFF),
                          title: 'Notifications',
                          subtitle: 'Customize notification preferences',
                          onTap: () {},
                        ),
                        _RowDivider(),
                        _SettingRow(
                          icon: Icons.language,
                          iconColor: const Color(0xFF34A853),
                          title: 'Language',
                          subtitle: 'English',
                          onTap: () {},
                        ),
                        _RowDivider(),
                        _DarkModeRow(
                          value: _darkMode,
                          onChanged: (v) => setState(() => _darkMode = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // About / Legal
                  _SectionCard(
                    child: Column(
                      children: [
                        _SettingRow(
                          title: 'About GINBEC',
                          onTap: () {},
                        ),
                        _RowDivider(),
                        _SettingRow(
                          title: 'Terms & Conditions',
                          onTap: () {},
                        ),
                        _RowDivider(),
                        _SettingRow(
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign Out
                  _SectionCard(
                    child: InkWell(
                      onTap: () => debugPrint('Sign out'),
                      borderRadius: BorderRadius.circular(14),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Footer
                  Center(
                    child: Text(
                      'GINBEC v2.1.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: GColor.placeholder,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private helpers ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingRow({
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (icon != null && iconColor != null) ...[
              _IconCircle(icon: icon!, color: iconColor!),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _DarkModeRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _DarkModeRow({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _IconCircle(
            icon: Icons.dark_mode_outlined,
            color: const Color(0xFF9C6FE4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Enable dark theme',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF9C6FE4),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }
}
