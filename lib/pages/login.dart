import 'package:eleetdojo/pages/reset_password.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:eleetdojo/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eleetdojo/pages/signup.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:eleetdojo/auth_service.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  final AuthService auth_service;

  const LoginScreen({Key? key, required this.auth_service}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    attemptLogIn();
    _setupAuthListener();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> attemptLogIn() async {
    await Future.delayed(Duration.zero);

    final session = widget.auth_service.getCurrentSession();
    debugPrint("Session: $session");
    if (session != null && mounted) {
      context.go('/learning-map');
    }
  }

  // Process login attempt
  Future<void> _processLogin(String user_email, String user_password) async {
    try {
      await widget.auth_service.emailSignIn(user_email, user_password);
      attemptLogIn();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailResetController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Reset Password"),
            content: TextField(
              controller: emailResetController,
              decoration: const InputDecoration(labelText: "Enter your email"),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (emailResetController.text.isNotEmpty) {
                    await _sendPasswordReset(emailResetController.text);
                  }
                  Navigator.pop(context);
                },
                child: const Text("Send"),
              ),
            ],
          ),
    );
  }

  Future<void> _sendPasswordReset(String email) async {
    try {
      await widget.auth_service.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password reset email sent! Check your inbox (and your Junk Mail)!",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
      );
    }
  }

  // Listen for authentication state changes and go to profile screen on login
  void _setupAuthListener() {
    widget.auth_service.onAuthStateChange()?.listen((data) {
      final event = data.event;

      if (mounted) {
        if (event == AuthChangeEvent.signedIn) {
          attemptLogIn();
        }
      }
    });
  }

  // Frontend UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      Text(
                        'eLeet Dojo',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: primary_color,
                          fontFamily: 'Monospace',
                          shadows: [
                            Shadow(blurRadius: 8.0, offset: Offset(3, 3)),
                          ],
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
                          _processLogin(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // Login button
                      ElevatedButton(
                        onPressed: () {
                          _processLogin(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                            width: 2,
                            color: primary_color,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Log In'),
                      ),

                      const SizedBox(height: 16),

                      // Signup button
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            GoRouter.of(context).go('/signup');
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: const Size(10, 10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.none,
                            ),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: "Sign up!",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Forgot Password button
                      TextButton(
                        onPressed: () async {
                          _showForgotPasswordDialog(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: const Size(10, 10),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Google sign in button
                      SignInButton(
                        Buttons.Google,
                        onPressed: () async {
                          await widget.auth_service.googleSignIn();
                          attemptLogIn();
                        },
                      ),

                      const SizedBox(height: 8),

                      // GitHub sign in button
                      SignInButton(
                        Buttons.GitHub,
                        onPressed: () async {
                          await widget.auth_service.githubSignIn();
                          attemptLogIn();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
