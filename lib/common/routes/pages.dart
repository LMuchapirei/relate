import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/application/application_page.dart';
import '../../features/application/bloc/app_bloc.dart';
import '../../features/auth/bloc/signin_bloc.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/register/register_bloc.dart';
import '../../features/register/screens/register.dart';
import '../../pages/welcome/bloc/welcome_bloc.dart';
import '../../pages/welcome/welcome.dart';
import 'names.dart';


class AppPages {
  static List<PageEntity> routes = [
    PageEntity(
      route: AppRoutes.INITIAL, 
      page: const Welcome(), 
      bloc: BlocProvider(create: (_)=> WelcomeBloc())),
     PageEntity(
      route: AppRoutes.SIGN_IN, 
      page: const SignIn(), 
      bloc: BlocProvider(create: (_)=> SignInBloc())),
    PageEntity(
      route: AppRoutes.REGISTER, 
      page: const Register(), 
      bloc: BlocProvider(create: (_)=> RegisterBlocs())),
    PageEntity(
      route: AppRoutes.APPLICATION, 
      page: const ApplicationPage(), 
      bloc:BlocProvider(create: (_)=> AppBloc(),)
     )
  ];

  static List<dynamic> allProviders(BuildContext context){
  List<dynamic> blocProviders = [];
  for(var bloc in routes){
    blocProviders.add(bloc.bloc!);
  }
  return blocProviders;
}

// a modal that covers entire screen as we click on navigator object
   static MaterialPageRoute generateRouteSettings(RouteSettings settings){
  if(settings.name != null){
    // check for route name matching when navigator gets triggered.
    var result = routes.where((element) => element.route == settings.name);
    if(result.isNotEmpty){
      return MaterialPageRoute(builder: (_)=>result.first.page);
    }
  }
  return MaterialPageRoute(builder: (_) => const SignIn(),settings: settings);
}
}
class PageEntity {
  String route;
  Widget page;
  dynamic bloc;

  PageEntity({
    required this.route,
    required this.page,
     this.bloc
  });


}