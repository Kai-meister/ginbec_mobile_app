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