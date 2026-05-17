import 'package:flutter/material.dart';
import 'package:ginbec_mobile_app/config/color.dart';
import 'package:ginbec_mobile_app/screens/alert_screen/alert.dart';
import 'package:ginbec_mobile_app/screens/document_screen/document_screen.dart';
import 'package:ginbec_mobile_app/screens/setting_screen/setting.dart';
import 'package:ginbec_mobile_app/widgets/tabbutton.dart';

import 'home_screen/home.dart';
import 'meeting_screen/meetingscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _page = [
    Home(onNavigateToTab: _onTabSelected),
    MeetingScreen(),
    DocumentScreen(),
    AlertScreen(),
    SettingScreen(),
  ];


  void _onTabSelected(int index){
    setState(()=> _selectedIndex =index);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _page[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade300,width: 1),),
        ),
        child: BottomAppBar(
          color: GColor.white,
          padding: EdgeInsets.zero,
          child: SafeArea(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                  tittle: 'ទំព័រដើម',
                  icon: Icons.home,
                  isSelected: _selectedIndex == 0,
                  onTap: () => _onTabSelected(0)),
              TabButton(
                  tittle: 'កិច្ចប្រជុំ',
                  icon: Icons.group,
                  isSelected: _selectedIndex == 1,
                  onTap: () => _onTabSelected(1)),
              TabButton(
                  tittle: 'ឯកសារ',
                  icon: Icons.description,
                  isSelected: _selectedIndex == 2,
                  onTap: () => _onTabSelected(2)),
              TabButton(
                  tittle: 'ការជូនដំណឹង',
                  icon: Icons.notifications,
                  isSelected: _selectedIndex == 3,
                  onTap: () => _onTabSelected(3)),
              TabButton(
                  tittle: 'ការកំណត់',
                  icon: Icons.settings,
                  isSelected: _selectedIndex == 4,
                  onTap: () => _onTabSelected(4)),
            ],
          )),
        ),
      ),
    );
  }
}
