import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';
import 'package:ginbec_mobile_app/widgets/hoverabletext.dart';
import 'package:ginbec_mobile_app/widgets/notification_item_card.dart';
import 'package:ginbec_mobile_app/widgets/recent_notifications.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await StorageService.instance.getUserId();
    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (_userId == null) return;
    try {
      final response = await ApiClient.instance.dio.get(
        '/notifications/my',
        queryParameters: {'userId': _userId, 'page': 0, 'size': 50},
      );

      final list = (response.data['data']['content'] as List?) ?? [];
      if (!mounted) return;
      setState(() {
        _notifications = list.map((n) {
          final map = n as Map<String, dynamic>;
          return NotificationModel(
            id: map['notificationId'].toString(),
            title: map['title'] as String? ?? '',
            subtitle: map['message'] as String? ?? '',
            createdAt:
                DateTime.tryParse(map['createdAt'] as String? ?? '') ??
                    DateTime.now(),
            type: (map['type'] as String? ?? 'system').toLowerCase(),
            isRead: map['isRead'] as bool? ?? false,
          );
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markOneRead(NotificationModel n) async {
    if (n.isRead) return;
    try {
      await ApiClient.instance.dio.put('/notifications/${n.id}/read');
      setState(() {
        final idx = _notifications.indexWhere((x) => x.id == n.id);
        if (idx != -1) {
          _notifications[idx] = NotificationModel(
            id: n.id,
            title: n.title,
            subtitle: n.subtitle,
            createdAt: n.createdAt,
            type: n.type,
            isRead: true,
          );
        }
      });
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    if (_userId == null) return;
    try {
      await ApiClient.instance.dio.put(
        '/notifications/read-all',
        queryParameters: {'userId': _userId},
      );
      setState(() {
        _notifications = _notifications.map((n) => NotificationModel(
              id: n.id,
              title: n.title,
              subtitle: n.subtitle,
              createdAt: n.createdAt,
              type: n.type,
              isRead: true,
            )).toList();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      appBar: AppBar(
        backgroundColor: GColor.white,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ការជូនដំណឹង',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: GColor.primarytext,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _isLoading
                  ? 'កំពុងផ្ទុក...'
                  : 'អ្នកមាន $unreadCount ការជូនដំណឹងមិនទាន់អាន',
              style: TextStyle(fontSize: 13, color: GColor.secondarytext),
            ),
          ],
        ),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Hoverabletext(
                  text: 'សម្គាល់អានទាំងអស់',
                  onTap: _markAllRead,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadNotifications,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(
                        child: Text(
                          'មិនទាន់មានការជូនដំណឹង',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          return NotificationItemCard(
                            notification: n,
                            onTap: () => _markOneRead(n),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }
}