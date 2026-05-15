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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: (){Navigator.pop(context);},
                          icon: Icon(Icons.arrow_back)),
                      Text('ត្រឡប់',style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'KhmerOSMoulLightRegular'),
                          textAlign: TextAlign.left,)
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('ចុះឈ្មោះ',style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'KhmerOSMoulLightRegular'),
                        textAlign: TextAlign.right,),
                    ],
                  ),
                  SizedBox(height: 10),


                      Text('ឈ្មោះពេញ',style: TextStyle(
                          fontSize: 22),textAlign: TextAlign.right),


                  RoundTextField(controller: txtFname , hintText: 'បញ្ចូលឈ្មោះពេញរបស់អ្នក', icon: Icons.email,isPassword: false,width: 400,height: 60,),
                  SizedBox(height: 10),

                  Text('អ៊ីមែល',style: TextStyle(
                      fontSize: 22),textAlign: TextAlign.right),
                  RoundTextField(controller: txtFname , hintText: 'your.email@example.com', icon: Icons.email,isPassword: false,width: 400,height: 60,),
                  SizedBox(height: 10),

                  Text('លេខទូរស័ព្ទ',style: TextStyle(
                      fontSize: 22),textAlign: TextAlign.right),
                  RoundTextField(controller: txtFname , hintText: '+855 XX XXX XXX', icon: Icons.email,isPassword: false,width: 400,height: 60,),
                  SizedBox(height: 10),

                  Text('ពាក្យសម្ងាត់',style: TextStyle(
                      fontSize: 22),textAlign: TextAlign.right),
                  RoundTextField(controller: txtFname , hintText: '********', icon: Icons.lock,isPassword: true,width: 400,height: 60,),
                  SizedBox(height: 10),

                  Text('បញ្ជាក់ពាក្យសម្ងាត់',style: TextStyle(
                      fontSize: 22),textAlign: TextAlign.right),
                  RoundTextField(controller: txtFname , hintText: '********', icon: Icons.lock,isPassword: true,width: 400,height: 60,),
                  SizedBox(height: 40),

                  RoundButton(
                    onPressed: (){Navigator.push(context,MaterialPageRoute(builder:(context)=>LoginScreen()),);},
                    size:120,
                    height: 60,
                    width: 400,
                    text: 'បង្កើតគណនី',
                    textColor: Colors.white,
                    fontSize: 20,
                    backgroundColor: GColor.primarycolor,),

                  SizedBox(height: 100),
                  Text('ដោយចុះឈ្មោះ អ្នកយល់ព្រមតាមលក្ខខណ្ឌប្រើប្រាស់ និងគោលការណ៍ឯកជនភាពរបស់ GINBEC',style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'KhmerOSMoulLightRegular'),
                    textAlign: TextAlign.right,),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

