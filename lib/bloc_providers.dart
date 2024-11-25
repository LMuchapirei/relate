import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/pages/welcome/bloc/welcome_bloc.dart';

class AppBlocProviders {
  static get allBlocProviders=>[
     BlocProvider(
            create: (context) => WelcomeBloc(),
          ),
  ];
}