import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/profile_screen/profile.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';
import 'package:ginbec_mobile_app/widgets/avatar.dart';
import 'package:ginbec_mobile_app/widgets/dashcard.dart';
import 'package:ginbec_mobile_app/widgets/event_card.dart';
import 'package:ginbec_mobile_app/widgets/hoverabletext.dart';
import 'package:ginbec_mobile_app/widgets/recent_notifications.dart';
import 'package:ginbec_mobile_app/widgets/transp_button.dart';
import '../../widgets/action_button.dart';
import 'package:ginbec_mobile_app/widgets/book_meeting_room.dart';

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
  Future<void> _openBookMeeting() async {
    try {
      final results = await Future.wait([
        ApiClient.instance.dio.get(
          '/meeting-rooms',
          queryParameters: {'status': 'AVAILABLE'},
        ),
        ApiClient.instance.dio.get('/users', queryParameters: {
          'page': 0,
          'size': 100,
        }),
      ]);

      final roomList = (results[0].data['data'] as List?) ?? [];
      final userPage = results[1].data['data'] as Map<String, dynamic>;
      final userList = (userPage['content'] as List?) ?? [];

      // Keep roomCode→roomId map for submission
      final roomIdMap = <String, int>{};
      final roomNames = <String>[];
      for (final r in roomList) {
        final map = r as Map<String, dynamic>;
        final code = map['roomCode'] as String? ?? '';
        final id = (map['roomId'] as num?)?.toInt();
        if (code.isNotEmpty && id != null) {
          roomNames.add(code);
          roomIdMap[code] = id;
        }
      }

      final attendees = userList.map((u) {
        final map = u as Map<String, dynamic>;
        final name = (map['userNameEn'] as String?)?.isNotEmpty == true
            ? map['userNameEn'] as String
            : (map['userNameKh'] as String?) ?? (map['email'] as String?) ?? '';
        return Attendee(
          name: name,
          role: (map['roleName'] as String?) ?? 'Member',
        );
      }).toList();

      if (!mounted) return;

      await showBookMeetingRoomSheet(
        context,
        rooms: roomNames,
        attendees: attendees,
        onSubmit: (booking) async {
          try {
            final roomName = booking['room'] as String;
            final start = booking['startTime'] as TimeOfDay;
            final end = booking['endTime'] as TimeOfDay;
            String pad(int n) => n.toString().padLeft(2, '0');

            await ApiClient.instance.dio.post('/meetings', data: {
              'roomId': roomIdMap[roomName],
              'title': booking['topic'],
              'meetingDate': (booking['date'] as DateTime)
                  .toIso8601String()
                  .split('T')
                  .first,
              'startTime': '${pad(start.hour)}:${pad(start.minute)}:00',
              'endTime': '${pad(end.hour)}:${pad(end.minute)}:00',
              'meetingType': 'INTERNAL',
              'statusCode': 'SCHEDULED',
            });
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('កក់កិច្ចប្រជុំជោគជ័យ!')),
            );
            _loadData();
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('កក់បានបរាជ័យ: $e')),
            );
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ផ្ទុកបន្ទប់បានបរាជ័យ: $e')),
      );
    }
  }


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
        _userName = userName ?? 'អ្នកប្រើប្រាស់';
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
      appBar: AppBar(
        backgroundColor: GColor.white,
        shape: Border(bottom: BorderSide(color: Colors.grey.shade300,width: 1)),
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Row(
            children: [
              AvatarWidget(imageUrl: 'lib/assets/user_icon.png', size: 50),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('សូមស្វាគមន៍មកវិញ', style: TextStyle(fontSize: 15)),
                    Text(
                      _userName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => widget.onNavigateToTab?.call(3),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DashCard(number: '$_todayMeetings', label: 'កិច្ចប្រជុំ\nថ្ងៃនេះ', width: fieldWidth / 3.5),
                    DashCard(number: '$_upcomingCount', label: 'នឹងមកដល់', width: fieldWidth / 3.5),
                    DashCard(number: '$_unreadCount', label: 'មិនទាន់អាន', width: fieldWidth / 3.5),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('សកម្មភាពរហ័ស', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ActionButton(icon: Icons.calendar_month, onTap: () => widget.onNavigateToTab?.call(1), label: 'កក់បន្ទប់', bttBg: Colors.blueAccent, width: fieldWidth / 4.5),
                    ActionButton(icon: Icons.description, onTap: () => widget.onNavigateToTab?.call(1), label: 'ឯកសារ', bttBg: Colors.green, width: fieldWidth / 4.5),
                    ActionButton(icon: Icons.group, onTap: () => widget.onNavigateToTab?.call(1), label: 'កាលវិភាគ', bttBg: Colors.purple, width: fieldWidth / 4.5),
                    ActionButton(icon: Icons.settings, onTap: () => widget.onNavigateToTab?.call(3), label: 'ការកំណត់', bttBg: GColor.primarycolor, width: fieldWidth / 4.5),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('កិច្ចប្រជុំខាងមុខ', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 12),
                if (_upcomingMeetings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('គ្មានកិច្ចប្រជុំខាងមុខ', style: TextStyle(color: Colors.grey.shade500)),
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
                  txt: 'កក់កិច្ចប្រជុំថ្មី',
                  onPressed: _openBookMeeting,
                  width: fieldWidth,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ការជូនដំណឹងថ្មីៗ', style: TextStyle(fontSize: 20)),
                    Hoverabletext(text: 'មើលទាំងអស់', onTap: () => widget.onNavigateToTab?.call(2)),
                  ],
                ),
                const SizedBox(height: 12),
                NotificationCard(
                  notifications: _notifications.isEmpty
                      ? [
                          NotificationModel(
                            id: '0',
                            title: 'មិនទាន់មានការជូនដំណឹងថ្មី',
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
                          'កាលវិភាគថ្ងៃនេះ',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        if (_todayMeetings == 0)
                          const Text(
                            'គ្មានកិច្ចប្រជុំសម្រាប់ថ្ងៃនេះ',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          )
                        else
                          Text(
                            'មាន $_todayMeetings កិច្ចប្រជុំសម្រាប់ថ្ងៃនេះ',
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