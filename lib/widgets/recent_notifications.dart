import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final String type;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.type,
    this.isRead = false,
  });
}

class NotificationCard extends StatelessWidget {
  final List<NotificationModel> notifications;
  final void Function(NotificationModel)? onTap;

  const NotificationCard({
    super.key,
    required this.notifications,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GColor.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GColor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            for (int i = 0; i < notifications.length; i++) ...[
              NotificationTile(
                notification: notifications[i],
                onTap: onTap == null ? null : () => onTap!(notifications[i]),
              ),
              if (i != notifications.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: GColor.borderSubtle,
                  indent: 14,
                  endIndent: 14,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData _iconForType(String type) {
    switch (type) {
      case 'meeting':
        return Icons.event;
      case 'booking':
        return Icons.calendar_month;
      case 'document':
        return Icons.description;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'ទើបតែឥឡូវ';
    if (diff.inMinutes < 60) return '${diff.inMinutes} នាទីមុន';
    if (diff.inHours < 24) return '${diff.inHours} ម៉ោងមុន';
    return '${diff.inDays} ថ្ងៃមុន';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: GColor.surfaceTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForType(notification.type),
                color: GColor.primarycolor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: GColor.textBody,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: GColor.textMuted,
                      fontFamily: 'KhmerOSSiemreap',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: GColor.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
