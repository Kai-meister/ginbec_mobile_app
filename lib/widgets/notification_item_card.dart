import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/widgets/recent_notifications.dart';

class NotificationItemCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationItemCard({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool unread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: GColor.white,
          borderRadius: BorderRadius.circular(14),
          border: unread
              ? Border.all(color: GColor.secondarycolor.withValues(alpha: 0.5), width: 1)
              : Border.all(color: Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _IconCircle(type: notification.type, unread: unread),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: GColor.primarytext,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: GColor.secondarytext,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: GColor.placeholder,
                    ),
                  ),
                ],
              ),
            ),
            if (unread)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: GColor.primarycolor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  }
}

class _IconCircle extends StatelessWidget {
  final String type;
  final bool unread;

  const _IconCircle({required this.type, required this.unread});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: unread ? GColor.primarycolor : const Color(0xFFE8E8E8),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _iconForType(type),
        color: unread ? GColor.white : const Color(0xFF9E9E9E),
        size: 22,
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'meeting_reminder':
        return Icons.calendar_today;
      case 'booking_confirmed':
        return Icons.check_circle_outline;
      case 'document':
        return Icons.description_outlined;
      case 'attendee':
        return Icons.person_add_alt_1_outlined;
      case 'upcoming_meeting':
        return Icons.access_time;
      case 'system':
        return Icons.notifications_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
