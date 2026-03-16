part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String phone;
  final double secondsRemaining;
  OtpSentState({required this.phone, required this.secondsRemaining});
}

class OtpTimerState extends AuthState {
  final String phone;
  final double secondsRemaining;
  OtpTimerState({required this.phone, required this.secondsRemaining});
}

class AuthenticatedState extends AuthState {
  final String name;

  AuthenticatedState({required this.name});
}

class NewUserState extends AuthState {
  NewUserState({required this.phone});
  final String phone;
}

class NameSavedState extends AuthState {
  NameSavedState({required this.nickname});
  final String nickname;
}

class AuthErrorState extends AuthState {
  AuthErrorState({required this.message});
  final String message;
}
