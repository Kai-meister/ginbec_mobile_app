import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/login_screen/register.dart';
import 'package:ginbec_mobile_app/screens/login_screen/reset_password.dart';
import 'package:ginbec_mobile_app/widgets/avatar.dart';
import 'package:ginbec_mobile_app/Widgets/round_text_field.dart';
import 'package:ginbec_mobile_app/Widgets/round_button.dart';
import 'package:ginbec_mobile_app/screens/home_screen/home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body:Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          children: [
            SizedBox(height: 80),
            Center(child: AvatarWidget(
                imageUrl: 'lib/assets/ginbec_logo.png', size: 200)),

            Text('អគ្គាធិការដ្ឋានពុទ្ធិកសិក្សាជាតិ',style: TextStyle(
                fontSize: 22,
                fontFamily: 'KhmerOSMoulLightRegular'),textAlign: TextAlign.right,),
            Text('(អ.ព.ស.ជ.ក)',style: TextStyle(
                fontSize: 22,
                fontFamily: 'KhmerOSMoulLightRegular'),textAlign: TextAlign.center,),
            SizedBox(height: 20),
            Text('ពាក្យសម្ងាត់',style: TextStyle(
                fontSize: 22,
                fontFamily: ''),textAlign: TextAlign.end),
            RoundTextField(controller: txtEmail, hintText: 'your.email@example.com', icon: Icons.email,isPassword: false,width: 400,height: 60,),
            SizedBox(height: 20),
            Text('លេខសម្ងាត់',style: TextStyle(
                fontSize: 22,
                fontFamily: ''),textAlign: TextAlign.end),
            RoundTextField(controller: txtPassword, hintText: '********', icon: Icons.lock,isPassword: true,width: 400,height: 60,),
            SizedBox(height: 20),
            RoundButton(
              onPressed: (){Navigator.push(context,MaterialPageRoute(builder:(context)=>Home()),);},
              size:120,
              height: 60,
              width: 400,
              text: 'Sign In',
              textColor: Colors.white,
              fontSize: 20,
              backgroundColor: GColor.primarycolor,),
            SizedBox(height: 20),
            TextButton(
                onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context)=>ResetPassword()));},
                child: Text('forgot password',
                  style: TextStyle(color: GColor.primarycolor),)),
            SizedBox(height: 70),
            TextButton(
                onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context)=>RegisterAccount()));},
                child: Text("Don't have an account? Register here",
                  style: TextStyle(color: GColor.primarycolor),)),

          ],
        ),
      ),
    );
  }
}
