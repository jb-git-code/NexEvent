import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/auth/home_page.dart';
import 'package:nexevent/screens/auth/signup_screen.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  Future<void> signIn() async {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      final snackbar = SnackBar(content: Text('Success Login'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
       Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                (route) => false,
              );
    } on FirebaseAuthException  catch (e) {
      print(e.toString());
    }
  }

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

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
                Text('Login Screen', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    hintText: 'email',
                    border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: _password,
                  decoration: InputDecoration(
                    hintText: 'password',
                    border: OutlineInputBorder()),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Don\'t have an account'),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Signup',
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
                    await signIn();
                  },
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
