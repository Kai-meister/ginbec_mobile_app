import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Floating pill switcher. Sits over the gradient hero edge in the
/// Documents tab. Caller controls the active index; this is a stateless
/// segmented control.
class SegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GColor.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GColor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(labels.length, (i) {
          final isActive = i == activeIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isActive ? GColor.primarycolor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : GColor.textMuted,
                    fontFamily: 'KhmerOSSiemreap',
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}