import 'package:flutter_test/flutter_test.dart';
import 'package:ginbec_mobile_app/models/document.dart';

void main() {
  group('Document.fromJson', () {
    test('parses a full document response', () {
      final json = {
        'documentId': 1,
        'officerName': 'Mr. Sok',
        'documentTypeName': 'Receipt',
        'documentName': 'RECEIPT.pdf',
        'documentNumber': 'DOC-2024-001',
        'note': 'Submitted for monthly review.',
        'statusCode': 'PENDING',
        'statusLabel': 'រង់ចាំអនុម័ត',
        'expiryDate': '2026-12-31',
        'fileUrl': 'https://example.com/file.pdf',
        'createdAt': '2026-05-17T08:00:00',
      };
      final doc = Document.fromJson(json);
      expect(doc.documentId, 1);
      expect(doc.officerName, 'Mr. Sok');
      expect(doc.statusCode, 'PENDING');
      expect(doc.expiryDate, DateTime(2026, 12, 31));
      expect(doc.createdAt, DateTime(2026, 5, 17, 8, 0, 0));
      expect(doc.fileUrl, 'https://example.com/file.pdf');
    });

    test('tolerates null optional fields', () {
      final json = {
        'documentId': 2,
        'documentName': 'X.pdf',
        'statusCode': 'DRAFT',
        'statusLabel': 'សេចក្តីព្រាង',
        'createdAt': '2026-05-17T08:00:00',
      };
      final doc = Document.fromJson(json);
      expect(doc.documentId, 2);
      expect(doc.officerName, isNull);
      expect(doc.note, isNull);
      expect(doc.expiryDate, isNull);
      expect(doc.fileUrl, isNull);
    });
  });
}
