import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/models/document_status.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  const DocumentCard({super.key, required this.document, required this.onTap});

  String _expiryText() {
    final d = document.expiryDate;
    if (d == null) return '—';
    final days = d.difference(DateTime.now()).inDays;
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final iso = '${d.year}-$month-$day';
    if (days < 0) return '$iso (ផុតកំណត់)';
    return '$iso (នៅសល់ $days ថ្ងៃ)';
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = DocumentStatus.colorFor(document.statusCode);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.description, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.documentName,
                      style: const TextStyle(
                        fontFamily: 'KhmerOSSiemreap',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      document.statusLabel,
                      style: TextStyle(
                        fontFamily: 'KhmerOSSiemreap',
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (document.documentTypeName != null)
                Text('ប្រភេទ: ${document.documentTypeName}',
                  style: const TextStyle(
                    fontFamily: 'KhmerOSSiemreap', fontSize: 12, color: Colors.black54)),
              if (document.officerName != null)
                Text('មន្ត្រី: ${document.officerName}',
                  style: const TextStyle(
                    fontFamily: 'KhmerOSSiemreap', fontSize: 12, color: Colors.black54)),
              Text('ផុតកំណត់: ${_expiryText()}',
                style: TextStyle(
                  fontFamily: 'KhmerOSSiemreap',
                  fontSize: 12,
                  color: GColor.primarycolor.withValues(alpha: 0.9))),
            ],
          ),
        ),
      ),
    );
  }
}