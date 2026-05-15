import 'package:flutter/material.dart';
import '../config/color.dart';

class TranspButton extends StatefulWidget {
  final String txt;
  final VoidCallback onPressed;
  final double width;

  const TranspButton({
    super.key,
    required this.txt,
    required this.onPressed,
    required this.width,
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
          width: widget.width,
        decoration: BoxDecoration(
          border: Border.all(color: _onpressed ? GColor.primarycolor : Colors.grey.shade500),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Row(

          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_month,size: 23,color: _onpressed ? GColor.primarycolor : Colors.grey.shade500,),
            GestureDetector(
              onTap: widget.onPressed,
              onTapDown: (_) => setState(() => _onpressed = true),
              onTapUp: (_) => setState(() => _onpressed = false),
              child: Center(
                child: Text(
                  ' ${widget.txt}',style: TextStyle(
                  fontSize: 20,
                  color: _onpressed ? GColor.primarycolor : Colors.grey.shade500,
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
