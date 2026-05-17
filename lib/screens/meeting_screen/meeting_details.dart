import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';

class MeetingDetailsScreen extends StatefulWidget {
  final int meetingId;

  const MeetingDetailsScreen({super.key, required this.meetingId});

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  Map<String, dynamic>? _meeting;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final resp = await ApiClient.instance.dio
          .get('/meetings/${widget.meetingId}');
      if (!mounted) return;
      setState(() {
        _meeting = resp.data['data'] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final body = e.response?.data;
      final msg = body is Map ? body['message'] : null;
      setState(() {
        _error = msg ?? e.message ?? 'ផ្ទុកលម្អិតបានបរាជ័យ';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'ផ្ទុកលម្អិតបានបរាជ័យ';
        _isLoading = false;
      });
    }
  }

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    const months = [
      'មករា','កុម្ភៈ','មីនា','មេសា','ឧសភា','មិថុនា',
      'កក្កដា','សីហា','កញ្ញា','តុលា','វិច្ឆិកា','ធ្នូ',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _fmtTime(String? hms) {
    if (hms == null || hms.isEmpty) return '—';
    final parts = hms.split(':');
    if (parts.length < 2) return hms;
    return '${parts[0]}:${parts[1]}';
  }

  (Color, Color, String) _statusStyle(String? code) {
    switch (code) {
      case 'CONFIRMED':
      case 'IN_PROGRESS':
      case 'COMPLETED':
        return (const Color(0xFFD1FAE5), const Color(0xFF047857),
            _statusLabel(code));
      case 'CANCELLED':
      case 'POSTPONED':
        return (const Color(0xFFFEE2E2), const Color(0xFFB91C1C),
            _statusLabel(code));
      case 'SCHEDULED':
      case 'DRAFT':
      case 'RESCHEDULED':
      default:
        return (const Color(0xFFFEF3C7), const Color(0xFF92400E),
            _statusLabel(code));
    }
  }

  String _statusLabel(String? code) {
    switch (code) {
      case 'DRAFT': return 'សេចក្តីព្រាង';
      case 'SCHEDULED': return 'កំណត់ពេល';
      case 'CONFIRMED': return 'បានបញ្ជាក់';
      case 'IN_PROGRESS': return 'កំពុងប្រជុំ';
      case 'COMPLETED': return 'បានបញ្ចប់';
      case 'CANCELLED': return 'បានលុបចោល';
      case 'POSTPONED': return 'បានពន្យារ';
      case 'RESCHEDULED': return 'កំណត់ពេលឡើងវិញ';
      default: return code ?? '—';
    }
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
          'លម្អិតកិច្ចប្រជុំ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                child: _error != null
                    ? _errorView()
                    : _detailsView(),
              ),
            ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.error_outline,
                color: Colors.grey.shade500, size: 48),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: _load, child: const Text('ព្យាយាមម្ដងទៀត')),
          ],
        ),
      ),
    );
  }

  Widget _detailsView() {
    final m = _meeting ?? {};
    final title = (m['title'] as String?)?.trim();
    final status = m['statusCode'] as String?;
    final (bg, fg, label) = _statusStyle(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA94D), Color(0xFFFF6A00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title?.isNotEmpty == true ? title! : '(គ្មានចំណងជើង)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _SectionLabel('ពេលវេលា'),
        const SizedBox(height: 8),
        _card([
          _Row(
            icon: Icons.calendar_today,
            label: 'កាលបរិច្ឆេទ',
            value: _fmtDate(m['meetingDate'] as String?),
          ),
          _Row(
            icon: Icons.access_time,
            label: 'ម៉ោង',
            value:
                '${_fmtTime(m['startTime'] as String?)} – ${_fmtTime(m['endTime'] as String?)}',
          ),
        ]),
        const SizedBox(height: 16),

        _SectionLabel('ទីកន្លែង'),
        const SizedBox(height: 8),
        _card([
          _Row(
            icon: Icons.meeting_room,
            label: 'បន្ទប់',
            value: (m['roomCode'] as String?) ?? '—',
          ),
          _Row(
            icon: Icons.location_on_outlined,
            label: 'ទីតាំង',
            value: (m['roomLocation'] as String?) ?? '—',
          ),
          _Row(
            icon: Icons.videocam_outlined,
            label: 'ប្រភេទ',
            value: _meetingTypeLabel(m['meetingType'] as String?),
          ),
          if ((m['meetingLink'] as String?)?.isNotEmpty ?? false)
            _Row(
              icon: Icons.link,
              label: 'តំណ',
              value: m['meetingLink'] as String,
            ),
        ]),
        const SizedBox(height: 16),

        _SectionLabel('អ្នករៀបចំ'),
        const SizedBox(height: 8),
        _card([
          _Row(
            icon: Icons.person_outline,
            label: 'អ្នករៀបចំ',
            value: (m['organizerName'] as String?) ?? '—',
          ),
        ]),
        const SizedBox(height: 16),

        if ((m['agenda'] as String?)?.trim().isNotEmpty ?? false) ...[
          _SectionLabel('របៀបវារៈ'),
          const SizedBox(height: 8),
          _card([
            _Row(
              icon: Icons.list_alt,
              label: 'របៀបវារៈ',
              value: m['agenda'] as String,
            ),
          ]),
          const SizedBox(height: 16),
        ],

        if ((m['note'] as String?)?.trim().isNotEmpty ?? false) ...[
          _SectionLabel('កំណត់ត្រា'),
          const SizedBox(height: 8),
          _card([
            _Row(
              icon: Icons.notes,
              label: 'កំណត់ត្រា',
              value: m['note'] as String,
            ),
          ]),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 8),
      ],
    );
  }

  String _meetingTypeLabel(String? t) {
    switch (t) {
      case 'INTERNAL': return 'ផ្ទៃក្នុង';
      case 'EXTERNAL': return 'ខាងក្រៅ';
      case 'ONLINE': return 'អនឡាញ';
      case 'HYBRID': return 'លាយ';
      default: return t ?? '—';
    }
  }

  Widget _card(List<Widget> rows) {
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

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
