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
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? selectedBranch;

  final List<String> branches = ["CSE", "ECE", "ME", "CE"];

  String? selectedBatch;

  final List<String> batches = ["2023-27", "2024-28", "2025-29", "2026-30"];

  Future<void> createAccount() async {
    try {
      String email = _email.text.trim();

      if (!email.endsWith("@iiitbh.ac.in")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Only IIIT Bhagalpur official email addresses are allowed.",
            ),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pop(context);
      }
      final authService = AuthService();
      // String rollNumber = _email.text.trim().split("@")[0].split(".")[1];
      String username = _email.text.trim().split("@")[0];

      List<String> parts = username.split(".");

      if (parts.length < 2) {
        throw Exception("Invalid college email format");
      }

      String rollNumber = parts[1];
      await authService.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
        role: 'student',
        batch: selectedBatch!,
        branch: selectedBranch!,
        tag: 'Default',
        roll: rollNumber,
      );
    } on FirebaseAuthException catch (e) {
      final eSnackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(eSnackbar);
    }
  }

  // Future<void> handleButtonPress() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   await Future.delayed(const Duration(seconds: 3));

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  int? _value = 1;

  List<String> roles = ['student', 'admin'];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Visual branding header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Join NexEvent and unlock amazing events',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Fields
                  TextFormField(
                    controller: _name,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Name is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }

                      if (!value.endsWith("@iiitbh.ac.in")) {
                        return "Only IIIT Bhagalpur official email is allowed.";
                      }

                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      labelText: 'College Email Address ',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedBranch,
                    decoration: const InputDecoration(
                      labelText: "Branch",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    items: branches.map((branch) {
                      return DropdownMenuItem(
                        value: branch,
                        child: Text(branch),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBranch = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: selectedBatch,
                    decoration: const InputDecoration(
                      labelText: "Batch",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    items: batches.map((batch) {
                      return DropdownMenuItem(value: batch, child: Text(batch));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBatch = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outlined),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role Selection
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFF3F4F6),
                  //     borderRadius: BorderRadius.circular(16),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: <Widget>[
                  //       Text(
                  //         'Select Your Role',
                  //         style: TextStyle(
                  //           fontSize: 14,
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.grey[700],
                  //         ),
                  //       ),
                  //       const SizedBox(height: 12.0),
                  //       Wrap(
                  //         spacing: 8.0,
                  //         children: List<Widget>.generate(2, (int index) {
                  //           final isSelected = _value == index;
                  //           return ChoiceChip(
                  //             label: Text(
                  //               roles[index].toUpperCase(),
                  //               style: TextStyle(
                  //                 color: isSelected
                  //                     ? Colors.white
                  //                     : Colors.grey[700],
                  //                 fontWeight: FontWeight.bold,
                  //                 fontSize: 13,
                  //               ),
                  //             ),
                  //             selected: isSelected,
                  //             selectedColor: primaryColor,
                  //             backgroundColor: Colors.white,
                  //             checkmarkColor: Colors.white,
                  //             side: BorderSide(
                  //               color: isSelected
                  //                   ? primaryColor
                  //                   : Colors.grey[300]!,
                  //               width: 1,
                  //             ),
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //             onSelected: (bool selected) {
                  //               setState(() {
                  //                 _value = selected ? index : null;
                  //                 role = roles[index];
                  //               });
                  //             },
                  //           );
                  //         }).toList(),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shadowColor: primaryColor.withValues(alpha: 0.3),
                      elevation: 4,
                    ),
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        await createAccount();
                        print('create account');
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Account Created")),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,

                          MaterialPageRoute(builder: (_) => const HomePage()),

                          (route) => false,
                        );
                      } finally {
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : const Text('Sign Up'),
                  ),
                  const SizedBox(height: 24),

                  // Toggle Auth Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const loginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
