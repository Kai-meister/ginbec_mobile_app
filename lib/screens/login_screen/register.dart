import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/login_screen/login.dart';

import '../../Widgets/round_button.dart';
import '../../Widgets/round_text_field.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  TextEditingController txtFname = TextEditingController();

  TextEditingController txtEmail = TextEditingController();

  TextEditingController txtPhNum = TextEditingController();

  TextEditingController txtPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: (){Navigator.pop(context);},
                      icon: Icon(Icons.arrow_back)),
                  Text('Back',style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'KhmerOSMoulLightRegular'),
                      textAlign: TextAlign.left,)
                ],
              ),
              SizedBox(height: 50),
              Text('ចុះឈ្មោះ',style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'KhmerOSMoulLightRegular'),
                textAlign: TextAlign.right,),
              SizedBox(height: 10),

              Text('Full Name',style: TextStyle(
                  fontSize: 22,
                  fontFamily: ''),textAlign: TextAlign.right),
              RoundTextField(controller: txtFname , hintText: 'Enter your Full Name', icon: Icons.email,isPassword: false,width: 400,height: 60,),
              SizedBox(height: 10),

              Text('Email',style: TextStyle(
                  fontSize: 22,
                  fontFamily: ''),textAlign: TextAlign.right),
              RoundTextField(controller: txtFname , hintText: 'your.email@example.com', icon: Icons.email,isPassword: false,width: 400,height: 60,),
              SizedBox(height: 10),

              Text('Phone Number',style: TextStyle(
                  fontSize: 22,
                  fontFamily: ''),textAlign: TextAlign.right),
              RoundTextField(controller: txtFname , hintText: '+855 XX XXX XXX', icon: Icons.email,isPassword: false,width: 400,height: 60,),
              SizedBox(height: 10),

              Text('Password',style: TextStyle(
                  fontSize: 22,
                  fontFamily: ''),textAlign: TextAlign.right),
              RoundTextField(controller: txtFname , hintText: '********', icon: Icons.lock,isPassword: true,width: 400,height: 60,),
              SizedBox(height: 10),

              Text('Password',style: TextStyle(
                  fontSize: 22,
                  fontFamily: ''),textAlign: TextAlign.right),
              RoundTextField(controller: txtFname , hintText: '********', icon: Icons.lock,isPassword: true,width: 400,height: 60,),
              SizedBox(height: 40),

              RoundButton(
                onPressed: (){Navigator.push(context,MaterialPageRoute(builder:(context)=>LoginScreen()),);},
                size:120,
                height: 60,
                width: 400,
                text: 'Create Account',
                textColor: Colors.white,
                fontSize: 20,
                backgroundColor: GColor.primarycolor,),

              SizedBox(height: 100),
              Text("By register, you agree to GINBEC's Term of service and Privacy Policy",style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'KhmerOSMoulLightRegular'),
                textAlign: TextAlign.right,),
            ],
          ),
        ),
      ),
    );
  }
}

