import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/pages/welcome/bloc/welcome_event.dart';
import 'package:relate/pages/welcome/bloc/welcome_state.dart';

class WelcomeBloc extends Bloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(WelcomeState(page: 0)) {
    on<WelcomeEvent>((event, emit) {
      emit(WelcomeState(page: state.page));
    });
  }
}