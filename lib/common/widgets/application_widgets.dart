import 'package:flutter/material.dart';

Widget buildPage(int index){
  List<Widget> _widget = const [
    Center(
      child: Text('Home'),
    ),
    Center(
      child: Text('Search'),
    ),
    Center(
      child: Text('Schedule'),
    ),
    Center(
      child: Text('Chat'),
    ),
    Center(
      child: Text('Profile'),
    )
  ];
  return _widget[index];
}

class BarItemData {
  final String icon;
  final String label;

  const BarItemData({required this.icon,required this.label});
}

List<BarItemData> barItems = const [
   BarItemData(icon: "assets/icons/home.png", label: "Home"),
   BarItemData(icon: "assets/icons/search2.png", label: "Search"),
   BarItemData(icon: "assets/icons/play-circle1.png", label: "Schedule"),
   BarItemData(icon: "assets/icons/message-circle.png", label: "Chat"),
   BarItemData(icon: "assets/icons/person2.png", label: "Profile")
];