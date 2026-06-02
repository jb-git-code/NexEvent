import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/auth/home_page.dart';
import 'package:nexevent/screens/auth/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  Future<void> createAccount() async {
    try {
      FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      final snackbar = SnackBar(content: Text('Account Created'));
      await ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Signup Screen', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _password,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Already have an account'),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => loginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.black),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                  ),
                  onPressed: () async {
                    await createAccount();
                  },
                  child: Text('Signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
