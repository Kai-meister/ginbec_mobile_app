import 'package:flutter/material.dart';

class Attendee {
  final String name;
  final String role;
  const Attendee({required this.name, required this.role});
}

class BookMeetingRoomSheet extends StatefulWidget {
  final List<String> rooms;
  final List<Attendee> attendees;
  final String? initialRoom;
  final void Function(Map<String, dynamic> booking)? onSubmit;

  const BookMeetingRoomSheet({
    super.key,
    required this.rooms,
    required this.attendees,
    this.initialRoom,
    this.onSubmit,
  });

  @override
  State<BookMeetingRoomSheet> createState() => _BookMeetingRoomSheetState();
}

class _BookMeetingRoomSheetState extends State<BookMeetingRoomSheet> {
  late String? _selectedRoom;
  DateTime? _date;
  final TextEditingController _startTimeCtrl = TextEditingController();
  final TextEditingController _endTimeCtrl = TextEditingController();
  final TextEditingController _topicCtrl = TextEditingController();
  final Set<int> _selectedAttendees = {};

  static const Color orange = Color(0xFFFF8A00);

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.initialRoom;
  }

  @override
  void dispose() {
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _topicCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _showTimeDialog({required bool isStart}) async {
    final ctrl = isStart ? _startTimeCtrl : _endTimeCtrl;
    final existing = _parseTime(ctrl.text);

    final hhCtrl = TextEditingController(
      text: existing != null ? existing.hour.toString().padLeft(2, '0') : '',
    );
    final mmCtrl = TextEditingController(
      text: existing != null ? existing.minute.toString().padLeft(2, '0') : '',
    );
    final hhFocus = FocusNode();
    final mmFocus = FocusNode();

    void onHhChanged() {
      if (hhCtrl.text.length >= 2 && hhFocus.hasFocus) {
        mmFocus.requestFocus();
        mmCtrl.selection = TextSelection(
          baseOffset: 0,
          extentOffset: mmCtrl.text.length,
        );
      }
    }
    hhCtrl.addListener(onHhChanged);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isStart ? 'ម៉ោងចាប់ផ្តើម' : 'ម៉ោងបញ្ចប់',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _timeBox(hhCtrl, 'HH', focusNode: hhFocus, autofocus: true),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(':', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            _timeBox(mmCtrl, 'MM', focusNode: mmFocus),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('បោះបង់'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: orange),
            onPressed: () {
              final hText = hhCtrl.text.trim();
              final mText = mmCtrl.text.trim();
              final h = hText.isEmpty ? 0 : int.tryParse(hText);
              final m = mText.isEmpty ? 0 : int.tryParse(mText);
              if (h == null || m == null ||
                  h < 0 || h > 23 || m < 0 || m > 59) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ម៉ោងមិនត្រឹមត្រូវ។ HH: 0–23, MM: 0–59')),
                );
                return;
              }
              ctrl.text =
                  '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
              Navigator.pop(ctx);
            },
            child: const Text('យល់ព្រម', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    hhCtrl.removeListener(onHhChanged);
    hhCtrl.dispose();
    mmCtrl.dispose();
    hhFocus.dispose();
    mmFocus.dispose();
  }

  Widget _timeBox(
    TextEditingController ctrl,
    String hint, {
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        autofocus: autofocus,
        keyboardType: TextInputType.number,
        maxLength: 2,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: TextStyle(fontSize: 16, color: Colors.grey.shade400),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  TimeOfDay? _parseTime(String text) {
    final trimmed = text.trim();
    final parts = trimmed.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  void _submit() {
    final startTime = _parseTime(_startTimeCtrl.text);
    final endTime = _parseTime(_endTimeCtrl.text);

    if (_selectedRoom == null ||
        _date == null ||
        startTime == null ||
        endTime == null ||
        _topicCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('សូមបំពេញព័ត៌មានទាំងអស់។ ទម្រង់ម៉ោង: HH:mm'),
        ),
      );
      return;
    }

    final booking = {
      'room': _selectedRoom,
      'date': _date,
      'startTime': startTime,
      'endTime': endTime,
      'topic': _topicCtrl.text.trim(),
      'attendees': _selectedAttendees
          .map((i) => widget.attendees[i])
          .toList(),
    };
    widget.onSubmit?.call(booking);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label(Icons.calendar_today, 'ជ្រើសរើសបន្ទប់'),
                      _roomDropdown(),
                      const SizedBox(height: 16),
                      _label(Icons.calendar_today, 'កាលបរិច្ឆេទ'),
                      _dateField(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _timeColumn(isStart: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _timeColumn(isStart: false)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _label(Icons.description, 'ប្រធានបទកិច្ចប្រជុំ'),
                      _topicField(),
                      const SizedBox(height: 16),
                      _label(
                        Icons.group,
                        'ជ្រើសរើសអ្នកចូលរួម (${_selectedAttendees.length})',
                      ),
                      _attendeeList(),
                      const SizedBox(height: 20),
                      _submitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA94D), Color(0xFFFF6A00)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'កក់បន្ទប់ប្រជុំ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: orange, size: 18),
          const SizedBox(width: 8),
          Text(text,
              style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  BoxDecoration get _fieldDecoration => BoxDecoration(
    color: const Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade300),
  );

  Widget _roomDropdown() {
    return Container(
      decoration: _fieldDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedRoom,
          hint: const Text('ជ្រើសរើសបន្ទប់...'),
          items: widget.rooms
              .map((r) => DropdownMenuItem(value: r, child: Text(r)))
              .toList(),
          onChanged: (v) => setState(() => _selectedRoom = v),
        ),
      ),
    );
  }

  Widget _dateField() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        decoration: _fieldDecoration,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _date == null
                    ? 'ថ្ងៃ/ខែ/ឆ្នាំ'
                    : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}/${_date!.year}',
                style: TextStyle(
                  color: _date == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.calendar_month, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _timeColumn({required bool isStart}) {
    final ctrl = isStart ? _startTimeCtrl : _endTimeCtrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(Icons.access_time, isStart ? 'ម៉ោងចាប់ផ្តើម' : 'ម៉ោងបញ្ចប់'),
        InkWell(
          onTap: () => _showTimeDialog(isStart: isStart),
          child: Container(
            decoration: _fieldDecoration,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: ctrl,
                    builder: (context, value, child) => Text(
                      value.text.isEmpty ? 'HH:MM' : value.text,
                      style: TextStyle(
                        color: value.text.isEmpty ? Colors.grey : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const Icon(Icons.access_time, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _topicField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: orange, width: 1.5),
      ),
      child: TextField(
        controller: _topicCtrl,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'បញ្ចូលប្រធានបទ ឬរបៀបវារៈកិច្ចប្រជុំ...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _attendeeList() {
    // Fixed height + internal scroll for many attendees
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: widget.attendees.length,
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemBuilder: (context, i) {
          final a = widget.attendees[i];
          final selected = _selectedAttendees.contains(i);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? orange.withValues(alpha: 0.1)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? orange : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      Text(a.role,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _selectedAttendees.remove(i);
                    } else {
                      _selectedAttendees.add(i);
                    }
                  }),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor:
                    selected ? orange : Colors.grey.shade300,
                    child: Icon(
                      selected ? Icons.check : Icons.add,
                      size: 18,
                      color: selected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'កក់កិច្ចប្រជុំ',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

/// Helper to show the sheet
Future<void> showBookMeetingRoomSheet(
    BuildContext context, {
      required List<String> rooms,
      required List<Attendee> attendees,
      String? initialRoom,
      void Function(Map<String, dynamic>)? onSubmit,
    }) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BookMeetingRoomSheet(
      rooms: rooms,
      attendees: attendees,
      initialRoom: initialRoom,
      onSubmit: onSubmit,
    ),
  );
}