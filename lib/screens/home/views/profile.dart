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

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user ID from FirebaseAuth
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? userId = currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
        ),
        body: Center(
          child: Text("Error: User is not logged in."),
        ),
      );
    }

    // Fetch user data when screen loads
    userController.fetchUserData(userId);

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: Obx(() {
        // Check if user data is loaded
        if (userController.userData.value.isEmpty) {
          return Center(child: CircularProgressIndicator());
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
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16),
              SizedBox(height: 32),
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
                      child: Text("Save Changes"),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: Text("Confirm Logout"),
                            content: Text("Do you want to logout?"),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text("Cancel"),
                              ),
                              ElevatedButton(
                        onPressed: () {
                        Get.offAll(() => LoginPage());
                        },
                                child: Text("Logout"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text("Logout"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                      ),
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
