import 'package:flutter/foundation.dart';
import '../../core/session/session_controller.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/user.dart';
import 'auth_state.dart';

/// ViewModel responsável pelo fluxo de autenticação.
class AuthViewModel {
  final AuthRemoteDatasource _datasource;
  final SessionController _sessionController;

  final ValueNotifier<AuthState> state = ValueNotifier(const AuthState());

  AuthViewModel(this._datasource, this._sessionController);

  /// Realiza login via DummyJSON e armazena o usuário na sessão.
  ///
  /// Retorna [true] em caso de sucesso, [false] em caso de falha.
  Future<bool> login(String username, String password) async {
    state.value = state.value.copyWith(isLoading: true, error: null);

    try {
      final userModel = await _datasource.login(username, password);
      _sessionController.login(User(
        id: userModel.id,
        username: userModel.username,
        firstName: userModel.firstName,
        lastName: userModel.lastName,
        image: userModel.image,
        accessToken: userModel.accessToken,
      ));
      state.value = state.value.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(
        isLoading: false,
        error: 'Usuário ou senha inválidos',
      );
      return false;
    }
  }

  /// Realiza logout limpando a sessão.
  void logout() {
    _sessionController.logout();
  }
}
