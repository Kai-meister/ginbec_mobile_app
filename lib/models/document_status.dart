import 'package:flutter/material.dart';

class DocumentStatus {
  static const _pending  = Color(0xFFFC9400);
  static const _approved = Color(0xFF22A06B);
  static const _rejected = Color(0xFFE5484D);
  static const _neutral  = Color(0xFF9CA3AF);
  static const _expired  = Color(0xFFE5484D);

  static Color colorFor(String statusCode) {
    switch (statusCode) {
      case 'PENDING':  return _pending;
      case 'APPROVED': return _approved;
      case 'REJECTED': return _rejected;
      case 'EXPIRED':  return _expired;
      case 'DRAFT':
      case 'ARCHIVED':
      case 'CANCELLED':
      default:         return _neutral;
    }
  }

  static String labelKh(String statusCode, String fallback) {
    return fallback.isNotEmpty ? fallback : '';
  }
}