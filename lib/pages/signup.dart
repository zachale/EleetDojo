import 'package:flutter/material.dart';
import 'package:eleetdojo/pages/login.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eleetdojo/main.dart';
import 'package:eleetdojo/auth_service.dart';

class SignupScreen extends StatefulWidget {
  final AuthService auth_service;

  const SignupScreen({Key? key, required this.auth_service}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Process create account attempt
  Future<void> _processCreateAccount(
    String user_email,
    String user_password,
  ) async {
    try {
      await widget.auth_service.emailSignUp(user_email, user_password);
      if (mounted) {
        context.go('/learning-map');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Sign Up'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Title
              const Text(
                'eLeet Dojo',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primary_color,
                ),
              ),
              const SizedBox(height: 10),
              // Logo
              Image.asset('assets/eleetdojo_logo.png', width: 120),
              const SizedBox(height: 20),
              // Email field
              TextField(
                controller: emailController,
                style: const TextStyle(color: primary_color),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: primary_color),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: primary_color),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: primary_color,
                      width: 2.0,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                cursorColor: primary_color,
              ),
              const SizedBox(height: 16),
              // Password field
              TextField(
                controller: passwordController,
                style: const TextStyle(color: primary_color),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: primary_color),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: primary_color),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: primary_color,
                      width: 2.0,
                    ),
                  ),
                ),
                obscureText: true,
                cursorColor: primary_color,
                onSubmitted: (value) {
                  _processCreateAccount(
                    emailController.text,
                    passwordController.text,
                  );
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _processCreateAccount(
                    emailController.text,
                    passwordController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 2, color: primary_color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.go('/login');
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                    children: [
                      TextSpan(text: "Already have an account? "),
                      TextSpan(
                        text: "Log in!",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
