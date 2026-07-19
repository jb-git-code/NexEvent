import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PasswordRecovery extends StatefulWidget {
  const PasswordRecovery({super.key});

  @override
  State<PasswordRecovery> createState() => _PasswordRecoveryState();
}

class _PasswordRecoveryState extends State<PasswordRecovery> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recover Your Account'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          child: Column(
            children: [
              Text('Enter your college email'),
              const SizedBox(height: 20),
              TextField(controller: emailController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: emailController.text.trim(),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Password reset link sent to your email.",
                        ),
                      ),
                    );
                    Navigator.of(context).pop();
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.message ?? "Error")),
                    );
                  }
                },
                child: const Text("Reset Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
