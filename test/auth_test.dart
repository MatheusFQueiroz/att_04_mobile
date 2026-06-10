import 'package:flutter_test/flutter_test.dart';
import 'package:att_04_mobile_02/domain/entities/user.dart';
import 'package:att_04_mobile_02/data/models/user_model.dart';
import 'package:att_04_mobile_02/core/session/session_controller.dart';

void main() {
  group('UserModel.fromJson', () {
    test('parses DummyJSON auth response', () {
      final json = {
        'id': 1,
        'username': 'emilys',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'image': 'https://dummyjson.com/icon/emilys/128',
        'accessToken': 'eyJhbGci...',
      };
      final model = UserModel.fromJson(json);
      expect(model.id, 1);
      expect(model.username, 'emilys');
      expect(model.firstName, 'Emily');
      expect(model.lastName, 'Johnson');
      expect(model.image, 'https://dummyjson.com/icon/emilys/128');
      expect(model.accessToken, 'eyJhbGci...');
    });
  });

  group('SessionController', () {
    test('initial state: no user, not logged in', () {
      final ctrl = SessionController.testInstance();
      expect(ctrl.user, isNull);
      expect(ctrl.isLoggedIn, false);
    });

    test('login stores user and sets isLoggedIn to true', () {
      final ctrl = SessionController.testInstance();
      final user = User(
        id: 1, username: 'emilys', firstName: 'Emily',
        lastName: 'Johnson', image: '', accessToken: 'tok',
      );
      ctrl.login(user);
      expect(ctrl.user, user);
      expect(ctrl.isLoggedIn, true);
    });

    test('logout clears user and sets isLoggedIn to false', () {
      final ctrl = SessionController.testInstance();
      final user = User(
        id: 1, username: 'emilys', firstName: 'Emily',
        lastName: 'Johnson', image: '', accessToken: 'tok',
      );
      ctrl.login(user);
      ctrl.logout();
      expect(ctrl.user, isNull);
      expect(ctrl.isLoggedIn, false);
    });
  });
}
