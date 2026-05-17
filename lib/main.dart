import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/screens/login_screen/login.dart';
import 'package:ginbec_mobile_app/screens/mainscreen.dart';
import 'package:ginbec_mobile_app/services/app_navigator.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  navigatorKey: appNavigatorKey,
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
  home: const AuthGate(),
));

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _hasToken = _checkToken();

  Future<bool> _checkToken() async {
    final token = await StorageService.instance.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasToken,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == true ? const MainScreen() : const LoginScreen();
      },
    );
  }
}