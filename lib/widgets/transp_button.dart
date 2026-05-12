import 'package:flutter/material.dart';
import '../config/color.dart';

class TranspButton extends StatefulWidget {
  final IconData icon;
  final String txt;
  final VoidCallback onPressed;
  const TranspButton({
    super.key,
    required this.icon,
    required this.txt,
    required this.onPressed,
  });

  @override
  State<TranspButton> createState() => _TranspButtonState();
}

class _TranspButtonState extends State<TranspButton> {
  bool _onpressed = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: Container(
          height: 60,
          width: 400,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),

        ),

        child: Row(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month,size: 23,color: Colors.grey.shade500,),
            GestureDetector(

              onTap: widget.onPressed,
              onTapDown: (_) => setState(() => _onpressed = true),
              onTapUp: (_) => setState(() => _onpressed = false),
              child: Center(
                child: Text(
                  ' '+widget.txt,style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade500,
                  decoration: _onpressed ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: GColor.primarycolor,
                  decorationThickness: 2,
                ),
                ),
              ),
            ),
          ],
        ),
    ),
    );
  }
}
