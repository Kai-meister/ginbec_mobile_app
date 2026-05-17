import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/widgets/round_text_field.dart';
import 'package:ginbec_mobile_app/screens/meeting_screen/meeting_details.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';
import 'package:ginbec_mobile_app/widgets/book_meeting_room.dart';
import 'package:ginbec_mobile_app/widgets/bookingcard.dart';
import 'package:ginbec_mobile_app/widgets/tab_switch.dart';

import '../../config/color.dart';
import '../../models/booking.dart';
import '../../models/room.dart';
import '../../widgets/roomcard.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  int _selectedIndex = 0;
  final TextEditingController txtSearch = TextEditingController();

  List<Room> _allRooms = [];
  List<Room> _filteredRooms = [];
  List<Booking> _allBookings = [];
  List<Booking> _filteredBookings = [];
  bool _isLoading = true;
  bool _canManage = false;

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(_onSearchChanged);
    _loadRole();
    _loadData();
  }

  Future<void> _loadRole() async {
    final can = await StorageService.instance.canManageMeetings();
    if (!mounted) return;
    setState(() => _canManage = can);
  }

  @override
  void dispose() {
    txtSearch.removeListener(_onSearchChanged);
    txtSearch.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = txtSearch.text.toLowerCase();
    setState(() {
      _filteredRooms = _allRooms
          .where((r) =>
              r.name.toLowerCase().contains(query) ||
              r.floor.toLowerCase().contains(query))
          .toList();
      _filteredBookings = _allBookings
          .where((b) => b.roomName.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiClient.instance.dio.get(
          '/meeting-rooms',
          queryParameters: {'status': 'AVAILABLE'},
        ),
        ApiClient.instance.dio.get('/meetings', queryParameters: {
          'page': 0,
          'size': 50,
        }),
      ]);

      final roomList = (results[0].data['data'] as List?) ?? [];
      final meetingList =
          (results[1].data['data']['content'] as List?) ?? [];

      final rooms = roomList.map((r) {
        final map = r as Map<String, dynamic>;
        return Room(
          name: map['roomCode'] as String? ?? 'បន្ទប់',
          floor: map['location'] as String? ?? '',
          capacity: (map['capacity'] as num?)?.toInt() ?? 0,
          openTime: const TimeOfDay(hour: 8, minute: 0),
          closeTime: const TimeOfDay(hour: 17, minute: 0),
          status: (map['status'] as String?) == 'AVAILABLE'
              ? RoomStatus.available
              : RoomStatus.occupied,
        );
      }).toList();

      final bookings = meetingList.map((m) {
        final map = m as Map<String, dynamic>;
        return Booking(
          id: (map['meetingId'] as num?)?.toInt(),
          roomName: map['title'] as String? ?? 'កិច្ចប្រជុំ',
          date: DateTime.tryParse(map['meetingDate'] as String? ?? '') ??
              DateTime.now(),
          startTime: _parseTime(map['startTime'] as String?),
          endTime: _parseTime(map['endTime'] as String?),
          attendees: 0,
          status: _mapStatus(map['statusCode'] as String?),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _allRooms = rooms;
        _filteredRooms = rooms;
        _allBookings = bookings;
        _filteredBookings = bookings;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTime(String? time) {
    if (time == null) return const TimeOfDay(hour: 0, minute: 0);
    final parts = time.split(':');
    if (parts.length < 2) return const TimeOfDay(hour: 0, minute: 0);
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  BookingStatus _mapStatus(String? code) {
    switch (code) {
      case 'CONFIRMED':
      case 'IN_PROGRESS':
      case 'COMPLETED':
        return BookingStatus.confirmed;
      case 'CANCELLED':
      case 'POSTPONED':return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  void _onselectedTap(int index) {
    setState(() => _selectedIndex = index);
  }

  void _openDetails(Booking b) {
    if (b.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('រកមិនឃើញលេខសម្គាល់កិច្ចប្រជុំ')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MeetingDetailsScreen(meetingId: b.id!),
      ),
    );
  }

  Future<void> _cancelBooking(Booking b) async {
    if (b.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('រកមិនឃើញលេខសម្គាល់កិច្ចប្រជុំ')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('បោះបង់ការកក់'),
        content: Text('តើអ្នកប្រាកដចង់បោះបង់ "${b.roomName}" មែនទេ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ទេ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('បាទ/ចាស', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiClient.instance.dio.delete('/meetings/${b.id}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('បានបោះបង់ការកក់')),
      );
      await _loadData();
    } on DioException catch (e) {
      if (!mounted) return;
      final code = e.response?.statusCode;
      final body = e.response?.data;
      final serverMsg = body is Map ? body['message'] : null;
      final shown = serverMsg ?? body?.toString() ?? e.message ?? e.type.name;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('បោះបង់បានបរាជ័យ [${code ?? '-'}]: $shown'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  Future<void> _openBookMeeting(String preselectedRoom) async {
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
        initialRoom: roomNames.contains(preselectedRoom) ? preselectedRoom : null,
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

  Widget _buildRoomsList() {
    if (_filteredRooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'រកមិនឃើញបន្ទប់ទំនេរ',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _filteredRooms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) => RoomCard(
        room: _filteredRooms[i],
        onBook: _canManage
            ? () => _openBookMeeting(_filteredRooms[i].name)
            : null,
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_filteredBookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'គ្មានការកក់',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _filteredBookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, i) => Bookingcard(
        booking: _filteredBookings[i],
        onViewDetails: () => _openDetails(_filteredBookings[i]),
        onCancel: _canManage
            ? () => _cancelBooking(_filteredBookings[i])
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'បន្ទប់ប្រជុំ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                  children: [
                    Expanded(
                      child: RoundTextField(
                        controller: txtSearch,
                        hintText: 'ស្វែងរកបន្ទប់...',
                        icon: Icons.search,
                        isPassword: false,
                        height: 60,
                        width: 400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TabSwitch(
                          tittle: 'បន្ទប់ទំនេរ',
                          onTap: () => _onselectedTap(0),
                          isSelected: _selectedIndex == 0,
                        ),
                      ),
                      Expanded(
                        child: TabSwitch(
                          tittle: 'ការកក់របស់ខ្ញុំ',
                          onTap: () => _onselectedTap(1),
                          isSelected: _selectedIndex == 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _selectedIndex == 0
                        ? _buildRoomsList()
                        : _buildBookingsList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}