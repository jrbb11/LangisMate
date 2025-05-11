import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final success = await AuthService().signUp(
                  emailCtrl.text,
                  passCtrl.text,
                );

                if (!mounted) return;

                Fluttertoast.showToast(
                  msg: success ? 'Registered!' : 'Failed to register',
                );

                if (success) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
