import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relate/common/routes/pages.dart';
import 'package:relate/pages/dashboard.dart';
import 'package:relate/pages/relationship_screen.dart';
import 'package:relate/pages/relationships.dart';
import 'package:relate/pages/welcome/welcome.dart';

import 'bloc_providers.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/register/screens/register.dart';
import 'global.dart';

void main() async { 
  await Global.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [...AppPages.allProviders(context),...AppPages.otherProviders(context)],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Relate',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              textTheme: GoogleFonts.jostTextTheme()),
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppPages.generateRouteSettings,
          );
        },
      ),
    );
  }
}
