import 'package:flutter/material.dart';
import 'package:eleetdojo/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eleetdojo/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  final AuthService auth_service;

  const ForgotPassword({super.key, required this.auth_service});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _newPasswordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _resetPassword() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final newPassword = _newPasswordController.text.trim();
      if (newPassword.isEmpty || newPassword.length < 6) {
        throw 'Password must be at least 6 characters long.';
      }

      await widget.auth_service.updatePassword(newPassword);
      await widget.auth_service.signOut();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated! Please log in.')),
      );

      // Navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(auth_service: widget.auth_service),
        ),
      );
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your new password:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _resetPassword,
              child:
                  _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
