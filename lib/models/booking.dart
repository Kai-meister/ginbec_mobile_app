import 'package:flutter/material.dart'; // for TimeOfDay

enum BookingStatus { confirmed, pending, cancelled }

class Booking {
  final int? id;
  final String roomName;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int attendees;
  final BookingStatus status;

  const Booking({
    this.id,
    required this.roomName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.attendees,
    required this.status,
  });
}