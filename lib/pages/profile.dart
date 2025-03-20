// TEMPORARY FILE
// Just to show some simple login info and ensure redirects work

import 'package:flutter/material.dart';
import 'package:eleetdojo/main.dart';
import 'package:eleetdojo/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eleetdojo/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService auth_service;

  const ProfileScreen({super.key, required this.auth_service});

  @override
  Widget build(BuildContext context) {
    final user = auth_service.getCurrentUser();
    final profileImageUrl = user?.userMetadata?['avatar_url'];
    final fullName = user?.userMetadata?['full_name'];
    final email = user?.email;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              auth_service.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(auth_service: auth_service),
                ),
              );
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profileImageUrl != null)
              ClipOval(
                child: Image.network(
                  profileImageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              email ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
