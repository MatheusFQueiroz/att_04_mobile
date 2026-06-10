import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';

/// Gerencia o estado de autenticação do usuário em memória.
///
/// Singleton — acesse via [SessionController.instance].
/// Em testes, use [SessionController.testInstance()] para obter
/// instância isolada sem poluir o singleton.
class SessionController {
  SessionController._();

  static final SessionController instance = SessionController._();

  /// Cria instância isolada para uso em testes.
  @visibleForTesting
  static SessionController testInstance() => SessionController._();

  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  void login(User user) {
    _user = user;
  }

  void logout() {
    _user = null;
  }
}
