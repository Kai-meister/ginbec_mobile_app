import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ginbec_mobile_app/config/color.dart';

class EventCard extends StatelessWidget {
  final String tittle;
  final DateTime datetime;
  final int attendee;

  const EventCard({
    super.key,
    required this.tittle,
    required this.attendee,
    required this.datetime,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){print('tap meeting now');},
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: Offset(0, 2),
          )]
        ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(tittle,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    Expanded(child: SizedBox()),
                    Text(DateFormat(' hh:mm a',).format(datetime),style: TextStyle(color: GColor.primarycolor,fontSize: 18,fontWeight: FontWeight.bold),)]
                ),
                Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.grey,size: 20,),
                      //add date here
                      Text(DateFormat(' dd/MM/yyyy ',).format(datetime),style: TextStyle(color: Colors.grey,fontSize: 18),),

                      Icon(Icons.group, color: Colors.grey,size: 20,),
                      //add attendee here
                     Text('  $attendee',style: TextStyle(color: Colors.grey,fontSize: 18),)
                      ]
                ),
              ],
            ),
          ),
      ),
    );
  }
}
