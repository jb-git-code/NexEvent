import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nexevent/screens/home/home_page.dart';
import 'package:nexevent/screens/auth/login_screen.dart';
import 'package:nexevent/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _name = TextEditingController();
  String role = "";

  Future<void> createAccount() async {
    try {
      final snackbar = SnackBar(content: Text('Account Created'));
      final authService = AuthService();
      authService.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        role: role,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      final e_snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(e_snackbar);
    }
  }

  int? _value = 1;

  List<String> roles = ['student', 'admin'];

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
                  controller: _name,
                  decoration: InputDecoration(
                    hintText: 'name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _email,
                  decoration: InputDecoration(
                    hintText: 'email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'password',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .center,
                  children: <Widget>[
                    Text('Select your role'),
                    const SizedBox(height: 10.0),
                    Wrap(
                      spacing: 5.0,
                      children: List<Widget>.generate(2, (int index) {
                        return ChoiceChip(
                          label: Text(roles[index]),
                          selected: _value == index,
                          onSelected: (bool selected) {
                            setState(() {
                              _value = selected ? index : null;
                              role = roles[index];
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
