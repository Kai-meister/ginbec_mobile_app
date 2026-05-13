import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/widgets/avatar.dart';
import 'package:ginbec_mobile_app/widgets/dashcard.dart';
import 'package:ginbec_mobile_app/widgets/event_card.dart';
import 'package:ginbec_mobile_app/widgets/hoverabletext.dart';
import 'package:ginbec_mobile_app/widgets/recent_notifications.dart';
import 'package:ginbec_mobile_app/widgets/transp_button.dart';

import '../../widgets/action_button.dart';

class Home extends StatelessWidget {

  const Home({super.key});

  @override
  Widget build(BuildContext context) {

    final exampleNotifications = [
      NotificationModel(
        id: '1',
        title: 'Meeting Reminder',
        subtitle: 'Meditation Hall A booking starts in 30 minutes',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        type: 'meeting',
      ),
      NotificationModel(
        id: '2',
        title: 'Booking Confirmed',
        subtitle: 'Your Conference Room 1 booking has been confirmed',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        type: 'booking',
      ),
      NotificationModel(
        id: '3',
        title: 'New Document Shared',
        subtitle: 'Buddhist Education Guidelines 2026 has been shared with you',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        type: 'document',
      ),
    ];

    return Scaffold(
        backgroundColor: GColor.backgroundcolor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  GestureDetector( //First row
                    onTap: (){debugPrint('go to profile');},
                    child: Row(
                      children: [
                        AvatarWidget(imageUrl: 'lib/assets/user_icon.png', size: 50),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back',textAlign: TextAlign.left,style: TextStyle(fontSize: 15),),
                            Text('Phireak',textAlign: TextAlign.left,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Expanded(child: SizedBox()),
                        IconButton(onPressed: (){debugPrint('setting icon');}, icon: Icon(Icons.settings)),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row( // second row
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DashCard(number: '122', label: 'Total \nMeetings'),
                      DashCard(number: '5', label: 'Upcoming'),
                      DashCard(number: '3', label: 'Unread'),
                    ],
                  ),
                  SizedBox(height: 20),
                  //3rd row`
                  Text('Quick Actions',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),textAlign: TextAlign.start,),
                  SizedBox(height: 20),
                  Row(//4th row
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ActionButton(icon: Icons.calendar_month, onTap: (){debugPrint('Book room');}, label: 'Book Room',bttBg: Colors.blueAccent),
                      ActionButton(icon: Icons.two_k, onTap: (){debugPrint('Documents');}, label: 'Documents',bttBg: Colors.green),
                      ActionButton(icon: Icons.group, onTap: (){debugPrint('Schedule');}, label: 'Schedule',bttBg: Colors.purple),
                      ActionButton(icon: Icons.settings, onTap: (){debugPrint('setting');}, label: 'setting',bttBg: GColor.primarycolor),
                    ],
                  ),
                Row(//5th row
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Upcoming Meetings',style: TextStyle(fontSize: 20),),

                  ],
                ),
                  //6th-7th Row
                  SizedBox(height: 20,),
                  EventCard(tittle: 'Q3 Meeting with Director', attendee: 23, datetime: DateTime(2026, 10, 20, 15, 35)),
                  SizedBox(height: 20,),
                  EventCard(tittle: 'Declaration Tax final day', attendee: 12, datetime: DateTime(2026, 5, 16, 8, 30)),

                  //8th row
                  SizedBox(height: 20,),
                  // RoundButton(onPressed: (){debugPrint('book new meeting');},
                  //   size:120,
                  //   height: 60,
                  //   width: 400,
                  //   backgroundColor: Colors.transparent,
                  //   text: 'Book New Meeting',
                  //   fontSize: 20,
                  //   icon: Icons.calendar_month,
                  // ),
                  TranspButton(icon: Icons.calendar_month, txt: 'Book New Meeting', onPressed: (){debugPrint('Book New Meeting');}),
                  SizedBox(height: 20,),
                  Row(//9th row
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Notifications',style: TextStyle(fontSize: 20),),
                      Hoverabletext(text: 'View All', onTap: (){debugPrint('View all meetings');}),
                    ],
                  ),


                  //10th Row
                  NotificationCard(
                    notifications: exampleNotifications,
                    onTap: (notification) {
                      debugPrint('Tapped: ${notification.title}');
                    },
                  ),
                  //11th row
                  SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.orangeAccent,Colors.deepOrange],begin: Alignment.topRight,end: Alignment.bottomLeft),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(
                        blurRadius: 8,
                        offset: Offset(0, 2),
                        color: Colors.grey.shade300,
                      )]
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's Schedule",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                          SizedBox(height: 10,),
                          Row(
                            children: [
                              Text("Morning Session",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                              Expanded(child: SizedBox()),
                              Text("09:00 - 11:00 AM",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                            ]
                          ),
                          Row(
                              children: [
                                Text("Free Time",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                                Expanded(child: SizedBox()),
                                Text("11:00 - 02:00 AM",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.white),),
                              ]
                          ),
                          Row(
                              children: [
                                Text("No Session",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.grey),),
                                Expanded(child: SizedBox()),
                                Text("-",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: Colors.grey),),
                              ]
                          )
                        ]
                      ),
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  }
}