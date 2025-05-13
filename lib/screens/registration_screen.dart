import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email     = _emailCtrl.text.trim();
    final password  = _passwordCtrl.text;
    final firstName = _firstNameCtrl.text.trim();
    final lastName  = _lastNameCtrl.text.trim();

    try {
      // 1️⃣ Sign up
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'first_name': firstName, 'last_name': lastName},
      );

      if (!mounted) return;

      if (response.user != null) {
        final userId = response.user!.id;

        // 2️⃣ Save profile row
        try {
          final profile = await Supabase.instance.client
              .from('user_profiles')         // ← your actual table
              .insert({
                'user_id':    userId,        // ← PK column
                'first_name': firstName,
                'last_name':  lastName,
                'email':      email,
                'created_at': DateTime.now().toUtc().toIso8601String(),
              })
              .select()
              .single();                    // ← returns the inserted row

          // if you need to use `profile`, it’s here as a Map<String, dynamic>
        } catch (e) {
          // profile save failed, but we’ll still navigate
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile save failed: $e')),
          );
        }

        // 3️⃣ Done!
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        // email confirmation required
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check your email for confirmation link.')),
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $error')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameCtrl,
                            decoration:
                                const InputDecoration(labelText: 'First Name'),
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v!.isEmpty ? 'Enter first name' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameCtrl,
                            decoration:
                                const InputDecoration(labelText: 'Last Name'),
                            textInputAction: TextInputAction.next,
                            validator: (v) =>
                                v!.isEmpty ? 'Enter last name' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter email';
                        final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        return regex.hasMatch(v) ? null : 'Enter valid email';
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: (v) => v != null && v.length >= 6
                          ? null
                          : 'Password must be at least 6 characters',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) => v == _passwordCtrl.text
                          ? null
                          : 'Passwords do not match',
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _registerWithEmail,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child:
                                const Text('Register', style: TextStyle(fontSize: 16)),
                          ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Already have an account? Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
