import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mock/mock_data.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const Authenticated(MockData.defaultAdmin)); // default logged-in for smooth desktop demo

  void checkAuth() {
    // Already authenticated initially or can switch
  }

  Future<void> login(String username, String password) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    if (username.trim().toLowerCase() == 'admin' && password == 'admin123') {
      emit(const Authenticated(MockData.defaultAdmin));
    } else if (username.trim().isNotEmpty && password.isNotEmpty) {
      // Demo ease: allow custom login as well
      emit(Authenticated(MockData.defaultAdmin));
    } else {
      emit(const AuthError('Invalid username or password. Use admin / admin123'));
    }
  }

  void logout() {
    emit(const Unauthenticated());
  }
}
