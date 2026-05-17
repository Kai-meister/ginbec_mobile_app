import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/models/booking.dart';
import 'package:ginbec_mobile_app/utils/formatters.dart';

class Bookingcard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onViewDetails;
  final VoidCallback? onCancel;

  const Bookingcard({
    super.key,
    required this.booking,
    required this.onViewDetails,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.roomName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.calendar_today_outlined, text: formatDate(booking.date)),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.access_time, text: formatTimeRange(booking.startTime, booking.endTime)),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.people_outline, text: '${booking.attendees} នាក់'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  child: const Text('មើលលម្អិត'),
                ),
              ),
              if (onCancel != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFDC2626)),
                    ),
                    child: const Text('បោះបង់'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Color(0xFF374151))),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      BookingStatus.confirmed => (const Color(0xFFD1FAE5), const Color(0xFF047857), 'បានបញ្ជាក់'),
      BookingStatus.pending   => (const Color(0xFFFEF3C7), const Color(0xFF92400E), 'កំពុងរង់ចាំ'),
      BookingStatus.cancelled => (const Color(0xFFFEE2E2), const Color(0xFFB91C1C), 'បានបោះបង់'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w500)),
    );
  }
}
