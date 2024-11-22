import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user data from Firebase
  Future<void> fetchUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('Users').doc(userId).get();
      if (doc.exists) {
        userData.value = doc.data() as Map<String, dynamic>;
      } else {
        print("User not found!");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  // Update user data in Firebase
  Future<void> updateUserData(String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('Users').doc(userId).update(updatedData);
      userData.value = updatedData;
      Get.snackbar("Success", "Profile updated successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    }
  }

  // Logout

}
