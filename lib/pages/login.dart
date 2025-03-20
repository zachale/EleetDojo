import 'package:eleetdojo/forgot_password.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:eleetdojo/main.dart';
import 'package:eleetdojo/pages/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eleetdojo/pages/signup.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:eleetdojo/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService auth_service;

  const LoginScreen({Key? key, required this.auth_service}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
    _setupAuthListener();
  }

  // Try to restore session after an OAuth redirect
  Future<void> _restoreSession() async {
    // Ensure the build context is available
    await Future.delayed(Duration.zero);

    final session = widget.auth_service.getCurrentSession();
    if (session != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => ProfileScreen(auth_service: widget.auth_service),
        ),
      );
    }
  }

  // Listen for authentication state changes and go to profile screen on login
  void _setupAuthListener() {
    widget.auth_service.onAuthStateChange()?.listen((data) {
      final event = data.event;

      if (mounted) {
        if (event == AuthChangeEvent.signedIn) {
          // Navigate to profile if signed in
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) => ProfileScreen(auth_service: widget.auth_service),
            ),
          );
        } else if (event == AuthChangeEvent.signedOut) {
          debugPrint("User signed out");
        } else if (event == AuthChangeEvent.passwordRecovery) {
          // Navigate to profile if signed in
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder:
                  (context) =>
                      ForgotPassword(auth_service: widget.auth_service),
            ),
          );
        }
      }
    });
  }

  // Process login attempt
  Future<void> _processLogin(String user_email, String user_password) async {
    try {
      await widget.auth_service.emailSignIn(user_email, user_password);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Reset Password"),
            content: TextField(
              controller: emailController,
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
                  if (emailController.text.isNotEmpty) {
                    await _sendPasswordReset(emailController.text);
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

  // Frontend UI
  @override
  Widget build(BuildContext context) {
    // Local controllers for email input
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: background_color, // Match app bar to background
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
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
                            borderSide: BorderSide(
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
                        style: TextStyle(color: primary_color),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: primary_color),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primary_color),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: primary_color,
                              width: 2.0,
                            ),
                          ),
                        ),
                        obscureText: true,
                        cursorColor: primary_color,
                      ),

                      const SizedBox(height: 16),

                      // Login button
                      ElevatedButton(
                        onPressed: () {
                          _processLogin(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                        child: const Text('Log In'),
                      ),

                      const SizedBox(height: 0),

                      // Forgot Password button
                      TextButton(
                        onPressed: () async {
                          _showForgotPasswordDialog(context);
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),

                      // Signup button
                      TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SignupScreen(
                                      auth_service: widget.auth_service,
                                    ),
                              ),
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

                      const SizedBox(height: 20),

                      // Google sign in button
                      SignInButton(
                        Buttons.Google,
                        onPressed: () {
                          widget.auth_service.googleSignIn();
                        },
                      ),

                      const SizedBox(height: 8),

                      // GitHub sign in button
                      SignInButton(
                        Buttons.GitHub,
                        onPressed: () {
                          widget.auth_service.githubSignIn();
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
