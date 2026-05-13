import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/widgets/hoverabletext.dart';
import 'package:ginbec_mobile_app/widgets/notification_item_card.dart';
import 'package:ginbec_mobile_app/widgets/recent_notifications.dart';

class AlertScreen extends StatelessWidget {
  const AlertScreen({super.key});

  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: '1',
      title: 'Meeting Reminder',
      subtitle: 'Meditation Hall A booking starts in 30 minutes',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      type: 'meeting_reminder',
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Booking Confirmed',
      subtitle: 'Your Conference Room 1 booking has been confirmed for Apr 28',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      type: 'booking_confirmed',
      isRead: false,
    ),
    NotificationModel(
      id: '3',
      title: 'New Document Shared',
      subtitle: 'Buddhist Education Guidelines 2026 has been shared with you',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      type: 'document',
      isRead: true,
    ),
    NotificationModel(
      id: '4',
      title: 'New Attendee',
      subtitle: 'Virak Sok joined your meeting on May 2',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      type: 'attendee',
      isRead: true,
    ),
    NotificationModel(
      id: '5',
      title: 'Upcoming Meeting',
      subtitle: 'You have a meeting tomorrow at 2:00 PM in Conference Room 1',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      type: 'upcoming_meeting',
      isRead: true,
    ),
    NotificationModel(
      id: '6',
      title: 'System Update',
      subtitle: 'GINBEC app has been updated to version 2.1.0',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      type: 'system',
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final int unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: GColor.primarytext,
                  ),
                ),
                const Expanded(child: SizedBox()),
                Hoverabletext(
                  text: 'Mark all read',
                  onTap: () => debugPrint('Mark all read'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'You have $unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 14, color: GColor.secondarytext),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return NotificationItemCard(
                    notification: _notifications[index],
                    onTap: () => debugPrint('Tapped: ${_notifications[index].title}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
