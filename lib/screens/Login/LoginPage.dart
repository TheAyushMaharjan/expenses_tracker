import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart'; // Import GetX for navigation
import '../home/views/home_screen.dart'; // Import the HomeScreen (make sure you have it in your project)
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // To track loading state

  // Form validation keys
  final _formKey = GlobalKey<FormState>();

  // Login function
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // On successful login, navigate to the HomeScreen
      Get.off(() => const HomeScreen());
    } catch (e) {
      // Handle error during login
      print('Error: $e');
      // Show error snackbar
      Get.snackbar('Login Failed', 'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Forgot password function
  Future<void> _forgotPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      Get.snackbar('Password Reset', 'Password reset email sent.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error: $e');
      Get.snackbar('Error', 'Failed to send reset email.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Login Title (Centered)
              const SizedBox(height: 150), // Extra space above the heading
              const Center(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align texts to the left
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                                color: Color(0xFF131313),
                            ),
                          ),
                          SizedBox(height: 8), // Space between the title and subtitle
                          Text(
                            'Welcome back to the app',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Extra spacing after title

              // Form for email and password
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email TextField
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)), // Semi-black label color
                        prefixIcon: const Icon(Icons.email),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), // Black border
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), // Black border when the field is not focused
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), // Black border when the field is focused
                        ),
                        filled: true, // Ensures background color is applied
                        fillColor: Colors.white, // White background
                      ),
                      style: const TextStyle(color: Colors.black), // Text color inside the field
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        }
                        if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
                            .hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password TextField
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)), // Semi-black label color
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), 
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), 
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), 
                        ),
                        filled: true, // Ensures background color is applied
                        fillColor: Colors.white, // White background
                      ),
                      obscureText: true, // Hide the password text
                      style: const TextStyle(color: Colors.black), // Text color inside the field
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    )
                    ,
                    const SizedBox(height: 20),

                    // Login Button
                    _isLoading
                        ? const Center(
                        child: CircularProgressIndicator()) // Show loading spinner
                        : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .blue, // Set the background color to blue
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Forgot password link
                    TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('Forgot Password?',
                          style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ],
                ),
              ),

              // Create a New Account button
              TextButton(
                onPressed: () {
                  Get.to(() => const SignUpPage());
                },
                child: const Text('Create a New Account',
                    style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}