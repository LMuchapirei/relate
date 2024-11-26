import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/features/register/register_bloc.dart';

import '../../common/widgets/flutter_toast.dart';

class RegisterController {
  final BuildContext context;

  const RegisterController(this.context);


  void handleEmailRegister() async {
    final state = context.read<RegisterBlocs>().state;
    String userName = state.userName;
    String email = state.email;
    String password = state.password;
    String rePassword = state.rePassword;
    //// Extract this validation somewhere else also
    if(userName.isEmpty){
      toastInfo(msg: "User name cannot be empty");
      return;
    }

    if(email.isEmpty){
      toastInfo(msg: "Email cannot be empty");
       return;
    }

    if(password.isEmpty){
      toastInfo(msg: "Password cannot be empty");
       return;
    }

    if(rePassword.isEmpty){
      toastInfo(msg: "Confirm password cannot be empty");
       return;
    }

    if(rePassword != password){
      toastInfo(msg: "Password did not match confirmation password");
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if(credential.user != null){
        await credential.user?.sendEmailVerification();
        await credential.user?.updateDisplayName(userName);
         toastInfo(msg: 'Email sent to the register email.To activate account check your email and click on the verification link');
         Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch(e){
      if(e.code == 'weak-password'){
         toastInfo(msg: 'The password provided is too weak');
      } else if(e.code == 'email-already-in-use'){
        toastInfo(msg: 'The email provided is already in use');
      } else if(e.code == "invalid-email"){
        toastInfo(msg: 'The email provided is invalid');
      } else {
        toastInfo(msg: 'Error - $e');
      }
    }
  } 
}