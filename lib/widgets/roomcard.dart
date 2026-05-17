import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/models/room.dart';
import 'package:ginbec_mobile_app/widgets/info_row.dart';
import 'package:ginbec_mobile_app/widgets/status_badge.dart';
import 'package:ginbec_mobile_app/utils/formatters.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onBook;

  const RoomCard({super.key, required this.room, this.onBook});

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
          // Header: title + status
          Row(
            children: [
              Expanded(
                child: Text(
                  room.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              _statusBadge(room.status),
            ],
          ),
          const SizedBox(height: 8),

          // Floor
          InfoRow(icon: Icons.location_on_outlined, text: room.floor),
          const SizedBox(height: 6),

          // Capacity + hours on one row
          Row(
            children: [
              InfoRow(icon: Icons.people_outline, text: '${room.capacity} នាក់'),
              const SizedBox(width: 24),
              InfoRow(
                icon: Icons.access_time,
                text: formatTimeRange(room.openTime, room.closeTime),
              ),
            ],
          ),
          if (onBook != null) ...[
            const SizedBox(height: 16),
            _BookButton(onPressed: onBook!),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(RoomStatus status) {
    return switch (status) {
      RoomStatus.available => StatusBadge.available(),
      RoomStatus.occupied => const StatusBadge(
        label: 'កំពុងប្រើ',
        background: Color(0xFFFEE2E2),
        foreground: Color(0xFFB91C1C),
      ),
      RoomStatus.maintenance => const StatusBadge(
        label: 'ជួសជុល',
        background: Color(0xFFE5E7EB),
        foreground: Color(0xFF374151),
      ),
    };
  }
}

class _BookButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _BookButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF8C42), Color(0xFFE85D1F)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'កក់បន្ទប់',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}