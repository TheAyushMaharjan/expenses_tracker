import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart'; // Import GetX for navigation
import '../home/views/home_screen.dart'; // Import the HomeScreen (make sure you have it in your project)
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
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
      Get.off(() => HomeScreen());
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
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Login Title (Centered)
              SizedBox(height: 150), // Extra space above the heading
              Center(
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
              SizedBox(height: 40), // Extra spacing after title

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
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), // Black border
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), // Black border when the field is not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black), // Black border when the field is focused
                        ),
                        filled: true, // Ensures background color is applied
                        fillColor: Colors.white, // White background
                      ),
                      style: TextStyle(color: Colors.black), // Text color inside the field
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

                    SizedBox(height: 16),

                    // Password TextField
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)), // Semi-black label color
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        filled: true, // Ensures background color is applied
                        fillColor: Colors.white, // White background
                      ),
                      obscureText: true, // Hide the password text
                      style: TextStyle(color: Colors.black), // Text color inside the field
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    )
                    ,
                    SizedBox(height: 20),

                    // Login Button
                    _isLoading
                        ? Center(
                        child: CircularProgressIndicator()) // Show loading spinner
                        : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .blue, // Set the background color to blue
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Forgot password link
                    TextButton(
                      onPressed: _forgotPassword,
                      child: Text('Forgot Password?',
                          style: TextStyle(color: Colors.blueAccent)),
                    ),
                  ],
                ),
              ),

              // Create a New Account button
              TextButton(
                onPressed: () {
                  Get.to(() => SignUpPage());
                },
                child: Text('Create a New Account',
                    style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}