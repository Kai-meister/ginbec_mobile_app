import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';
import 'package:ginbec_mobile_app/widgets/avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = await StorageService.instance.getUserId();
      if (userId == null) {
        throw Exception('រកមិនឃើញលេខសម្គាល់អ្នកប្រើ');
      }

      final response = await ApiClient.instance.dio.get('/users/$userId');
      final data = response.data['data'] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() {
        _user = data;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final fallbackName = await StorageService.instance.getUserName();
      final fallbackEmail = await StorageService.instance.getUserEmail();
      setState(() {
        _user = {
          'userNameEn': fallbackName,
          'email': fallbackEmail,
        };
        _error = e.response?.data?['message'] as String? ??
            'ផ្ទុកប្រវត្តិរូបពីម៉ាស៊ីនមេបានបរាជ័យ';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'ផ្ទុកប្រវត្តិរូបបានបរាជ័យ';
        _isLoading = false;
      });
    }
  }

  String _displayName() {
    final m = _user;
    if (m == null) return 'អ្នកប្រើប្រាស់';
    final en = m['userNameEn'] as String?;
    final kh = m['userNameKh'] as String?;
    if (en != null && en.trim().isNotEmpty) return en;
    if (kh != null && kh.trim().isNotEmpty) return kh;
    return (m['email'] as String?) ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      appBar: AppBar(
        backgroundColor: GColor.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        title: const Text(
          'ប្រវត្តិរូប',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _SectionLabel('ព័ត៌មានផ្ទាល់ខ្លួន'),
                    const SizedBox(height: 8),
                    _infoCard([
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'ឈ្មោះ (អង់គ្លេស)',
                        value: _user?['userNameEn'] as String?,
                      ),
                      _InfoRow(
                        icon: Icons.translate,
                        label: 'ឈ្មោះ (ខ្មែរ)',
                        value: _user?['userNameKh'] as String?,
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'អ៊ីមែល',
                        value: _user?['email'] as String?,
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: 'លេខទូរស័ព្ទ',
                        value: _user?['phone'] as String? ??
                            _user?['phoneNumber'] as String?,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _SectionLabel('កន្លែងធ្វើការ'),
                    const SizedBox(height: 8),
                    _infoCard([
                      _InfoRow(
                        icon: Icons.shield_outlined,
                        label: 'តួនាទី',
                        value: _user?['roleName'] as String?,
                      ),
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'នាយកដ្ឋាន',
                        value: _user?['departmentName'] as String? ??
                            _user?['department'] as String?,
                      ),
                      _InfoRow(
                        icon: Icons.work_outline,
                        label: 'មុខតំណែង',
                        value: _user?['position'] as String?,
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA94D), Color(0xFFFF6A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const AvatarWidget(
              imageUrl: 'lib/assets/user_icon.png',
              size: 72,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  (_user?['email'] as String?) ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if ((_user?['roleName'] as String?)?.isNotEmpty ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _user!['roleName'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(Divider(
            height: 1, thickness: 1, color: Colors.grey.shade100));
      }
    }
    return Container(
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
      child: Column(children: children),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: GColor.primarycolor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasValue ? value! : '—',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: hasValue ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}