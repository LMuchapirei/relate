class SignInState {
  final String email;
  final String password;

  const SignInState({required this.email, required this.password});

  SignInState copyWith({String? email, String? password}) {
    return SignInState(
        email: email ?? this.email, password: password ?? this.password);
  }

  @override
  String toString() {
    // TODO: implement toString
    return {
      "email":email,
      "password":password
    }.toString();
  }
}
