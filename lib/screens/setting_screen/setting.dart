import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/login_screen/login.dart';
import 'package:ginbec_mobile_app/screens/profile_screen/profile.dart';
import 'package:ginbec_mobile_app/screens/setting_screen/about.dart';
import 'package:ginbec_mobile_app/screens/setting_screen/privacy.dart';
import 'package:ginbec_mobile_app/screens/setting_screen/terms.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut(BuildContext context) async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);

    try {
      await ApiClient.instance.dio.post('/auth/logout');
    } catch (_) {
      // Proceed with local logout even if API call fails
    }

    await StorageService.instance.clearAll();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

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
              ),
            child: const Text(
              'ការកំណត់',
              style: TextStyle(
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
                  // Account
                  _SectionLabel(label: 'គណនី'),
                  const SizedBox(height: 8),
                  _SectionCard(
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: Icons.person_outline,
                          iconColor: GColor.primarycolor,
                          title: 'ការកំណត់ប្រវត្តិរូប',
                          subtitle: 'កែសម្រួលព័ត៌មានផ្ទាល់ខ្លួន',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          ),
                        ),
                        _RowDivider(),
                        _SettingRow(
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFF7B2D8B),
                          title: 'ឯកជនភាព និងសុវត្ថិភាព',
                          subtitle: 'គ្រប់គ្រងការកំណត់ឯកជនភាព',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preferences
                  _SectionLabel(label: 'ចំណូលចិត្ត'),
                  const SizedBox(height: 8),
                  _SectionCard(
                    child: Column(
                      children: [
                        _SettingRow(
                          icon: Icons.notifications_outlined,
                          iconColor: const Color(0xFF5B9EFF),
                          title: 'ការជូនដំណឹង',
                          subtitle: 'កែប្រែការជូនដំណឹង',
                          onTap: () {},
                        ),
                        _RowDivider(),
                        _SettingRow(
                          icon: Icons.language,
                          iconColor: const Color(0xFF34A853),
                          title: 'ភាសា',
                          subtitle: 'ភាសាខ្មែរ',
                          onTap: () {},
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
                          title: 'អំពី GINBEC',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AboutScreen(),
                            ),
                          ),
                        ),
                        _RowDivider(),
                        _SettingRow(
                          title: 'លក្ខខណ្ឌប្រើប្រាស់',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsScreen(),
                            ),
                          ),
                        ),
                        _RowDivider(),
                        _SettingRow(
                          title: 'គោលការណ៍ឯកជនភាព',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign Out
                  _SectionCard(
                    child: InkWell(
                      onTap: () => _signOut(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: _isSigningOut
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                )
                              : const Text(
                                  'ចាកចេញ',
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
                      'GINBEC v1.0.0',
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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100);
  }
}
