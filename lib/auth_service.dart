import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps Supabase auth errors into a single type.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Registers a new user. Throws [AuthException] on failure.
  Future<User> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw AuthException('Sign up failed, no user returned.');
      }
      return user;
    } on AuthException {
      rethrow; // already an AuthException
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Signs in an existing user. Throws [AuthException] on failure.
  Future<User> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw AuthException('Sign in failed, no user returned.');
      }
      return user;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// The currently authenticated user (or null).
  User? get currentUser => _client.auth.currentUser;
}
