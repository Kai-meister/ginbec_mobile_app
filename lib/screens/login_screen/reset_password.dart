import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/login_screen/otp_screen.dart';

import '../../Widgets/round_button.dart';
import '../../Widgets/round_text_field.dart';

class ResetPassword extends StatelessWidget {
  final TextEditingController txtEmail = TextEditingController();
  ResetPassword({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
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
            Text('អ៊ីមែល',style: TextStyle(
                fontSize: 22),textAlign: TextAlign.right),
            RoundTextField(controller: txtEmail , hintText: 'your.email@example.com', icon: Icons.email,isPassword: false,width: 400,height: 60,),
            SizedBox(height: 20),
            RoundButton(
              onPressed: (){Navigator.push(context,MaterialPageRoute(builder:(context)=>OtpScreen()),);},
              size:120,
              height: 60,
              width: 400,
              text: 'ផ្ញើលេខកូដ',
              textColor: Colors.white,
              fontSize: 20,
              backgroundColor: GColor.primarycolor,),
          ],
        ),
      ),
    );
  }
}
