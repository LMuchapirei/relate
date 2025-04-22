import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_states.dart';
import 'app_events.dart';

class AppBloc extends Bloc<AppEvent,AppState> {
   AppBloc(): super(const AppState()){
    on<TriggerAppEvent>(_handleAppEventHandler);
  }

  void _handleAppEventHandler(TriggerAppEvent event, Emitter<AppState> emit){
    emit(AppState(
      index: event.index
    ));
  }
}