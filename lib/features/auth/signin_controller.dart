import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../common/widgets/flutter_toast.dart';
import 'bloc/signin_bloc.dart';

class SignInController {
  final BuildContext context;
  SignInController({required this.context});

  void handleSignIn(SignInType type) async {
    try {
      if (type == SignInType.email) {
        final state = context.read<SignInBloc>().state;
        final emailAddress = state.email;
        final password = state.password;
        if (emailAddress.isEmpty) {
          toastInfo(msg: "Please enter your email address");
          return;
        }
        if (password.isEmpty) {
             toastInfo(msg: "Please enter your password");
          return;
        }
        try {
          final credential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: emailAddress, password: password);
          if (credential.user == null) {
             toastInfo(msg: "User doesn't exist.");

          }
          if (!credential.user!.emailVerified) {
             toastInfo(msg: "You need to verify your email address.");
          }
          var user = credential.user;
          if (user != null) {
          } else {
             toastInfo(msg: "Currently you are not a user of this app");
          }
        } on FirebaseAuthException catch (e) {
             toastInfo(msg: "Error : ${e.code}");
        }
      }
    // ignore: empty_catches
    } catch (e) {

    }
  }

  void handleSignInWithGoogle() async{
   final user =  await signInWithGoogle();
   print(user);
  }

//   Future<User?> signInWithGoogle() async {
//   // Initialize the GoogleSignIn instance
//   final GoogleSignIn googleSignIn = GoogleSignIn();
//   // Attempt to get the currently authenticated user
//   final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//   if (googleUser == null) {
//     // If user cancels the sign-in
//     return null;
//   }
//   // Obtain the Google user's authentication details
//   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//   // Create a new credential using the GoogleAuthProvider
//   final AuthCredential credential = GoogleAuthProvider.credential(
//     accessToken: googleAuth.accessToken,
//     idToken: googleAuth.idToken,
//   );
//   // Sign in to Firebase with the generated credential
//   UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//   return userCredential.user;
// }
Future<User?> signInWithGoogle() async {
  try {
    // Initialize the GoogleSignIn instance
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Attempt to get the currently authenticated user
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      // If user cancels the sign-in
      print('Sign-in canceled by user');
      return null;
    }

    // Obtain the Google user's authentication details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential using the GoogleAuthProvider
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the generated credential
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    return userCredential.user;

  } on FirebaseAuthException catch (e) {
    // Handle Firebase-specific errors
    print('FirebaseAuthException: ${e.message}');
    // You can show an alert or toast here if needed
    return null;

  } on GoogleSignInAccount catch (e) {
    // Handle GoogleSignIn-specific errors
    print('GoogleSignInAccount: ${e}');
    return null;
  
  } catch (e) {
    // Handle any other type of error
    print('Unknown error occurred: $e');
    return null;
  }
}
}

enum SignInType { email, social }
