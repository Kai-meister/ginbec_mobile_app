import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/Widgets/round_text_field.dart';
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

  // CHANGED: moved out of build() so it isn't recreated on every rebuild
  final TextEditingController txtSearch = TextEditingController();

  // CHANGED: moved out of build() — was a local variable inside build()
  late final Booking sampleBooking = Booking(
    roomName: 'Meditation Hall A',
    date: DateTime(2026, 4, 27),
    startTime: const TimeOfDay(hour: 9, minute: 0),
    endTime: const TimeOfDay(hour: 11, minute: 0),
    attendees: 25,
    status: BookingStatus.confirmed,
  );

  // NEW: list of bookings so we can render them with ListView.separated
  late final List<Booking> bookings = [
    sampleBooking,
    sampleBooking,
    sampleBooking,
  ];

  // CHANGED: moved out of build() — was a local variable inside build()
  late final List<Room> rooms = [
    Room(
      name: 'Meditation Hall A',
      floor: '2nd Floor',
      capacity: 50,
      openTime: const TimeOfDay(hour: 9, minute: 0),
      closeTime: const TimeOfDay(hour: 17, minute: 0),
      status: RoomStatus.available,
    ),
    Room(
      name: 'Conference Room 1',
      floor: '3rd Floor',
      capacity: 20,
      openTime: const TimeOfDay(hour: 10, minute: 0),
      closeTime: const TimeOfDay(hour: 16, minute: 0),
      status: RoomStatus.available,
    ),
  ];

  // NEW: properly dispose the TextEditingController to avoid memory leaks
  @override
  void dispose() {
    txtSearch.dispose();
    super.dispose();
  }

  void _onselectedTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openBookingFlow(Room room) {
    // TODO: navigate to booking form for the selected room
  }

  // NEW: helper that builds the Available Rooms list
  Widget _buildRoomsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: rooms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => RoomCard(
        room: rooms[i],
        onBook: () => _openBookingFlow(rooms[i]),
      ),
    );
  }

  // NEW: helper that builds the My Bookings list
  Widget _buildBookingsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Bookingcard(
        booking: bookings[i],
        onViewDetails: () => print('View Details tapped'),
        onCancel: () => print('cancel'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CHANGED: removed local sampleBooking, rooms, and txtSearch — now class fields above

    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Meeting Rooms',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
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
              const SizedBox(height: 40),
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
              const SizedBox(height: 40),

              // CHANGED: removed the 3 hardcoded Bookingcard widgets and
              //          the standalone ListView.separated that was here.
              // NEW: single AnimatedSwitcher that flips between the two lists
              //      based on which tab is selected. This is the actual
              //      "switch between cards on tab tap" behavior.
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
    );
  }
}