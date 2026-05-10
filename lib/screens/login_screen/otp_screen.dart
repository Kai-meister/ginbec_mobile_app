import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:pinput/pinput.dart';

import '../../Widgets/round_button.dart';
import 'login.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PinTheme defaultTheme = PinTheme(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: Colors.white,
      ),
          height: 88,
      width: 72,
      textStyle: const TextStyle(
        fontSize: 24,
        //fontWeight: 600,

      ),
    );
    return Scaffold(
      backgroundColor: GColor.backgroundcolor,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please Enter Verification code',style: TextStyle(fontSize: 25),),
            SizedBox(height: 40),
            Pinput(
              defaultPinTheme: defaultTheme,
              focusedPinTheme: defaultTheme.copyBorderWith(
                border: Border.all(color: Colors.purple, width: 2)
              ),
              errorPinTheme: defaultTheme.copyBorderWith(border: Border.all(color: Colors.red, width: 2)),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              validator: (v) => v == '2222' ? null : 'Incorrect Pin',
              ),
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
          ],
        ),
      ),
    );
  }
}
