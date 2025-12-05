import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _authRepository;

  StreamSubscription? _authStateSubscription;

  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
    this._authRepository,
  ) : super(const AuthState.initial()) {
    on<AuthEvent>(_onEvent);
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        add(const AuthEvent.checkAuthStatus());
      } else {
        emit(const AuthState.unauthenticated());
      }
    });
  }

  Future<void> _onEvent(AuthEvent event, Emitter<AuthState> emit) async {
    await event.when(
      checkAuthStatus: () => _checkAuthStatus(emit),
      loginWithEmail: (email, password) =>
          _loginWithEmail(email, password, emit),
      loginWithGoogle: () => _loginWithGoogle(emit),
      loginWithApple: () => _loginWithApple(emit),
      register: (email, password, fullName, phone) =>
          _register(email, password, fullName, phone, emit),
      forgotPassword: (email) => _forgotPassword(email, emit),
      verifyOtp: (email, otp) => _verifyOtp(email, otp, emit),
      resetPassword: (newPassword) => _resetPassword(newPassword, emit),
      updateProfile: (fullName, phone, avatarUrl) =>
          _updateProfile(fullName, phone, avatarUrl, emit),
      logout: () => _logout(emit),
    );
  }

  Future<void> _checkAuthStatus(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) => emit(const AuthState.unauthenticated()),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _loginWithEmail(
    String email,
    String password,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(AuthState.error(failure: failure)),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _loginWithGoogle(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) => emit(AuthState.error(failure: failure)),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _loginWithApple(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signInWithApple();

    result.fold(
      (failure) => emit(AuthState.error(failure: failure)),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _register(
    String email,
    String password,
    String fullName,
    String? phone,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    final result = await _registerUseCase(
      RegisterParams(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      ),
    );

    result.fold(
      (failure) => emit(AuthState.error(failure: failure)),
      (user) => emit(AuthState.authenticated(user: user)),
    );
  }

  Future<void> _forgotPassword(String email, Emitter<AuthState> emit) async {
    // Implementation would go here - simplified for now
    emit(AuthState.passwordResetSent(email: email));
  }

  Future<void> _verifyOtp(String email, String otp, Emitter<AuthState> emit) async {
    // Implementation would go here
    emit(const AuthState.otpVerified());
  }

  Future<void> _resetPassword(String newPassword, Emitter<AuthState> emit) async {
    // Implementation would go here
    emit(const AuthState.passwordResetSuccess());
  }

  Future<void> _updateProfile(String? fullName, String? phone, String? avatarUrl, Emitter<AuthState> emit) async {
     // Implementation would go here
  }

  Future<void> _logout(Emitter<AuthState> emit) async {
    emit(const AuthState.loading());

    final result = await _logoutUseCase();

    result.fold(
      (failure) => emit(AuthState.error(failure: failure)),
      (_) => emit(const AuthState.unauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
