import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ginbec_mobile_app/models/document_status.dart';

void main() {
  group('DocumentStatus', () {
    test('returns amber for PENDING', () {
      expect(DocumentStatus.colorFor('PENDING'),
        const Color(0xFFFC9400));
    });
    test('returns green for APPROVED', () {
      expect(DocumentStatus.colorFor('APPROVED'),
        const Color(0xFF22A06B));
    });
    test('returns red for REJECTED', () {
      expect(DocumentStatus.colorFor('REJECTED'),
        const Color(0xFFE5484D));
    });
    test('returns grey for unknown', () {
      expect(DocumentStatus.colorFor('WHATEVER'),
        const Color(0xFF9CA3AF));
    });

    test('khmer label fallback for unknown', () {
      expect(DocumentStatus.labelKh('UNKNOWN', ''), '');
      expect(DocumentStatus.labelKh('UNKNOWN', 'foo'), 'foo');
    });
  });
}