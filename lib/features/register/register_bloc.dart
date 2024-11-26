import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:relate/features/register/register_event.dart';
import 'package:relate/features/register/register_state.dart';

class RegisterBlocs extends Bloc<RegisterEvent,RegisterStates> {
   RegisterBlocs(): super(const RegisterStates()){
    on<UserNameEvent>(_userNameEventHandler);
    on<PasswordEvent>(_passwordEventHandler);
    on<ConfirmPasswordEvent>(_confirmPasswordEventHandler);
    on<EmailRegisterEvent>(_emailEventHandler);
  }

  void _userNameEventHandler(UserNameEvent event,Emitter<RegisterStates> emit){
    emit(state.copyWith(
      userName: event.userName
    ));
  }

  void _passwordEventHandler(PasswordEvent event,Emitter<RegisterStates> emit){
    emit(state.copyWith(
      password : event.password
    ));
  }

  void _confirmPasswordEventHandler(ConfirmPasswordEvent event,Emitter<RegisterStates> emit){
    emit(state.copyWith(
      rePassword: event.confirmPassword
    ));
  }

  void _emailEventHandler(EmailRegisterEvent event,Emitter<RegisterStates> emit){
    emit(state.copyWith(
      email: event.email
    ));
  }

}