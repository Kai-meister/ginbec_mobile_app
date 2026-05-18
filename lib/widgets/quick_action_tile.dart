import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Single tile used in the Home quick-actions grid.
/// White card · 1px subtle border · tinted icon square · Khmer label below.
class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: GColor.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GColor.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: GColor.surfaceTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: GColor.primarycolor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: GColor.textBody,
                fontFamily: 'KhmerOSSiemreap',
              ),
            ),
          ],
        ),
      ),
    );
  }
}