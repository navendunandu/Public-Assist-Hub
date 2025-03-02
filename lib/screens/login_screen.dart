import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:public_assist_hub/components/form_validation.dart';
import 'package:public_assist_hub/components/loader_screen.dart';
import 'package:public_assist_hub/screens/homescreen.dart';
import 'package:public_assist_hub/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) return;

    Loader.showLoader(context);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailEditingController.text,
        password: _passwordEditingController.text,
      );
      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('tbl_user').doc(uid).get();

      if (userDoc.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Loader.hideLoader(context);
        _showErrorToast("No user found for that email.");
      }
    } on FirebaseAuthException catch (e) {
      Loader.hideLoader(context);
      if (e.code == 'user-not-found') {
        _showErrorToast("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        _showErrorToast("Wrong password provided for that user.");
      } else {
        _showErrorToast("Something went wrong! Please try again.");
      }
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot Password', style: GoogleFonts.poppins()),
        content: TextFormField(
          controller: emailController,
          validator: FormValidation.validateEmail,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email, color: Color(0xFF33A4BB)),
            hintText: 'Enter Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF33A4BB)),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (FormValidation.validateEmail(emailController.text) != null) {
                _showErrorToast("Please enter a valid email");
                return;
              }
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
                _showSuccessToast("Password reset email sent. Check your inbox.");
                Navigator.pop(context);
              } catch (e) {
                _showErrorToast("Failed to send reset email: $e");
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF33A4BB)),
            child: Text('Send', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessToast(String message) {
    CherryToast.success(
      title: Text(message, style: const TextStyle(color: Colors.black)),
    ).show(context);
  }

  void _showErrorToast(String message) {
    CherryToast.error(
      description: Text(message, style: const TextStyle(color: Colors.black)),
      animationType: AnimationType.fromRight,
      animationDuration: const Duration(milliseconds: 1000),
      autoDismiss: true,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  "Welcome",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 44,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "back!",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 44,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Sign in to your account",
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) => FormValidation.validateEmail(value),
                        controller: _emailEditingController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person, color: Color(0xFF33A4BB)),
                          hintText: 'Enter E-mail',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 72, 72, 72)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF33A4BB)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: const Color(0xFF33A4BB),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        validator: (value) => FormValidation.validatePassword(value),
                        controller: _passwordEditingController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.key, color: Color(0xFF33A4BB)),
                          hintText: 'Enter Password',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color.fromARGB(255, 72, 72, 72)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF33A4BB)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: const Color.fromARGB(255, 116, 116, 116),
                            ),
                            onPressed: () {
                              setState(() => _obscureText = !_obscureText);
                            },
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        cursorColor: const Color(0xFF33A4BB),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Color(0xFF33A4BB)),
                            ),
                            onPressed: _showForgotPasswordDialog,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF33A4BB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                "Sign in",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: Text("Don't have an account? ", style: TextStyle(color: Colors.black)),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                              );
                            },
                            child: const Text(
                              'Create a new account',
                              style: TextStyle(color: Color(0xFF33A4BB)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}