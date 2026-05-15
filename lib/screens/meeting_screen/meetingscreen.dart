import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/Widgets/round_text_field.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
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

  @override
  void initState() {
    super.initState();
    txtSearch.addListener(_onSearchChanged);
    _loadData();
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
          name: map['roomCode'] as String? ?? 'Room',
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
          roomName: map['title'] as String? ?? 'Meeting',
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
      case 'POSTPONED':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  void _onselectedTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildRoomsList() {
    if (_filteredRooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No available rooms found',
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
        onBook: () => debugPrint('Book: ${_filteredRooms[i].name}'),
      ),
    );
  }

  Widget _buildBookingsList() {
    if (_filteredBookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No bookings found',
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
        onViewDetails: () => debugPrint('View: ${_filteredBookings[i].roomName}'),
        onCancel: () => debugPrint('Cancel: ${_filteredBookings[i].roomName}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Meeting Rooms',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: RoundTextField(
                        controller: txtSearch,
                        hintText: 'Search rooms...',
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
                          tittle: 'Available Rooms',
                          onTap: () => _onselectedTap(0),
                          isSelected: _selectedIndex == 0,
                        ),
                      ),
                      Expanded(
                        child: TabSwitch(
                          tittle: 'My Bookings',
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
    );
  }
}