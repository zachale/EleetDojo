import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eleetdojo/widgets/go_app_bar.dart';

class ErrorPage extends StatelessWidget {
  final String message;
  final String route;
  final String? buttonText;

  const ErrorPage({
    super.key,
    required this.message,
    this.route = '/learning-map',
    this.buttonText = 'Return to Learning Map',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GoAppBar(name: 'Error', route: route),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go(route),
                child: Text(buttonText!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
