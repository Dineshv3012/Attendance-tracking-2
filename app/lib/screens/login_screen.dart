
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Attendance Pro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 8),
                  TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                  const SizedBox(height: 16),
                  if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
                  ElevatedButton(
                    onPressed: loading ? null : () async {
                      setState(() { loading = true; error = null; });
                      try {
                        await AuthService.instance.signInWithEmail(emailCtrl.text.trim(), passCtrl.text);
                      } catch (e) {
                        setState(() { error = e.toString(); });
                      } finally {
                        if (mounted) setState(() { loading = false; });
                      }
                    },
                    child: Text(loading ? 'Signing in...' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await AuthService.instance.signInWithGoogle();
                      } catch (e) {
                        setState(() { error = e.toString(); });
                      }
                    },
                    child: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      if (emailCtrl.text.isEmpty) {
                        setState(() { error = 'Enter email to reset password'; });
                        return;
                      }
                      await AuthService.instance.sendReset(emailCtrl.text.trim());
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset email sent')));
                      }
                    },
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
