import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

ElevatedButton buildFormOptionsButton(String title,{required VoidCallback onTap,bool primary = true}) {
    return ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary ? Colors.black : Colors.grey,
                  fixedSize: Size(100.w, 30.h)
                ),
                child: Text('$title',style: TextStyle(
                  color: primary ? Colors.white : Colors.black
                ),),
              );
  }