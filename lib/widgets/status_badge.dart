import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const StatusBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  /// Convenience constructors for common statuses
  factory StatusBadge.available() => const StatusBadge(
    label: 'ទំនេរ',
    background: Color(0xFFD1FAE5),
    foreground: Color(0xFF047857),
  );

  factory StatusBadge.confirmed() => const StatusBadge(
    label: 'បានបញ្ជាក់',
    background: Color(0xFFD1FAE5),
    foreground: Color(0xFF047857),
  );

  factory StatusBadge.pending() => const StatusBadge(
    label: 'កំពុងរង់ចាំ',
    background: Color(0xFFFEF3C7),
    foreground: Color(0xFF92400E),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: foreground, fontWeight: FontWeight.w500)),
    );
  }
}