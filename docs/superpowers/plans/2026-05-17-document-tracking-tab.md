# Documents Tracking Tab Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a 5th bottom-nav tab ("ឯកសារ") that lets officers track their documents and admins approve/reject pending documents — using the existing `/documents` and `/approvals` REST endpoints.

**Architecture:** Plain `StatefulWidget` + `setState` (matches project convention — no Provider/Bloc). Each sub-tab (Pending / Recent / Expiring) calls `/documents` with different filter params. Backend enforces row-level access by bearer token, so the client never sends an `officer_id` filter. File downloads launch via `url_launcher` against either a presigned R2 URL or the `/attachments/{id}/download` endpoint, depending on what `Document.fileUrl` returns.

**Tech Stack:** Flutter 3.x, Dio HTTP, existing `ApiClient.instance.dio` singleton, `url_launcher` (new dependency).

**Spec reference:** `docs/superpowers/specs/2026-05-17-document-tracking-tab-design.md`

---

## File Plan

### Created
| Path | Responsibility |
|---|---|
| `lib/models/document.dart` | `Document` data class + `fromJson` |
| `lib/models/document_status.dart` | Status code → Khmer label + badge color |
| `lib/services/document_service.dart` | List + get document, list statuses |
| `lib/services/approval_service.dart` | Find approval for doc; decide (approve/reject) |
| `lib/widgets/document_card.dart` | One row in the list |
| `lib/screens/document_screen/document_screen.dart` | Main tab — 3 sub-tabs, pagination |
| `lib/screens/document_screen/document_detail.dart` | Detail screen — view + download + admin actions |
| `test/models/document_test.dart` | Unit tests for `Document.fromJson` |
| `test/models/document_status_test.dart` | Unit tests for status mapping |

### Modified
| Path | Change |
|---|---|
| `pubspec.yaml` | Add `url_launcher` dependency |
| `lib/screens/mainscreen.dart` | Insert `DocumentScreen()` at index 2; add 5th `TabButton`; shift Alerts/Settings indices |

---

## Task 0: Pre-flight verification (already done — read-only confirmation)

These were verified against the live backend before this plan was written:

- Status codes from `GET /lookups/document-statuses`: `DRAFT`, `PENDING`, `APPROVED`, `REJECTED`, `EXPIRED`, `ARCHIVED`, `CANCELLED`. The Pending sub-tab will filter `status=PENDING`.
- `GET /documents?expiring_within=30` is supported.
- Approve/reject is a `PUT /approvals/{id}/decide` with body `{ statusCode: "APPROVED"|"REJECTED", comment: "…" }`.
- `GET /approvals?status=PENDING&size=200` returns approvals with a `documentId` field, used to find the approval id for a given document client-side.
- `LoginResponse` carries only `userId` and `permissions` — no officer ID. We will NOT send `officer_id` as a filter; backend scopes results by bearer token.

No code action for this task.

---

## Task 1: Add url_launcher dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Open `pubspec.yaml` and locate the `dependencies:` block**

Run:
```bash
grep -n "^dependencies:" pubspec.yaml
grep -n "^  flutter:" pubspec.yaml
```

- [ ] **Step 2: Add `url_launcher` under `dependencies:`**

Insert this line after the `flutter:` entry in the `dependencies:` block (alphabetical placement preferred):

```yaml
  url_launcher: ^6.3.0
```

- [ ] **Step 3: Run `flutter pub get`**

Run: `flutter pub get`
Expected: Output ends with `Got dependencies!` and no errors.

- [ ] **Step 4: Verify the package is resolved**

Run: `grep -c "url_launcher:" pubspec.lock`
Expected: number ≥ 1.

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "deps: add url_launcher for opening document file URLs"
```

---

## Task 2: Create `Document` model with TDD

**Files:**
- Create: `lib/models/document.dart`
- Test: `test/models/document_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/models/document_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to confirm it fails**

Run: `flutter test test/models/document_test.dart`
Expected: FAIL — `Target of URI doesn't exist: 'package:ginbec_mobile_app/models/document.dart'`.

- [ ] **Step 3: Implement `Document`**

Create `lib/models/document.dart`:

```dart
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
```

- [ ] **Step 4: Run the test to confirm it passes**

Run: `flutter test test/models/document_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/models/document.dart test/models/document_test.dart
git commit -m "feat(models): add Document model with fromJson"
```

---

## Task 3: Create `DocumentStatus` mapping with TDD

**Files:**
- Create: `lib/models/document_status.dart`
- Test: `test/models/document_status_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/models/document_status_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to confirm it fails**

Run: `flutter test test/models/document_status_test.dart`
Expected: FAIL — file not found.

- [ ] **Step 3: Implement `DocumentStatus`**

Create `lib/models/document_status.dart`:

```dart
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
```

- [ ] **Step 4: Run the test to confirm it passes**

Run: `flutter test test/models/document_status_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/models/document_status.dart test/models/document_status_test.dart
git commit -m "feat(models): add DocumentStatus color/label mapping"
```

---

## Task 4: Create `DocumentService`

**Files:**
- Create: `lib/services/document_service.dart`

No tests in this task — services hit the live network and the project has no mocking infra; behavior gets exercised through manual UAT after Task 8.

- [ ] **Step 1: Create the service**

Create `lib/services/document_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';

class DocumentPage {
  final List<Document> items;
  final int pageNumber;
  final bool last;
  DocumentPage({required this.items, required this.pageNumber, required this.last});
}

class DocumentService {
  DocumentService._();
  static final DocumentService instance = DocumentService._();

  Dio get _dio => ApiClient.instance.dio;

  Future<DocumentPage> list({
    int page = 0,
    int size = 20,
    String? status,
    int? expiringWithin,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'size': size,
      if (status != null) 'status': status,
      if (expiringWithin != null) 'expiring_within': expiringWithin,
    };
    final res = await _dio.get('/documents', queryParameters: params);
    final body = res.data['data'] as Map<String, dynamic>;
    final content = (body['content'] as List? ?? [])
        .map((e) => Document.fromJson(e as Map<String, dynamic>))
        .toList();
    return DocumentPage(
      items: content,
      pageNumber: body['pageNumber'] as int? ?? page,
      last: body['last'] as bool? ?? true,
    );
  }

  Future<Document> getById(int id) async {
    final res = await _dio.get('/documents/$id');
    return Document.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
```

- [ ] **Step 2: Confirm it analyzes clean**

Run: `flutter analyze lib/services/document_service.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/services/document_service.dart
git commit -m "feat(services): add DocumentService (list, getById)"
```

---

## Task 5: Create `ApprovalService`

**Files:**
- Create: `lib/services/approval_service.dart`

- [ ] **Step 1: Create the service**

Create `lib/services/approval_service.dart`:

```dart
import 'package:dio/dio.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';

class ApprovalService {
  ApprovalService._();
  static final ApprovalService instance = ApprovalService._();

  Dio get _dio => ApiClient.instance.dio;

  /// Finds the most recent pending approval for [documentId].
  /// Returns null if none exists.
  Future<int?> findPendingApprovalIdFor(int documentId) async {
    final res = await _dio.get(
      '/approvals',
      queryParameters: {'status': 'PENDING', 'size': 200, 'page': 0},
    );
    final list = (res.data['data']?['content'] as List? ?? []);
    for (final item in list) {
      if ((item as Map<String, dynamic>)['documentId'] == documentId) {
        return item['approvalId'] as int?;
      }
    }
    return null;
  }

  /// Decides on an approval. [statusCode] is "APPROVED" or "REJECTED".
  Future<void> decide({
    required int approvalId,
    required String statusCode,
    String comment = '',
  }) async {
    await _dio.put(
      '/approvals/$approvalId/decide',
      data: {'statusCode': statusCode, 'comment': comment},
    );
  }
}
```

- [ ] **Step 2: Confirm it analyzes clean**

Run: `flutter analyze lib/services/approval_service.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/services/approval_service.dart
git commit -m "feat(services): add ApprovalService (find + decide)"
```

---

## Task 6: Create `DocumentCard` widget

**Files:**
- Create: `lib/widgets/document_card.dart`

- [ ] **Step 1: Create the widget**

Create `lib/widgets/document_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/models/document_status.dart';

class DocumentCard extends StatelessWidget {
  final Document document;
  final VoidCallback onTap;
  const DocumentCard({super.key, required this.document, required this.onTap});

  String _expiryText() {
    final d = document.expiryDate;
    if (d == null) return '—';
    final days = d.difference(DateTime.now()).inDays;
    final iso = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
    if (days < 0) return '$iso (ផុតកំណត់)';
    return '$iso (នៅសល់ ${days} ថ្ងៃ)';
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = DocumentStatus.colorFor(document.statusCode);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.description, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.documentName,
                      style: const TextStyle(
                        fontFamily: 'KhmerOSSiemreap',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      document.statusLabel,
                      style: TextStyle(
                        fontFamily: 'KhmerOSSiemreap',
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (document.documentTypeName != null)
                Text('ប្រភេទ: ${document.documentTypeName}',
                  style: const TextStyle(
                    fontFamily: 'KhmerOSSiemreap', fontSize: 12, color: Colors.black54)),
              if (document.officerName != null)
                Text('មន្ត្រី: ${document.officerName}',
                  style: const TextStyle(
                    fontFamily: 'KhmerOSSiemreap', fontSize: 12, color: Colors.black54)),
              Text('ផុតកំណត់: ${_expiryText()}',
                style: TextStyle(
                  fontFamily: 'KhmerOSSiemreap',
                  fontSize: 12,
                  color: GColor.primarycolor.withValues(alpha: 0.9))),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Confirm it analyzes clean**

Run: `flutter analyze lib/widgets/document_card.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/widgets/document_card.dart
git commit -m "feat(widgets): add DocumentCard list row"
```

---

## Task 7: Build `DocumentScreen` with three sub-tabs and pagination

**Files:**
- Create: `lib/screens/document_screen/document_screen.dart`

- [ ] **Step 1: Create the screen with sub-tab state machinery**

Create `lib/screens/document_screen/document_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/services/document_service.dart';
import 'package:ginbec_mobile_app/widgets/document_card.dart';
import 'package:ginbec_mobile_app/screens/document_screen/document_detail.dart';

enum _SubTab { pending, recent, expiring }

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  _SubTab _active = _SubTab.pending;

  // Independent per-tab state
  final _state = {
    _SubTab.pending:  _TabState(),
    _SubTab.recent:   _TabState(),
    _SubTab.expiring: _TabState(),
  };

  @override
  void initState() {
    super.initState();
    _loadInitial(_active);
  }

  Future<void> _loadInitial(_SubTab tab) async {
    final s = _state[tab]!;
    if (s.items.isNotEmpty || s.isLoading) return;
    setState(() => s.isLoading = true);
    try {
      final page = await _fetch(tab, 0);
      setState(() {
        s.items.addAll(page.items);
        s.currentPage = 0;
        s.hasMore = !page.last;
        s.isLoading = false;
        s.error = null;
      });
    } catch (e) {
      setState(() {
        s.isLoading = false;
        s.error = 'មិនអាចទាញយកបាន';
      });
    }
  }

  Future<void> _loadMore(_SubTab tab) async {
    final s = _state[tab]!;
    if (s.isLoading || !s.hasMore) return;
    setState(() => s.isLoading = true);
    try {
      final next = s.currentPage + 1;
      final page = await _fetch(tab, next);
      setState(() {
        s.items.addAll(page.items);
        s.currentPage = next;
        s.hasMore = !page.last;
        s.isLoading = false;
      });
    } catch (_) {
      setState(() => s.isLoading = false);
    }
  }

  Future<void> _refresh(_SubTab tab) async {
    final s = _state[tab]!;
    setState(() {
      s.items.clear();
      s.currentPage = 0;
      s.hasMore = true;
      s.error = null;
    });
    await _loadInitial(tab);
  }

  Future<DocumentPage> _fetch(_SubTab tab, int page) {
    switch (tab) {
      case _SubTab.pending:
        return DocumentService.instance.list(page: page, status: 'PENDING');
      case _SubTab.recent:
        return DocumentService.instance.list(page: page);
      case _SubTab.expiring:
        return DocumentService.instance.list(page: page, expiringWithin: 30);
    }
  }

  String _emptyMessage(_SubTab tab) {
    switch (tab) {
      case _SubTab.pending:  return 'មិនមានឯកសារកំពុងរង់ចាំ';
      case _SubTab.recent:   return 'មិនមានឯកសារថ្មីៗ';
      case _SubTab.expiring: return 'មិនមានឯកសារផុតកំណត់ក្នុង ៣០ ថ្ងៃ';
    }
  }

  void _openDetail(Document doc) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DocumentDetail(document: doc)),
    );
    if (changed == true) await _refresh(_active);
  }

  @override
  Widget build(BuildContext context) {
    final s = _state[_active]!;
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      appBar: AppBar(
        title: const Text('ឯកសារ',
          style: TextStyle(fontFamily: 'KhmerOSMoulLightRegular')),
        backgroundColor: GColor.backgroundcolor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _SubTabBar(active: _active, onSelect: (t) {
            setState(() => _active = t);
            _loadInitial(t);
          }),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(_active),
              child: _buildList(s),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(_TabState s) {
    if (s.isLoading && s.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.error != null && s.items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 100),
        Center(child: Text(s.error!,
          style: const TextStyle(fontFamily: 'KhmerOSSiemreap'))),
        const SizedBox(height: 16),
        Center(child: TextButton(
          onPressed: () => _refresh(_active),
          child: const Text('ព្យាយាមម្តងទៀត',
            style: TextStyle(fontFamily: 'KhmerOSSiemreap')))),
      ]);
    }
    if (s.items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 120),
        Center(child: Text(_emptyMessage(_active),
          style: const TextStyle(
            fontFamily: 'KhmerOSSiemreap', color: Colors.black54))),
      ]);
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100) {
          _loadMore(_active);
        }
        return false;
      },
      child: ListView.builder(
        itemCount: s.items.length + (s.hasMore ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i >= s.items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final doc = s.items[i];
          return DocumentCard(document: doc, onTap: () => _openDetail(doc));
        },
      ),
    );
  }
}

class _TabState {
  final List<Document> items = [];
  int currentPage = 0;
  bool hasMore = true;
  bool isLoading = false;
  String? error;
}

class _SubTabBar extends StatelessWidget {
  final _SubTab active;
  final ValueChanged<_SubTab> onSelect;
  const _SubTabBar({required this.active, required this.onSelect});

  Widget _chip(BuildContext ctx, _SubTab tab, String label) {
    final isActive = tab == active;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(tab),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? GColor.primarycolor : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'KhmerOSSiemreap',
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? GColor.primarycolor : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(children: [
        _chip(context, _SubTab.pending,  'កំពុងរង់ចាំ'),
        _chip(context, _SubTab.recent,   'ថ្មីៗ'),
        _chip(context, _SubTab.expiring, 'ផុតកំណត់'),
      ]),
    );
  }
}
```

- [ ] **Step 2: Stub `DocumentDetail` so this file compiles**

Create `lib/screens/document_screen/document_detail.dart` as a placeholder (full implementation in Task 8):

```dart
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/models/document.dart';

class DocumentDetail extends StatelessWidget {
  final Document document;
  const DocumentDetail({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ឯកសារ')),
      body: Center(child: Text(document.documentName)),
    );
  }
}
```

- [ ] **Step 3: Confirm both files analyze clean**

Run: `flutter analyze lib/screens/document_screen/`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/screens/document_screen/document_screen.dart lib/screens/document_screen/document_detail.dart
git commit -m "feat(screens): add DocumentScreen with 3 sub-tabs and pagination"
```

---

## Task 8: Implement `DocumentDetail` with download + admin actions

**Files:**
- Modify: `lib/screens/document_screen/document_detail.dart`

- [ ] **Step 1: Replace the stub with the full detail screen**

Overwrite `lib/screens/document_screen/document_detail.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/models/document_status.dart';
import 'package:ginbec_mobile_app/services/approval_service.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';

class DocumentDetail extends StatefulWidget {
  final Document document;
  const DocumentDetail({super.key, required this.document});

  @override
  State<DocumentDetail> createState() => _DocumentDetailState();
}

class _DocumentDetailState extends State<DocumentDetail> {
  bool _downloading = false;
  bool _deciding = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final perms = await StorageService.instance.getPermissions();
    if (!mounted) return;
    setState(() => _isAdmin = perms.contains('DOC_APPROVE'));
  }

  Future<void> _download() async {
    final url = widget.document.fileUrl;
    if (url == null || url.isEmpty) return;
    setState(() => _downloading = true);
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('មិនអាចទាញយកបាន',
            style: TextStyle(fontFamily: 'KhmerOSSiemreap'))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('មិនអាចទាញយកបាន',
            style: TextStyle(fontFamily: 'KhmerOSSiemreap'))));
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _decide(String statusCode) async {
    String comment = '';
    if (statusCode == 'REJECTED') {
      final result = await _promptRejectReason();
      if (result == null) return; // cancelled
      comment = result;
    }
    setState(() => _deciding = true);
    try {
      final apprId = await ApprovalService.instance
          .findPendingApprovalIdFor(widget.document.documentId);
      if (apprId == null) {
        _toast('មិនអាចស្វែងរកសំណើ');
        return;
      }
      await ApprovalService.instance
          .decide(approvalId: apprId, statusCode: statusCode, comment: comment);
      if (!mounted) return;
      Navigator.of(context).pop(true); // signal list to refresh
    } catch (_) {
      _toast('មានបញ្ហា ព្យាយាមម្តងទៀត');
    } finally {
      if (mounted) setState(() => _deciding = false);
    }
  }

  Future<String?> _promptRejectReason() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('មូលហេតុបដិសេធ',
          style: TextStyle(fontFamily: 'KhmerOSSiemreap')),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'សូមបញ្ចូលមូលហេតុ',
            hintStyle: TextStyle(fontFamily: 'KhmerOSSiemreap'),
          ),
          style: const TextStyle(fontFamily: 'KhmerOSSiemreap'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('បោះបង់',
              style: TextStyle(fontFamily: 'KhmerOSSiemreap')),
          ),
          TextButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isEmpty) return;
              Navigator.of(ctx).pop(t);
            },
            child: const Text('បញ្ជូន',
              style: TextStyle(fontFamily: 'KhmerOSSiemreap')),
          ),
        ],
      ),
    );
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg,
        style: const TextStyle(fontFamily: 'KhmerOSSiemreap'))));
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final badgeColor = DocumentStatus.colorFor(doc.statusCode);
    final hasFile = doc.fileUrl != null && doc.fileUrl!.isNotEmpty;
    final canDecide = _isAdmin && doc.statusCode == 'PENDING';

    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      appBar: AppBar(
        title: const Text('ឯកសារ',
          style: TextStyle(fontFamily: 'KhmerOSMoulLightRegular')),
        backgroundColor: GColor.backgroundcolor,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: Icon(Icons.description, size: 64)),
          const SizedBox(height: 8),
          Center(child: Text(doc.documentName,
            style: const TextStyle(
              fontFamily: 'KhmerOSSiemreap', fontSize: 18, fontWeight: FontWeight.w700))),
          if (doc.documentNumber != null)
            Center(child: Text('#${doc.documentNumber}',
              style: const TextStyle(color: Colors.black54))),
          const SizedBox(height: 12),
          Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(doc.statusLabel,
              style: TextStyle(
                fontFamily: 'KhmerOSSiemreap',
                color: badgeColor, fontWeight: FontWeight.w600)),
          )),
          const SizedBox(height: 24),
          _InfoRow(label: 'ប្រភេទ',     value: doc.documentTypeName ?? '—'),
          _InfoRow(label: 'មន្ត្រី',     value: doc.officerName ?? '—'),
          _InfoRow(label: 'ថ្ងៃផុតកំណត់', value: _formatDate(doc.expiryDate)),
          _InfoRow(label: 'បានបង្កើត',   value: _formatDate(doc.createdAt)),
          if (doc.note != null && doc.note!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('ចំណាំ',
              style: TextStyle(
                fontFamily: 'KhmerOSSiemreap', fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(doc.note!,
                style: const TextStyle(fontFamily: 'KhmerOSSiemreap')),
            ),
          ],
          const SizedBox(height: 28),
          if (hasFile)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloading ? null : _download,
                icon: const Icon(Icons.download),
                label: Text(_downloading ? 'កំពុងទាញយក...' : 'ទាញយកឯកសារ',
                  style: const TextStyle(fontFamily: 'KhmerOSSiemreap')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GColor.primarycolor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          if (canDecide) ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: _deciding ? null : () => _decide('APPROVED'),
                icon: const Icon(Icons.check, color: Color(0xFF22A06B)),
                label: const Text('យល់ព្រម',
                  style: TextStyle(
                    fontFamily: 'KhmerOSSiemreap', color: Color(0xFF22A06B))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF22A06B)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: _deciding ? null : () => _decide('REJECTED'),
                icon: const Icon(Icons.close, color: Color(0xFFE5484D)),
                label: const Text('បដិសេធ',
                  style: TextStyle(
                    fontFamily: 'KhmerOSSiemreap', color: Color(0xFFE5484D))),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE5484D)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )),
            ]),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
              style: const TextStyle(
                fontFamily: 'KhmerOSSiemreap', color: Colors.black54)),
          ),
          Expanded(
            child: Text(value,
              style: const TextStyle(
                fontFamily: 'KhmerOSSiemreap', fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add permissions storage to `StorageService`**

Open `lib/services/storage_service.dart`.

Find the block of key constants (around line 11–16):

```dart
  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyUserEmail = 'user_email';
  static const _keyUserName = 'user_name';
  static const _keyUserRole = 'user_role';
```

Add one more key after `_keyUserRole`:

```dart
  static const _keyPermissions = 'user_permissions';
```

Then, right before `Future<void> clearAll()` at the bottom of the class, add these two methods:

```dart
  Future<void> savePermissions(List<String> permissions) =>
      _storage.write(key: _keyPermissions, value: permissions.join(','));

  Future<List<String>> getPermissions() async {
    final raw = await _storage.read(key: _keyPermissions);
    if (raw == null || raw.isEmpty) return const [];
    return raw.split(',').where((s) => s.isNotEmpty).toList();
  }
```

- [ ] **Step 2b: Persist permissions at login**

Open `lib/screens/login_screen/login.dart` and find the block around lines 52–61 where `StorageService.instance.saveTokens(...)`, `saveUserId(...)`, etc. are called after a successful login response.

Add this call alongside the others (immediately after `saveUserRole`):

```dart
        StorageService.instance.savePermissions(
          ((data['permissions'] as List?) ?? const [])
              .map((e) => e.toString())
              .toList(),
        ),
```

If those calls are inside a `Future.wait([...])` block, keep the comma after each entry and add the new call as another list element.

- [ ] **Step 3: Confirm everything analyzes clean**

Run: `flutter analyze lib/screens/document_screen/ lib/services/storage_service.dart lib/screens/login_screen/login.dart`
Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/screens/document_screen/document_detail.dart lib/services/storage_service.dart lib/screens/login_screen/login.dart
git commit -m "feat(screens): implement DocumentDetail with download + approve/reject"
```

---

## Task 9: Wire the new tab into `MainScreen`

**Files:**
- Modify: `lib/screens/mainscreen.dart`

- [ ] **Step 1: Inspect the current file**

Run: `cat lib/screens/mainscreen.dart`

Confirm it currently has 4 tabs in this order: Home (0), Meetings (1), Alerts (2), Settings (3).

- [ ] **Step 2: Update the `_page` list to insert `DocumentScreen` at index 2**

Open `lib/screens/mainscreen.dart`.

Add this import at the top, in alphabetical order with the others:
```dart
import 'package:ginbec_mobile_app/screens/document_screen/document_screen.dart';
```

Find this block:
```dart
  late final List<Widget> _page = [
    Home(onNavigateToTab: _onTabSelected),
    MeetingScreen(),
    AlertScreen(),
    SettingScreen(),
  ];
```

Replace with:
```dart
  late final List<Widget> _page = [
    Home(onNavigateToTab: _onTabSelected),
    MeetingScreen(),
    DocumentScreen(),
    AlertScreen(),
    SettingScreen(),
  ];
```

- [ ] **Step 3: Add the 5th `TabButton` and shift indices**

Find this `Row` block (current 4 tabs):
```dart
              TabButton(
                  tittle: 'ទំព័រដើម',
                  icon: Icons.home,
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onTabSelected(0)),
              TabButton(
                  tittle: 'កិច្ចប្រជុំ',
                  icon: Icons.group,
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onTabSelected(1)),
              TabButton(
                  tittle: 'ការជូនដំណឹង',
                  icon: Icons.notifications,
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onTabSelected(2)),
              TabButton(
                  tittle: 'ការកំណត់',
                  icon: Icons.settings,
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onTabSelected(3)),
```

Replace with (Documents inserted at index 2, others shifted to 3 and 4):
```dart
              TabButton(
                  tittle: 'ទំព័រដើម',
                  icon: Icons.home,
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onTabSelected(0)),
              TabButton(
                  tittle: 'កិច្ចប្រជុំ',
                  icon: Icons.group,
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onTabSelected(1)),
              TabButton(
                  tittle: 'ឯកសារ',
                  icon: Icons.description,
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onTabSelected(2)),
              TabButton(
                  tittle: 'ការជូនដំណឹង',
                  icon: Icons.notifications,
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onTabSelected(3)),
              TabButton(
                  tittle: 'ការកំណត់',
                  icon: Icons.settings,
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onTabSelected(4)),
```

- [ ] **Step 4: Audit `Home` for hardcoded tab indices**

Run: `grep -n "onNavigateToTab\|_onTabSelected\|onTabSelected\|navigateToTab" lib/screens/home_screen/home.dart`

For each numeric tab index passed in those calls, update it:
- `0` (Home) → stays `0`
- `1` (Meetings) → stays `1`
- `2` (was Alerts) → becomes `3`
- `3` (was Settings) → becomes `4`

If no hardcoded indices are found, skip to Step 5.

- [ ] **Step 5: Confirm analysis passes**

Run: `flutter analyze lib/screens/mainscreen.dart lib/screens/home_screen/home.dart`
Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/screens/mainscreen.dart lib/screens/home_screen/home.dart
git commit -m "feat(nav): add Documents tab as 5th bottom nav target"
```

---

## Task 10: Manual UAT on a running device

No code changes — purely verification.

- [ ] **Step 1: Build and run on a device or emulator**

Run: `flutter run`
Expected: App boots without errors. Bottom nav shows 5 tabs.

- [ ] **Step 2: Verify Pending sub-tab**

Tap the new "ឯកសារ" tab. Confirm:
- Three sub-tabs visible: កំពុងរង់ចាំ / ថ្មីៗ / ផុតកំណត់
- "កំពុងរង់ចាំ" is active by default
- With the DB currently empty, the empty state `មិនមានឯកសារកំពុងរង់ចាំ` appears.

- [ ] **Step 3: Verify each sub-tab switches and refreshes**

Tap "ថ្មីៗ" → empty state for recent. Tap "ផុតកំណត់" → empty state for expiring.
Pull-to-refresh on each tab → spinner appears briefly, list reloads.

- [ ] **Step 4: Verify pre-existing tabs still work**

Tap Home → Home renders. Tap Meetings → Meetings renders. Tap Alerts → Alerts renders. Tap Settings → Settings renders. No index off-by-one bugs.

- [ ] **Step 5: Verify download + decide once seeded data exists**

Skip if no documents are seeded. Otherwise:
- Log in as `admin@system.kh` / `Admin@1234` (credentials documented in OpenAPI info section)
- Tap a Pending document → detail screen renders
- Tap "ទាញយកឯកសារ" → file opens in system viewer (or browser)
- Tap "យល់ព្រម" → approves and pops back; the doc disappears from Pending
- Tap a different Pending doc → "បដិសេធ" → reason dialog → enter reason → submits

- [ ] **Step 6: Run full static analysis on the whole project**

Run: `flutter analyze`
Expected: `No issues found!` (or only pre-existing warnings unrelated to this feature)

- [ ] **Step 7: Run unit tests**

Run: `flutter test`
Expected: All tests pass, including new `document_test.dart` and `document_status_test.dart`.

No commit needed — this task only verifies.

---

## Done

After Task 10 passes, the feature is shippable. The 3 spec "open implementation questions" have been resolved:

1. ✅ `POST /approvals` payload — actually `PUT /approvals/{id}/decide` with `{ statusCode, comment }` is used.
2. ✅ `DocumentResponse.fileUrl` is passed verbatim to `url_launcher` — works for both presigned R2 URLs and any future server-side URL shape, as long as it's an `http(s)` URI. If the backend ever returns a relative path (e.g., `/attachments/1/download`), the download will fail with a snackbar and the fix is a small Dio call wrapper — out of MVP scope.
3. ✅ No `officer_id` is sent. Backend enforces per-user scoping by bearer token, eliminating the need to map `userId` ↔ `officer_id` on the client.
