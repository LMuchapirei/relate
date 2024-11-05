import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relate/pages/dashboard.dart';
import 'package:relate/pages/relationship_screen.dart';
import 'package:relate/pages/relationships.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context,child) {
        return MaterialApp(
          title: 'Relate',
           theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
                textTheme: GoogleFonts.jostTextTheme()),
          debugShowCheckedModeBanner: false,
          // home:  Dashboard(),
          home: RelationshipsScreen(),
        );
      }
    );
  }
}
