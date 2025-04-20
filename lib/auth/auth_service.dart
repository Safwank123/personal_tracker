import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  User? _currentUser;
  bool _isDarkMode = false;

  AuthService() {
    _currentUser = _client.auth.currentUser;
    _client.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isDarkMode => _isDarkMode;

  Future<void> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      print('Sign up complete: ${response.user?.email}');
      if (response.user?.emailConfirmedAt == null) {
        print('Check your email to confirm account.');
      }
      notifyListeners();
    } on AuthException catch (e) {
      print('AuthException on signUp: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error on signUp: $e');
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('Sign in successful: ${response.user?.email}');
      notifyListeners();
    } on AuthException catch (e) {
      print('AuthException on signIn: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error on signIn: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void logout() async {
    await signOut();
  }
}
