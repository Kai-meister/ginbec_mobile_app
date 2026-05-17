class Document {
  final int documentId;
  final String? officerName;
  final String? documentTypeName;
  final String documentName;
  final String? documentNumber;
  final String? note;
  final String statusCode;
  final String statusLabel;
  final DateTime? expiryDate;
  final String? fileUrl;
  final DateTime createdAt;

  Document({
    required this.documentId,
    required this.documentName,
    required this.statusCode,
    required this.statusLabel,
    required this.createdAt,
    this.officerName,
    this.documentTypeName,
    this.documentNumber,
    this.note,
    this.expiryDate,
    this.fileUrl,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return Document(
      documentId: json['documentId'] as int,
      officerName: json['officerName'] as String?,
      documentTypeName: json['documentTypeName'] as String?,
      documentName: json['documentName'] as String? ?? '',
      documentNumber: json['documentNumber'] as String?,
      note: json['note'] as String?,
      statusCode: json['statusCode'] as String? ?? 'UNKNOWN',
      statusLabel: json['statusLabel'] as String? ?? '',
      expiryDate: parseDate(json['expiryDate']),
      fileUrl: json['fileUrl'] as String?,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
    );
  }
}
