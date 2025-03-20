import 'package:flutter/material.dart';
import 'package:eleetdojo/pages/login.dart';
import 'package:eleetdojo/pages/profile.dart';
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
      widget.auth_service.emailSignUp(user_email, user_password);
      widget.auth_service.emailSignIn(user_email, user_password);
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
        backgroundColor: Theme.of(context)
            .colorScheme
            .surface, // Match app bar to background
        elevation: 0,
      ),
      body: Padding(
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
              style: TextStyle(
                color: primary_color,
              ), // Set user typed text color to primary_color
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: primary_color),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primary_color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primary_color, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              cursorColor: primary_color,
            ),

            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: passwordController,
              style: TextStyle(color: primary_color),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: primary_color),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primary_color),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primary_color, width: 2.0),
                ),
              ),
              obscureText: true,
              cursorColor: primary_color,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                _processCreateAccount(
                  emailController.text,
                  passwordController.text,
                );
              },
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white, // Default color for the text
                    decoration: TextDecoration.none,
                  ),
                  children: [
                    const TextSpan(text: "Already have an account? "),
                    TextSpan(
                      text: "Log in!",
                      style: const TextStyle(
                        color: Colors.blue, // Only this part will be blue
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
    );
  }
}
