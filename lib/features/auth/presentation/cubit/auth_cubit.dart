import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final Login _login;
  final GetCurrentUser _getCurrentUser;
  final Logout _logout;

  AuthCubit({
    required Login login,
    required GetCurrentUser getCurrentUser,
    required Logout logout,
  })  : _login = login,
        _getCurrentUser = getCurrentUser,
        _logout = logout,
        super(const AuthInitial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (failure) => emit(const Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> login(String username, String password) async {
    emit(const AuthLoading());
    final result = await _login(LoginParams(username: username, password: password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> logout() async {
    await _logout(const NoParams());
    emit(const Unauthenticated());
  }
}
