import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common/widgets/signin_widgets.dart';
import '../bloc/signin_bloc.dart';
import '../bloc/signin_event.dart';
import '../bloc/signin_state.dart';
import '../signin_controller.dart';



class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);
  static const String routeName = "signIn";
  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInBloc, SignInState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          child: SafeArea(
            child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    buildThirdPartyLogin(context,{
                      SocialLogin.google:(){
                        SignInController(context: context).handleSignInWithGoogle();
                      },
                      SocialLogin.facebook:(){
                        
                      },
                      SocialLogin.apple:(){
                        
                      }
                    }),
                    Center(
                        child:
                            reusableText("Or use your email account login")),
                    Container(
                        margin: EdgeInsets.only(top: 36.h),
                        padding: EdgeInsets.only(left: 25.w, right: 25.w),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              reusableText("Email"),
                              SizedBox(height: 5.h),
                              buildTextField(
                                  "Enter your email address", "email", "user",(value){
                                    context.read<SignInBloc>().add(EmailEvent(value));
                                  }),
                              reusableText("Password"),
                              SizedBox(height: 5.h),
                              buildTextField(
                                  "Enter your password", "password", "lock",(value){
                                    context.read<SignInBloc>().add(PasswordEvent(value));
                                  }),
                              forgotPassword(),
                              buildLogInAndRegButton("Login", ButtonType.login,(){
                                SignInController(context: context).handleSignIn(SignInType.email);
                              }),
                              buildLogInAndRegButton(
                                  "Sign Up", ButtonType.register,(){
                              //  Navigator.of(context).pushNamed(Register.routeName);
                              })
                            ]))
                  ]),
                ),
                backgroundColor: Colors.white,
                appBar: buildAppBar()),
          ),
        );
      },
    );
  }
}