import 'package:flutter/material.dart';

enum UserRole {
  admin,
  treinador,
  visitante,
}

class UserSessionProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.visitante;
  String? _equipaId;

  UserRole get role => _currentRole;
  UserRole get currentRole => _currentRole;

  String? get equipaId => _equipaId;

  bool get isAdmin => _currentRole == UserRole.admin;
  bool get isTreinador => _currentRole == UserRole.treinador;
  bool get isVisitante => _currentRole == UserRole.visitante;

  void loginComo(UserRole perfil, {String? equipaId}) {
    _currentRole = perfil;
    _equipaId = equipaId;
    notifyListeners();
  }

  void logout() {
    _currentRole = UserRole.visitante;
    _equipaId = null;
    notifyListeners();
  }
}
