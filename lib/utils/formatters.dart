import 'package:flutter/material.dart';

String formatDate(DateTime date) {
  const months = ['មករា', 'កុម្ភៈ', 'មីនា', 'មេសា', 'ឧសភា', 'មិថុនា',
                  'កក្កដា', 'សីហា', 'កញ្ញា', 'តុលា', 'វិច្ឆិកា', 'ធ្នូ'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatTimeRange(TimeOfDay start, TimeOfDay end) {
  String fmt(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  return '${fmt(start)} – ${fmt(end)}';
}
