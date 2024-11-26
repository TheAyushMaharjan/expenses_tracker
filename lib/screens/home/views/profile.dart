import 'package:expenses_tracker/screens/Login/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../controller.dart';

class ProfileScreen extends StatelessWidget {
  final UserController userController = Get.put(UserController());
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user ID from FirebaseAuth
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? userId = currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
        ),
        body: const Center(
          child: Text("Error: User is not logged in."),
        ),
      );
    }

    // Fetch user data when screen loads
    userController.fetchUserData(userId);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Obx(() {
        // Check if user data is loaded
        if (userController.userData.value.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Populate controllers with user data
        usernameController.text = userController.userData.value['username'] ?? '';
        phoneController.text = userController.userData.value['phone'] ?? '';
        passwordController.text = userController.userData.value['password'] ?? '';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Update user data in Firebase
                        userController.updateUserData(userId, {
                          'username': usernameController.text,
                          'phone': phoneController.text,
                        });
                      },
                      child: const Text("Save Changes"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text("Confirm Logout"),
                            content: const Text("Do you want to logout?"),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                        onPressed: () {
                        Get.offAll(() => const LoginPage());
                        },
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
