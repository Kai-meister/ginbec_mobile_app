import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget? child;
  final double size;
  final Color? backgroundColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final IconData? icon;
  final String? text;
  final double? iconSize;
  final double? fontSize;
  final Color? textColor;

  const RoundButton({
    super.key,
    required this.onPressed,
    this.child,
    this.height,
    this.width,
    this.icon,
    this.iconSize =12,
    this.fontSize =12,
    this.text,
    this.textColor,
    this.size = 46,
    this.borderRadius = 12,
    this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Theme.of(context).primaryColor,
      elevation: 4,
      shape: borderRadius > 0
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))
          : const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          height: height ?? size,
          width: width ?? size,
          child: Center(
            child: child ?? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, color: textColor, size: iconSize),
                if (icon != null && text != null) SizedBox(height: 8),
                if (text != null) Text(
                  text!,
                  style: TextStyle(color: textColor, fontSize: fontSize),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}