import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final session = await authRepository.restoreSession();
      if (session != null) {
        emit(Authenticated(session.user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final session = await authRepository.login(
        phoneNumber: event.phoneNumber,
        password: event.password,
      );
      emit(Authenticated(session.user));
    } on ApiException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.register(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        password: event.password,
        email: event.email,
        role: event.role,
        address: event.address,
        profilePicturePath: event.profilePicturePath,
      );
    } on ApiException catch (e) {
      emit(AuthFailure(_mapAuthErrorMessage(e.message), lastException: e));
      return;
    } catch (e) {
      emit(AuthFailure(e.toString()));
      return;
    }

    // Registration succeeded. Auto-login to obtain JWT tokens and establish session.
    try {
      final session = await authRepository.login(
        phoneNumber: event.phoneNumber,
        password: event.password,
      );
      emit(Authenticated(session.user));
    } catch (_) {
      // Auto-login failed after successful registration.
      // Do NOT retry registration. Show clear fallback guidance.
      emit(
        const AuthFailure(
          'खाता बन गया है, कृपया मोबाइल नंबर और पासवर्ड से लॉग इन करें',
        ),
      );
    }
  }

  String _mapAuthErrorMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('already exists')) {
      return 'इस मोबाइल नंबर या ईमेल से खाता पहले से मौजूद है';
    }
    if (lower.contains('required')) {
      return 'कृपया सभी आवश्यक फ़ील्ड भरें';
    }
    return message;
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.logout();
    } catch (_) {
      // Allow logout to proceed even on network failures
    }
    emit(const Unauthenticated());
  }
}
