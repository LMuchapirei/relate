
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../values/colors.dart';

AppBar buildAppBar({String title = "Login"}) {
  return AppBar(
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              color: AppColors.primarySecondaryBackground, height: 1.0)),
      title: Text(title,
          style: TextStyle(fontSize: 16.sp, color: AppColors.primaryText)));
}


/// We need context for accessing the bloc
Widget buildThirdPartyLogin(BuildContext context,Map<SocialLogin,Function> signInFunctions) {
  return Container(
      margin: EdgeInsets.only(top: 40.h, bottom: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _socialLoginIcon("google",signInFunctions[SocialLogin.google]!),
          _socialLoginIcon("apple",signInFunctions[SocialLogin.apple]!),
          _socialLoginIcon("facebook",signInFunctions[SocialLogin.facebook]!)
        ],
      ));
}

Widget _socialLoginIcon(String iconName,Function signInHandler) {
  return GestureDetector(
      onTap: (){
        signInHandler();
      },
      child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Image.asset("assets/icons/$iconName.png")));
}

Widget reusableText(String text) {
  return Container(
      margin: EdgeInsets.only(bottom: 5.h),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
              color: Colors.grey.withOpacity(0.7))));
}

Widget buildTextField(String hintText, String textType, String iconName,void Function(String)? onChanged) {
  return Container(
      width: 325.w,
      height: 50.h,
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(15.w)),
          border: Border.all(color: AppColors.primaryFourthElementText)),
      child: Row(children: [
        Container(
            width: 16.w,
            height: 16.w,
            margin: EdgeInsets.only(left: 17.w),
            child: Image.asset("assets/icons/$iconName.png")),
        SizedBox(
            width: 270.w,
            height: 50.w,
            child: TextField(
                keyboardType: TextInputType.multiline,
                onChanged:onChanged,
                autocorrect: false,
                obscureText: textType.isPassword(),
                style: TextStyle(
                    color: AppColors.primaryText,
                    fontFamily: "Avenir",
                    fontWeight: FontWeight.normal,
                    fontSize: 12.sp),
                decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                        color: AppColors.primarySecondaryElementText),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    disabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent)))))
      ]));
}

Widget forgotPassword() {
  return Container(
    width: 260.w,
    height: 44.h,
    child: GestureDetector(
        onTap: () {},
        child: const Text("Forgot password",
            style: TextStyle(
                color: AppColors.primaryText,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primaryText))),
  );
}

Widget buildLogInAndRegButton(String buttonName, ButtonType buttonType,void Function()? func) {
  final colorCheck =  buttonType == ButtonType.login || buttonType == ButtonType.signup;
  return GestureDetector(
      onTap: () {
        func!();
      },
      child: Container(
          width: 325.w,
          height: 50.h,
          margin: EdgeInsets.only(
              top: buttonType == ButtonType.login ? 40.h : 20.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color:colorCheck
                  ? AppColors.primaryElement
                  : AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(15.w),
              border: Border.all(
                  color: colorCheck
                      ? Colors.transparent
                      : AppColors.primaryFourthElementText),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                  color: Colors.grey.withOpacity(0.1),
                )
              ]),
          child: Text(buttonName,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal,
                  color: colorCheck
                      ? AppColors.primaryBackground
                      : AppColors.primaryText))));
}

extension StrUtils on String {
  bool isPassword() {
    return this == "password";
  }
}

enum ButtonType { register, login, signup }

enum SocialLogin { google,apple,facebook}