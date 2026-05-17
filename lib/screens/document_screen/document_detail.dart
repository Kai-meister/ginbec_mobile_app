import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/models/document_status.dart';
import 'package:ginbec_mobile_app/services/approval_service.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';

class DocumentDetail extends StatefulWidget {
  final Document document;
  const DocumentDetail({super.key, required this.document});

  @override
  State<DocumentDetail> createState() => _DocumentDetailState();
}

class _DocumentDetailState extends State<DocumentDetail> {
  bool _downloading = false;
  bool _deciding = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final perms = await StorageService.instance.getPermissions();
    if (!mounted) return;
    setState(() => _isAdmin = perms.contains('DOC_APPROVE'));
  }

  Future<void> _download() async {
    final url = widget.document.fileUrl;
    if (url == null || url.isEmpty) return;
    setState(() => _downloading = true);
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('មិនអាចទាញយកបាន',
            style: TextStyle(fontFamily: 'KhmerOSSiemreap'))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('មិនអាចទាញយកបាន',
            style: TextStyle(fontFamily: 'KhmerOSSiemreap'))));
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _decide(String statusCode) async {
    String comment = '';
    if (statusCode == 'REJECTED') {
      final result = await _promptRejectReason();
      if (result == null) return; // cancelled
      comment = result;
    }
    setState(() => _deciding = true);
    try {
      final apprId = await ApprovalService.instance
          .findPendingApprovalIdFor(widget.document.documentId);
      if (apprId == null) {
        _toast('មិនអាចស្វែងរកសំណើ');
        return;
      }
      await ApprovalService.instance
          .decide(approvalId: apprId, statusCode: statusCode, comment: comment);
      if (!mounted) return;
      Navigator.of(context).pop(true); // signal list to refresh
    } catch (_) {
      _toast('មានបញ្ហា ព្យាយាមម្តងទៀត');
    } finally {
      if (mounted) setState(() => _deciding = false);
    }
  }

  Future<String?> _promptRejectReason() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('មូលហេតុបដិសេធ',
          style: TextStyle(fontFamily: 'KhmerOSSiemreap')),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'សូមបញ្ចូលមូលហេតុ',
            hintStyle: TextStyle(fontFamily: 'KhmerOSSiemreap'),
          ),
          style: const TextStyle(fontFamily: 'KhmerOSSiemreap'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('បោះបង់',
              style: TextStyle(fontFamily: 'KhmerOSSiemreap')),
          ),
          TextButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) return;
              Navigator.of(ctx).pop(t);
            },
            child: const Text('បញ្ជូន',
              style: TextStyle(fontFamily: 'KhmerOSSiemreap')),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg,
        style: const TextStyle(fontFamily: 'KhmerOSSiemreap'))));
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final badgeColor = DocumentStatus.colorFor(doc.statusCode);
    final hasFile = doc.fileUrl != null && doc.fileUrl!.isNotEmpty;
    final canDecide = _isAdmin && doc.statusCode == 'PENDING';

    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      appBar: AppBar(
        title: const Text('ឯកសារ',
          style: TextStyle(fontFamily: 'KhmerOSMoulLightRegular')),
        backgroundColor: GColor.backgroundcolor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: Icon(Icons.description, size: 64)),
          const SizedBox(height: 8),
          Center(child: Text(doc.documentName,
            style: const TextStyle(
              fontFamily: 'KhmerOSSiemreap', fontSize: 18, fontWeight: FontWeight.w700))),
          if (doc.documentNumber != null)
            Center(child: Text('#${doc.documentNumber}',
              style: const TextStyle(color: Colors.black54))),
          const SizedBox(height: 12),
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(doc.statusLabel,
              style: TextStyle(
                fontFamily: 'KhmerOSSiemreap',
                color: badgeColor, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 24),
          _InfoRow(label: 'ប្រភេទ',     value: doc.documentTypeName ?? '—'),
          _InfoRow(label: 'មន្ត្រី',     value: doc.officerName ?? '—'),
          _InfoRow(label: 'ថ្ងៃផុតកំណត់', value: _formatDate(doc.expiryDate)),
          _InfoRow(label: 'បានបង្កើត',   value: _formatDate(doc.createdAt)),
          if (doc.note != null && doc.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('ចំណាំ',
              style: TextStyle(
                fontFamily: 'KhmerOSSiemreap', fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(doc.note!,
                style: const TextStyle(fontFamily: 'KhmerOSSiemreap')),
            ),
          ],
          const SizedBox(height: 28),
          if (hasFile)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloading ? null : _download,
                icon: const Icon(Icons.download),
                label: Text(_downloading ? 'កំពុងទាញយក...' : 'ទាញយកឯកសារ',
                  style: const TextStyle(fontFamily: 'KhmerOSSiemreap')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GColor.primarycolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          if (canDecide) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: _deciding ? null : () => _decide('APPROVED'),
                icon: const Icon(Icons.check, color: Color(0xFF22A06B)),
                label: const Text('យល់ព្រម',
                  style: TextStyle(
                    fontFamily: 'KhmerOSSiemreap', color: Color(0xFF22A06B))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF22A06B)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: _deciding ? null : () => _decide('REJECTED'),
                icon: const Icon(Icons.close, color: Color(0xFFE5484D)),
                label: const Text('បដិសេធ',
                  style: TextStyle(
                    fontFamily: 'KhmerOSSiemreap', color: Color(0xFFE5484D))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5484D)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )),
            ]),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
              style: const TextStyle(
                fontFamily: 'KhmerOSSiemreap', color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
              style: const TextStyle(
                fontFamily: 'KhmerOSSiemreap', fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}