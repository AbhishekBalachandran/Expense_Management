part of 'auth_bloc.dart';

abstract class AuthEvent {}

class SendOtpEvent extends AuthEvent {
  SendOtpEvent({required this.phone});
  final String phone;
}

class VerifyOtpEvent extends AuthEvent {
  VerifyOtpEvent({required this.otp});
  final String otp;
}

class ResendOtpEvent extends AuthEvent {}

class OtpTimerEvent extends AuthEvent {
  OtpTimerEvent({required this.secondsRemaining});
  final double secondsRemaining;
}

class SaveName extends AuthEvent {
  SaveName({required this.nickname});
  final String nickname;
}
