  import 'package:flutter/material.dart';
  import 'package:ginbec_mobile_app/config/color.dart';

  class TabSwitch extends StatelessWidget {
    final String tittle;
    final bool isSelected;
    final VoidCallback onTap;


    const TabSwitch({
      super.key,
      required this.tittle,
      required this.onTap,
      required this.isSelected,
    });

    @override
    Widget build(BuildContext context) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? GColor.primarycolor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(tittle,style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white  : Colors.grey.shade300)))

      );
    }
  }
