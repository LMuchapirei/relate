// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../common/values/colors.dart';
import '../common/widgets/modals.dart';
import '../common/widgets/relationship_form.dart';



class Dashboard extends StatelessWidget {
  static const routeName = '/dashboard';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Light background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
                Center(
                  child: Text(
                    'Linear',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            Text(
              'This is where you see your curated list of current relationships you are managing',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textColor1,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                // Handle add relationship action
                displayBottomModalSheet(context,Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: AddRelationshipScreen())
                );
              },
              child: Container(
                width: 240.h,
                height: 240.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // border: Border.all(
                  //   color: Colors.blueGrey[900]!,
                  //   width: 8.0,
                  // ),
                ),
                child: Center(
                  child:Image.asset(
                "assets/images/add_circle.png",
              ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No Relationships',
              style: TextStyle(
                color: AppColors.textColor2,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
             Spacer(),
          ],
        ),
      ),
    );
  }
}
