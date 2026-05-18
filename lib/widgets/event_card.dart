import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Compact meeting card.
/// Left: 48px time block (HH:mm in primary color, weekday abbrev below).
/// Divider: 1px dashed [GColor.borderSubtle].
/// Right: title (bold) + subtitle ("បន្ទប់ X · N នាក់" — caller passes [room]).
class EventCard extends StatelessWidget {
  final String tittle;
  final DateTime datetime;
  final int attendee;
  final String? room;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.tittle,
    required this.attendee,
    required this.datetime,
    this.room,
    this.onTap,
  });

  static const List<String> _weekdayKh = [
    'ច័ន្ទ', 'អង្គារ', 'ពុធ', 'ព្រហ', 'សុក្រ', 'សៅរ៍', 'អាទិត្យ',
  ];

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayKh[(datetime.weekday - 1).clamp(0, 6)];
    final subtitleParts = <String>[];
    if (room != null && room!.isNotEmpty) subtitleParts.add('បន្ទប់ $room');
    subtitleParts.add('$attendee នាក់');
    final subtitle = subtitleParts.join(' · ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(
                    DateFormat('HH:mm').format(datetime),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GColor.primarycolor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    weekday,
                    style: TextStyle(
                      fontSize: 10,
                      color: GColor.textMuted,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 1,
              height: 36,
              color: GColor.borderSubtle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tittle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: GColor.textBody,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: GColor.textMuted,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: GColor.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
