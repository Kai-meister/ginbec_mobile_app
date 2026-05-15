import 'package:flutter/material.dart';


class DashCard extends StatelessWidget {
  final String number;
  final String label;
  final VoidCallback? onTap;
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
        height: 130,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardbg ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: Offset(0, 2)
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
