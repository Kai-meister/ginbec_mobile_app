import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/models/document_status.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  const DocumentCard({super.key, required this.document, required this.onTap});

  String _metaLine() {
    final parts = <String>[];
    if (document.officerName != null && document.officerName!.isNotEmpty) {
      parts.add('មន្ត្រី ${document.officerName}');
    }
    final d = document.expiryDate;
    if (d != null) {
      final days = d.difference(DateTime.now()).inDays;
      if (days < 0) {
        parts.add('ផុតកំណត់ហើយ');
      } else {
        parts.add('នៅសល់ $days ថ្ងៃ');
      }
    }
    if (parts.isEmpty) return document.documentTypeName ?? '';
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = DocumentStatus.colorFor(document.statusCode);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: GColor.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: GColor.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GColor.surfaceTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description,
                  color: GColor.primarycolor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.documentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'KhmerOSSiemreap',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: GColor.textBody,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _metaLine(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'KhmerOSSiemreap',
                        fontSize: 11,
                        color: GColor.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  document.statusLabel,
                  style: TextStyle(
                    fontFamily: 'KhmerOSSiemreap',
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}