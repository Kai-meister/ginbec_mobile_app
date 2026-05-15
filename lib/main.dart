import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/screens/login_screen/login.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    fontFamily: 'battambangregular',
  ),
  builder: (context, child) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      final focus = FocusManager.instance.primaryFocus;
      if (focus != null && focus.hasFocus) focus.unfocus();
    },
    child: child,
  ),
  home: Scaffold(
    body: LoginScreen(),
  ),
));