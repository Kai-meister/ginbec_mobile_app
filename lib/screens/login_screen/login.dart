import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/login_screen/register.dart';
import 'package:ginbec_mobile_app/screens/login_screen/reset_password.dart';
import 'package:ginbec_mobile_app/screens/mainscreen.dart';
import 'package:ginbec_mobile_app/services/api_client.dart';
import 'package:ginbec_mobile_app/services/storage_service.dart';
import 'package:ginbec_mobile_app/widgets/avatar.dart';
import 'package:ginbec_mobile_app/Widgets/round_text_field.dart';
import 'package:ginbec_mobile_app/Widgets/round_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _txtEmail = TextEditingController();
  final _txtPassword = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _txtEmail.dispose();
    _txtPassword.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _txtEmail.text.trim();
    final password = _txtPassword.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('សូមបញ្ចូលអ៊ីមែល និងពាក្យសម្ងាត់');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient.instance.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data['data'];

      await Future.wait([
        StorageService.instance.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        ),
        StorageService.instance.saveUserId(data['userId']),
        StorageService.instance.saveUserEmail(data['email']),
        StorageService.instance.saveUserName(
          (data['userNameEn'] as String?) ?? (data['userNameKh'] as String?) ?? email,
        ),
      ]);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String?;
      _showError(msg ?? 'ការចូលបានបរាជ័យ។ សូមពិនិត្យអ៊ីមែល/ពាក្យសម្ងាត់');
    } catch (_) {
      _showError('មានបញ្ហា។ សូមព្យាយាមម្ដងទៀត');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fieldWidth = MediaQuery.of(context).size.width - 50;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: GColor.backgroundcolor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: AvatarWidget(
                    imageUrl: 'lib/assets/ginbec_logo.png',
                    size: 200,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'អគ្គាធិការដ្ឋានពុទ្ធិកសិក្សាជាតិ',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'KhmerOSMoulLightRegular',
                      ),
                    ),
                    Text(
                      '(អ.ព.ស.ជ.ក)',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'KhmerOSMoulLightRegular',
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'អ៊ីមែល',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    RoundTextField(
                      controller: _txtEmail,
                      hintText: 'your.email@example.com',
                      icon: Icons.email,
                      isPassword: false,
                      width: fieldWidth,
                      height: 60,
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ពាក្យសម្ងាត់',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    RoundTextField(
                      controller: _txtPassword,
                      hintText: '********',
                      icon: Icons.lock,
                      isPassword: true,
                      width: fieldWidth,
                      height: 60,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    RoundButton(
                      onPressed: _isLoading ? () {} : _login,
                      size: 120,
                      height: 60,
                      width: fieldWidth,
                      text: _isLoading ? 'កំពុងចូល...' : 'ចូលគណនី',
                      textColor: Colors.white,
                      fontSize: 20,
                      backgroundColor: _isLoading
                          ? Colors.grey
                          : GColor.primarycolor,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResetPassword(),
                          ),
                        );
                      },
                      child: Text(
                        'ភ្លេចពាក្យសម្ងាត់',
                        style: TextStyle(color: GColor.primarycolor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterAccount()),
                    );
                  },
                  child: Text(
                    'មិនទាន់មានគណនី? ចុះឈ្មោះនៅទីនេះ',
                    style: TextStyle(color: GColor.primarycolor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
