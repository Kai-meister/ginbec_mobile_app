import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

class DashCard extends StatelessWidget {
  final String number;
  final String label;
  final VoidCallback? onTap;
  /// Optional override for the card background. Defaults to [GColor.surfaceCard].
  final Color? cardbg;
  final double width;

  const DashCard({
    super.key,
    required this.number,
    required this.label,
    required this.width,
    this.onTap,
    this.cardbg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardbg ?? GColor.surfaceCard,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: GColor.primarycolor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: GColor.textMuted,
                fontFamily: 'KhmerOSSiemreap',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
