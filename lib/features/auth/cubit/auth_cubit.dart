import 'package:bloc/bloc.dart';
import 'package:kasway/data/repositories/auth_repository.dart';
import 'package:kasway/features/auth/cubit/auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    _init();
  }

  final AuthRepository _authRepository;

  void _init() {
    if (_authRepository.isSignedIn) {
      emit(AuthState(status: _resolveAuthStatus()));
    } else {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }

    _authRepository.authStateChanges.listen((event) {
      switch (event.event) {
        case sb.AuthChangeEvent.signedIn:
        case sb.AuthChangeEvent.tokenRefreshed:
        case sb.AuthChangeEvent.userUpdated:
          emit(state.copyWith(status: _resolveAuthStatus()));
        case sb.AuthChangeEvent.signedOut:
          emit(const AuthState(status: AuthStatus.unauthenticated));
        default:
          break;
      }
    });
  }

  /// Determines whether the user still needs to link Google or is fully authenticated.
  AuthStatus _resolveAuthStatus() {
    return _authRepository.hasGoogleLinked
        ? AuthStatus.authenticated
        : AuthStatus.needsGoogleLink;
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.signInWithGoogle();
      // Status is updated by authStateChanges listener on OAuth callback
    } on sb.AuthException catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'An unexpected error occurred.',
      ));
    }
  }

  Future<void> linkGoogle() async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.linkGoogle();
      // Status updated by authStateChanges listener (userUpdated event) after linking
    } on sb.AuthException catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'An unexpected error occurred.',
      ));
    }
  }

  Future<void> sendOtp(String email) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.sendOtp(email);
      emit(state.copyWith(status: AuthStatus.otpSent));
    } on sb.AuthException catch (e) {
      emit(AuthState(status: AuthStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Failed to send code. Please try again.',
      ));
    }
  }

  Future<void> verifyOtp(String email, String token) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _authRepository.verifyOtp(email, token);
      // Auth state change listener handles the transition to needsGoogleLink/authenticated
    } on sb.AuthException catch (e) {
      // Return to otpSent so the user can retry
      emit(AuthState(status: AuthStatus.otpSent, errorMessage: e.message));
    } catch (_) {
      emit(const AuthState(
        status: AuthStatus.otpSent,
        errorMessage: 'Invalid code. Please try again.',
      ));
    }
  }

  void resetToUnauthenticated() {
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }
}
