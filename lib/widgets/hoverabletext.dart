import 'package:flutter/material.dart';
import '../config/color.dart';

class Hoverabletext extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const Hoverabletext({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<Hoverabletext> createState() => _HoverabletextState();
}

class _HoverabletextState extends State<Hoverabletext> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: Text(
          widget.text,style: TextStyle(
          fontSize: 20,
          color: GColor.primarycolor,
          decoration: _isPressed ? TextDecoration.underline : TextDecoration.none,
          decorationColor: GColor.primarycolor,
          decorationThickness: 2,
        ),
        ),
      ),
    );
  }
}
