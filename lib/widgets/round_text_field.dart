import 'package:flutter/material.dart';

class RoundTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final double height;
  final double width;


  const RoundTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.isPassword,
    required this.width,
    required this.height
  });

  @override
  State<RoundTextField> createState() => _RoundTextFieldState();
}

class _RoundTextFieldState extends State<RoundTextField> {
  late bool _isPasswordVisible = true;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: TextField(
        obscureText: widget.isPassword ? !_isPasswordVisible : false,
        controller: widget.controller,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon),
          suffix: widget.isPassword ? IconButton(
            icon: Icon(
            _isPasswordVisible
                ? Icons.visibility
                : Icons.visibility_off,
          ),onPressed: (){
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },):null,
          hintText: widget.hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
        ),
      ),
    );
  }
}
