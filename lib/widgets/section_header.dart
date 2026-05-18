import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

/// Row used above each home/documents section: bold title on the left,
/// optional "មើលទាំងអស់ →" affordance on the right.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.seeAllLabel = 'មើលទាំងអស់ →',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: GColor.textBody,
              fontFamily: 'KhmerOSSiemreap',
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Text(
                  seeAllLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color: GColor.primarycolor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'KhmerOSSiemreap',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}