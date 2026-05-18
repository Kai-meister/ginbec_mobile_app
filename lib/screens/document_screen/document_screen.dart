import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/models/document.dart';
import 'package:ginbec_mobile_app/services/document_service.dart';
import 'package:ginbec_mobile_app/widgets/document_card.dart';
import 'package:ginbec_mobile_app/widgets/gradient_hero.dart';
import 'package:ginbec_mobile_app/widgets/segmented_tabs.dart';
import 'package:ginbec_mobile_app/screens/document_screen/document_detail.dart';

enum _SubTab { pending, recent, expiring }

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  _SubTab _active = _SubTab.pending;

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

  String? _countLabel(_SubTab tab) {
    final s = _state[tab]!;
    if (s.items.isEmpty) return null;
    return '${s.items.length}${s.hasMore ? '+' : ''}';
  }

  void _openDetail(Document doc) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => DocumentDetail(document: doc)),
    );
    if (changed == true) await _refresh(_active);
  }

  static const _tabLabels = ['កំពុងរង់ចាំ', 'ថ្មីៗ', 'ផុតកំណត់'];
  static const _tabs = [_SubTab.pending, _SubTab.recent, _SubTab.expiring];

  @override
  Widget build(BuildContext context) {
    final s = _state[_active]!;
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: Column(
        children: [
          GradientHero(
            bottomPadding: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ឯកសារ',
                  style: TextStyle(
                    fontFamily: 'KhmerOSMoulLightRegular',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'គ្រប់គ្រងឯកសារនិងការអនុម័ត',
                  style: TextStyle(
                    fontFamily: 'KhmerOSSiemreap',
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _CountChip(
                      count: _countLabel(_SubTab.pending),
                      label: 'កំពុងរង់ចាំ',
                    ),
                    const SizedBox(width: 8),
                    _CountChip(
                      count: _countLabel(_SubTab.recent),
                      label: 'ថ្មីៗ',
                    ),
                    const SizedBox(width: 8),
                    _CountChip(
                      count: _countLabel(_SubTab.expiring),
                      label: 'នឹងផុត',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: SegmentedTabs(
                labels: _tabLabels,
                activeIndex: _tabs.indexOf(_active),
                onChanged: (i) {
                  setState(() => _active = _tabs[i]);
                  _loadInitial(_tabs[i]);
                },
              ),
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -10),
              child: RefreshIndicator(
                onRefresh: () => _refresh(_active),
                child: _buildList(s),
              ),
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
        const SizedBox(height: 80),
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
        const SizedBox(height: 100),
        Center(child: Text(_emptyMessage(_active),
          style: TextStyle(
            fontFamily: 'KhmerOSSiemreap',
            color: GColor.textMuted))),
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
        padding: const EdgeInsets.only(top: 6, bottom: 16),
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

class _CountChip extends StatelessWidget {
  final String? count;
  final String label;

  const _CountChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count ?? '—',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.9),
                fontFamily: 'KhmerOSSiemreap',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
