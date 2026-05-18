import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/meeting_screen/meeting_details.dart';
import 'package:ginbec_mobile_app/screens/profile_screen/profile.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';
import 'package:ginbec_mobile_app/widgets/avatar.dart';
import 'package:ginbec_mobile_app/widgets/dashcard.dart';
import 'package:ginbec_mobile_app/widgets/event_card.dart';
import 'package:ginbec_mobile_app/widgets/gradient_hero.dart';
import 'package:ginbec_mobile_app/widgets/quick_action_tile.dart';
import 'package:ginbec_mobile_app/widgets/recent_notifications.dart';
import 'package:ginbec_mobile_app/widgets/section_header.dart';
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
  bool _canManage = false;
  Future<void> _openBookMeeting() async {
    try {
      final roomsResp = await ApiClient.instance.dio.get(
        '/meeting-rooms',
        queryParameters: {'status': 'AVAILABLE'},
      );
      final roomList = (roomsResp.data['data'] as List?) ?? [];

      // /users requires USER_CREATE — managers and below get 403.
      // Tolerate failure and just show no attendees to pick.
      List<dynamic> userList = const [];
      try {
        final usersResp = await ApiClient.instance.dio.get(
          '/users',
          queryParameters: {'page': 0, 'size': 100},
        );
        final userPage =
            usersResp.data['data'] as Map<String, dynamic>?;
        userList = (userPage?['content'] as List?) ?? const [];
      } catch (_) {
        // ignore — booking still works without attendees in payload
      }

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
          } on DioException catch (e) {
            if (!mounted) return;
            final req = e.requestOptions;
            final code = e.response?.statusCode;
            final body = e.response?.data;
            final authHeader =
                (req.headers['Authorization'] as String?) ?? '(missing)';
            final tokenPreview = authHeader.length > 25
                ? '${authHeader.substring(0, 25)}...'
                : authHeader;
            final detail = StringBuffer()
              ..writeln('URL: ${req.method} ${req.uri}')
              ..writeln('Status: ${code ?? '-'}')
              ..writeln('Auth: $tokenPreview')
              ..writeln('Request payload:')
              ..writeln(req.data?.toString() ?? '(empty)')
              ..writeln('---')
              ..writeln('Response body:')
              ..writeln(body?.toString() ?? '(empty)')
              ..writeln('Dio: ${e.type.name} ${e.message ?? ''}');
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('កក់បានបរាជ័យ'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: SelectableText(detail.toString(),
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12)),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('បិទ'),
                  ),
                ],
              ),
            );
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

      final canManage = await StorageService.instance.canManageMeetings();

      if (!mounted) return;
      setState(() {
        _userName = userName ?? 'អ្នកប្រើប្រាស់';
        _canManage = canManage;
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: GColor.backgroundcolor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final statCardWidth = (width - 32 - 16) / 3;

    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHero(
                bottomPadding: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 2,
                              ),
                            ),
                            child: const AvatarWidget(
                              imageUrl: 'lib/assets/user_icon.png',
                              size: 44,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'សូមស្វាគមន៍មកវិញ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontFamily: 'KhmerOSSiemreap',
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _userName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'KhmerOSSiemreap',
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => widget.onNavigateToTab?.call(4),
                          icon: const Icon(Icons.settings, color: Colors.white),
                          tooltip: 'ការកំណត់',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _todayMeetings == 0
                                  ? 'គ្មានកិច្ចប្រជុំសម្រាប់ថ្ងៃនេះ'
                                  : 'មាន $_todayMeetings កិច្ចប្រជុំសម្រាប់ថ្ងៃនេះ',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontFamily: 'KhmerOSSiemreap',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DashCard(
                            number: '$_todayMeetings',
                            label: 'ប្រជុំ\nថ្ងៃនេះ',
                            width: statCardWidth,
                          ),
                          DashCard(
                            number: '$_upcomingCount',
                            label: 'នឹងមកដល់',
                            width: statCardWidth,
                          ),
                          DashCard(
                            number: '$_unreadCount',
                            label: 'មិនទាន់អាន',
                            width: statCardWidth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'សកម្មភាពរហ័ស'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (_canManage) ...[
                            Expanded(
                              child: QuickActionTile(
                                icon: Icons.calendar_month,
                                label: 'កក់',
                                onTap: _openBookMeeting,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.description,
                              label: 'ឯកសារ',
                              onTap: () => widget.onNavigateToTab?.call(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.group,
                              label: 'កាលវិភាគ',
                              onTap: () => widget.onNavigateToTab?.call(1),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: QuickActionTile(
                              icon: Icons.settings,
                              label: 'ការកំណត់',
                              onTap: () => widget.onNavigateToTab?.call(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SectionHeader(
                        title: 'កិច្ចប្រជុំខាងមុខ',
                        onSeeAll: () => widget.onNavigateToTab?.call(1),
                      ),
                      if (_upcomingMeetings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'គ្មានកិច្ចប្រជុំខាងមុខ',
                            style: TextStyle(
                              color: GColor.textMuted,
                              fontFamily: 'KhmerOSSiemreap',
                            ),
                          ),
                        )
                      else
                        ..._upcomingMeetings.take(2).map((m) {
                          final id = (m['meetingId'] as num?)?.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: EventCard(
                              tittle: m['title'] as String? ?? '',
                              attendee: 0,
                              datetime: _meetingDateTime(m),
                              room: m['roomName'] as String?,
                              onTap: id == null
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MeetingDetailsScreen(
                                            meetingId: id,
                                          ),
                                        ),
                                      ),
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                      SectionHeader(
                        title: 'ការជូនដំណឹងថ្មីៗ',
                        onSeeAll: () => widget.onNavigateToTab?.call(3),
                      ),
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
                        onTap: (_) => widget.onNavigateToTab?.call(3),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}