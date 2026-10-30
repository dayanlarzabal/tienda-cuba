import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    // TODO: llamar al backend
    _token = 'demo-token';
    notifyListeners();
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
