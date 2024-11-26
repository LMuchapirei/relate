import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/widgets/signin_widgets.dart';
import '../register_bloc.dart';
import '../register_controller.dart';
import '../register_event.dart';
import '../register_state.dart';


class Register extends StatefulWidget {
  static const routeName = "register";
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
      return BlocBuilder<RegisterBlocs, RegisterStates>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(children: [
                    Center(
                        child:
                            reusableText("Enter your details below & free sign up")),
                    Container(
                        margin: EdgeInsets.only(top: 36.h),
                        padding: EdgeInsets.only(left: 25.w, right: 25.w),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              reusableText("User name"),
                              buildTextField(
                                  "Enter your user name", "username", "user",
                                  (value){
                                     context.read<RegisterBlocs>().add(UserNameEvent(value));
                                  }),
                              reusableText("Email"),
                              buildTextField(
                                  "Enter your email address", "email", "user",(value){
                                     context.read<RegisterBlocs>().add(EmailRegisterEvent(value));
                                  }),
                              reusableText("Password"),
                              buildTextField(
                                  "Enter your password", "password", "lock",(value){
                                    context.read<RegisterBlocs>().add(PasswordEvent(value));
                                  }),
                              reusableText("Confirm Password"),
                              buildTextField(
                                  "Confirm your password", "password", "lock",(value){
                                     context.read<RegisterBlocs>().add(ConfirmPasswordEvent(value));
                                  }),
                               reusableText("By creating an account you have to agree with our terms and conditions"),
 
                              buildLogInAndRegButton("Sign Up", ButtonType.signup,(){
                                RegisterController(context).handleEmailRegister();
                              }),
                            ]))
                  ]),
                ),
                backgroundColor: Colors.white,
                appBar: buildAppBar(title: "Sign Up")),
          ),
        );
      },
    );
  }
}
