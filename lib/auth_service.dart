import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final SupabaseClient supabase;

  AuthService({required this.supabase});

  // Initiate GitHub OAuth login
  Future<bool> githubSignIn() async {
    return await supabase.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: 'eleetdojo://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  // Initiate Google OAuth login
  Future<AuthResponse> googleSignIn() async {
    const webClientId =
        '677157494962-ag5ki0ojgfpn0a60si84g6enft043heo.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // Initial Email Signup
  Future<AuthResponse> emailSignUp(
    String user_email,
    String user_password,
  ) async {
    return await supabase.auth.signUp(
      email: user_email,
      password: user_password,
    );
  }

  // Initiate Email login
  Future<AuthResponse> emailSignIn(
    String userEmail,
    String userPassword,
  ) async {
    return await supabase.auth.signInWithPassword(
      email: userEmail,
      password: userPassword,
    );
  }

  // Signout
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Get current session
  Session? getCurrentSession() {
    return supabase.auth.currentSession;
  }

  // Get state change
  Stream<AuthState>? onAuthStateChange() {
    return supabase.auth.onAuthStateChange;
  }

  // Get current user
  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Reset user password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'eleetdojo://reset-password-callback',
      );
      debugPrint('Password reset email sent');
    } catch (error) {
      debugPrint('An error occurred: $error');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final token =
          supabase
              .auth
              .currentSession!
              .accessToken; // Get the token from session

      debugPrint('${dotenv.env['SUPABASE_URL']}/functions/v1/delete-user');

      final response = await http.post(
        Uri.parse('${dotenv.env['SUPABASE_URL']}/functions/v1/delete-user'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Add the Authorization header
        },
        body: jsonEncode({"userId": userId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete account: ${response.body}');
      }

      await signOut();
      debugPrint('Account successfully deleted');
    } catch (error) {
      debugPrint('Error deleting account: $error');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (error) {
      debugPrint('An error occurred: $error');
    }
  }
}
