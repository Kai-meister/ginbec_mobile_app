import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/login_screen/login.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
                    IconButton(onPressed: (){Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=>LoginScreen()));},
                        icon: Icon(Icons.arrow_back)),
                    Text('Back',style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'KhmerOSMoulLightRegular'),
                      textAlign: TextAlign.right,)
                  ],
                ),
              ],
            ),
          ),
        )
      );

  }
}