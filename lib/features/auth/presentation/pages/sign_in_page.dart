import 'package:flutter/material.dart';

/// Minimal sign-in page used by the boilerplate router.
///
/// In real projects, replace this with your actual auth flow while keeping
/// the routing structure intact.
class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sign in screen placeholder'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement sign-in flow or replace this page.
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

