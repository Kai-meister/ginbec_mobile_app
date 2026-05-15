import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';
import 'package:ginbec_mobile_app/widgets/avatar.dart';
import 'package:ginbec_mobile_app/widgets/dashcard.dart';
import 'package:ginbec_mobile_app/widgets/event_card.dart';
import 'package:ginbec_mobile_app/widgets/hoverabletext.dart';
import 'package:ginbec_mobile_app/widgets/recent_notifications.dart';
import 'package:ginbec_mobile_app/widgets/transp_button.dart';
import '../../widgets/action_button.dart';

class Home extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;

  const Home({super.key, this.onNavigateToTab});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _userName = '';
  int _todayMeetings = 0;
  int _upcomingCount = 0;
  int _unreadCount = 0;
  List<Map<String, dynamic>> _upcomingMeetings = [];
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userId = await StorageService.instance.getUserId();
      final userName = await StorageService.instance.getUserName();

      final results = await Future.wait([
        ApiClient.instance.dio.get(
          '/dashboard/summary',
          queryParameters: {'userId': userId},
        ),
        ApiClient.instance.dio.get('/meetings', queryParameters: {
          'page': 0,
          'size': 3,
          'status': 'SCHEDULED',
        }),
        ApiClient.instance.dio.get('/notifications/my', queryParameters: {
          'userId': userId,
          'page': 0,
          'size': 3,
          'isRead': false,
        }),
      ]);

      final dashboard = results[0].data['data'] as Map<String, dynamic>;
      final meetingsPage = results[1].data['data'] as Map<String, dynamic>;
      final notifPage = results[2].data['data'] as Map<String, dynamic>;

      final meetingsList = (meetingsPage['content'] as List?) ?? [];
      final notifList = (notifPage['content'] as List?) ?? [];

      if (!mounted) return;
      setState(() {
        _userName = userName ?? 'User';
        _todayMeetings = (dashboard['todayMeetings'] as num?)?.toInt() ?? 0;
        _unreadCount = (dashboard['unreadNotifications'] as num?)?.toInt() ?? 0;
        _upcomingCount = (meetingsPage['totalElements'] as num?)?.toInt() ?? 0;
        _upcomingMeetings = meetingsList.cast<Map<String, dynamic>>();
        _notifications = notifList.map((n) {
          final map = n as Map<String, dynamic>;
          return NotificationModel(
            id: map['notificationId'].toString(),
            title: map['title'] as String? ?? '',
            subtitle: map['message'] as String? ?? '',
            createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
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

  DateTime _meetingDateTime(Map<String, dynamic> m) {
    try {
      final date = m['meetingDate'] as String;
      final time = m['startTime'] as String;
      return DateTime.parse('${date}T$time');
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldWidth = MediaQuery.of(context).size.width - 50;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: GColor.backgroundcolor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => widget.onNavigateToTab?.call(3),
                  child: Row(
                    children: [
                      AvatarWidget(imageUrl: 'lib/assets/user_icon.png', size: 50),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Welcome back', style: TextStyle(fontSize: 15)),
                          Text(
                            _userName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      IconButton(
                        onPressed: () => widget.onNavigateToTab?.call(3),
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DashCard(number: '$_todayMeetings', label: "Today's\nMeetings", width: fieldWidth / 3.5),
                    DashCard(number: '$_upcomingCount', label: 'Upcoming', width: fieldWidth / 3.5),
                    DashCard(number: '$_unreadCount', label: 'Unread', width: fieldWidth / 3.5),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(icon: Icons.calendar_month, onTap: () => widget.onNavigateToTab?.call(1), label: 'Book Room', bttBg: Colors.blueAccent, width: fieldWidth / 4.5),
                    ActionButton(icon: Icons.description, onTap: () => widget.onNavigateToTab?.call(1), label: 'Documents', bttBg: Colors.green, width: fieldWidth / 4.5),
                    ActionButton(icon: Icons.group, onTap: () => widget.onNavigateToTab?.call(1), label: 'Schedule', bttBg: Colors.purple, width: fieldWidth / 4.5),
                    ActionButton(icon: Icons.settings, onTap: () => widget.onNavigateToTab?.call(3), label: 'Settings', bttBg: GColor.primarycolor, width: fieldWidth / 4.5),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Upcoming Meetings', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                if (_upcomingMeetings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No upcoming meetings', style: TextStyle(color: Colors.grey.shade500)),
                  )
                else
                  ..._upcomingMeetings.take(2).map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EventCard(
                          tittle: m['title'] as String? ?? '',
                          attendee: 0,
                          datetime: _meetingDateTime(m),
                        ),
                      )),
                const SizedBox(height: 20),
                TranspButton(
                  txt: 'Book New Meeting',
                  onPressed: () => widget.onNavigateToTab?.call(1),
                  width: fieldWidth,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Notifications', style: TextStyle(fontSize: 20)),
                    Hoverabletext(text: 'View All', onTap: () => widget.onNavigateToTab?.call(2)),
                  ],
                ),
                const SizedBox(height: 12),
                NotificationCard(
                  notifications: _notifications.isEmpty
                      ? [
                          NotificationModel(
                            id: '0',
                            title: 'No new notifications',
                            subtitle: '',
                            createdAt: DateTime.now(),
                            type: 'system',
                          )
                        ]
                      : _notifications,
                  onTap: (_) => widget.onNavigateToTab?.call(2),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orangeAccent, Colors.deepOrange],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(blurRadius: 8, offset: const Offset(0, 2), color: Colors.grey.shade300),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Today's Schedule",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        if (_todayMeetings == 0)
                          const Text(
                            'No meetings scheduled for today',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          )
                        else
                          Text(
                            '$_todayMeetings meeting${_todayMeetings == 1 ? '' : 's'} scheduled today',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}