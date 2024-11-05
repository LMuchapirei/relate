import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void displayBottomModalSheet(BuildContext context,Widget sheetBody,{isScroll = true}){
      showModalBottomSheet(
        context: context, 
        showDragHandle: true,
        isDismissible: false,
        isScrollControlled: isScroll,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.h),
           
          )
        ),
        builder: (context){
          return sheetBody;
        });
}


void displayBottomModalSheetLarge(BuildContext context,Widget sheetBody,{isScroll = true}){
      showModalBottomSheet(
        context: context, 
        showDragHandle: false,
        isDismissible: false,
        isScrollControlled: isScroll,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(10.h),
          )
        ),
        builder: (context){
          return sheetBody;
        });
}