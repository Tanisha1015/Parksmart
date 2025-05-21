// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:park_smart/providers/auth_provider.dart';
import 'package:park_smart/screens/home_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_parking_rounded,
              size: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Park Smart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Find parking spaces with ease',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 50),
            if (authProvider.isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final userCredential = await authProvider.signInWithGoogle();
                    if (userCredential != null && context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign in failed: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.login),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    'Sign in with Google',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
