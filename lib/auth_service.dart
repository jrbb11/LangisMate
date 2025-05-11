import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<bool> signUp(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password);
    return res.user != null;
  }

  Future<bool> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    return res.user != null;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
}
