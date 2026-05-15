import 'package:flutter/material.dart';


class ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color? bttBg;
  final IconData icon;
  final String label;
  final double width;


  const ActionButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    required this.width,
    this.bttBg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 80,
            width: width,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: bttBg ?? Colors.grey,
              boxShadow: [BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8,
                offset: Offset(0,2),
              ),]
            ),
            child: Icon(icon,size: 40,color: Colors.white),
          ),
          Text(label,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
        ],
      ),

    );
  }
}
