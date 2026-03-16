import 'dart:async';

import 'package:expense_manager/core/storage/prefs_service.dart';
import 'package:expense_manager/data/remote/auth_remote_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteSource _authRemoteSource;
  final PrefsService _prefsService;
  AuthBloc({
    required AuthRemoteSource authRemoteSource,
    required PrefsService prefsService,
  }) : _authRemoteSource = authRemoteSource,
       _prefsService = prefsService,
       super(AuthInitial()) {
    on<SendOtpEvent>(onOtpSend);
    on<VerifyOtpEvent>(onVerifyOtp);
    on<ResendOtpEvent>(onResendOtp);
    on<OtpTimerEvent>(onTimerChange);
    on<SaveName>(onSaveNickname);
  }

  Timer? _resendTimer;
  static const double _resendDuration = 60;

  String _phone = '';
  String _receivedOtp = '';
  bool _userExists = false;
  String _token = '';

  Future<void> onOtpSend(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRemoteSource.sendOtp(phone: event.phone);
      _phone = event.phone;
      _receivedOtp = response['otp']?.toString() ?? '';
      _userExists = response['user_exists'] == true;
      _token = response['token']?.toString() ?? '';
      // if user exists
      if (_userExists) {
        final nickname = response['nickname']?.toString() ?? '';
        await _prefsService.saveToken(_token);
        await _prefsService.saveName(nickname);
        emit(AuthenticatedState(name: nickname));
        return;
      }

      // if new user
      // starting timer
      startResendTimer();
      emit(OtpSentState(phone: _phone, secondsRemaining: _resendDuration));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  // start otp resend timer
  void startResendTimer() {
    cancelResendTimer();
    double seconds = _resendDuration;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      seconds--;
      add(OtpTimerEvent(secondsRemaining: seconds));
      if (seconds <= 0) cancelResendTimer();
    });
  }

  //verify otp
  Future<void> onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (event.otp != _receivedOtp) {
        emit(AuthErrorState(message: 'Invalid OTP. Please try again.'));
        return;
      }

      cancelResendTimer();

      if (_userExists) {
        await _prefsService.saveToken(_token);
        emit(AuthenticatedState(name: ''));
      } else {
        emit(NewUserState(phone: _phone));
      }
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  // resend otp
  Future<void> onResendOtp(
    ResendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRemoteSource.sendOtp(phone: _phone);
      _receivedOtp = response['otp']?.toString() ?? '';

      cancelResendTimer();
      startResendTimer();

      emit(OtpSentState(phone: _phone, secondsRemaining: _resendDuration));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  void onTimerChange(OtpTimerEvent event, Emitter<AuthState> emit) {
    emit(
      OtpTimerState(phone: _phone, secondsRemaining: event.secondsRemaining),
    );
  }

  // save nickname //locally // remote
  Future<void> onSaveNickname(SaveName event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _authRemoteSource.createAccount(
        phone: _phone,
        nickname: event.nickname,
      );

      final token = response['token']?.toString();
      await _prefsService.saveToken(token ?? '');
      await _prefsService.saveName(event.nickname);

      emit(NameSavedState(nickname: event.nickname));
    } catch (e) {
      emit(AuthErrorState(message: e.toString()));
    }
  }

  //
  void cancelResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }
}
