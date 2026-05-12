import 'package:flutter/material.dart';

enum RoomStatus { available, occupied, maintenance }

class Room {
  final String name;
  final String floor;          // "2nd Floor"
  final int capacity;          // 50
  final TimeOfDay openTime;    // 09:00
  final TimeOfDay closeTime;   // 17:00
  final RoomStatus status;

  const Room({
    required this.name,
    required this.floor,
    required this.capacity,
    required this.openTime,
    required this.closeTime,
    required this.status,
  });
}