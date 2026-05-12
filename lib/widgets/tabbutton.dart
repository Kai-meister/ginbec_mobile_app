import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';

class TabButton extends StatelessWidget {
  final String tittle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.tittle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? GColor.primarycolor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : GColor.secondarycolor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tittle,
            style: TextStyle(
              color: isSelected ? GColor.primarycolor : GColor.secondarycolor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}