// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// class NotificationService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<String> _getUserId() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       return user.uid;
//     } else {
//       throw Exception('User not authenticated');
//     }
//   }
//
//   // Method to get the note from Firebase
//   Future<String> _getCategoryNote(String category) async {
//     final userId = await _getUserId();
//
//     // Retrieve note for a given category from Firebase
//     final noteDoc = await _firestore
//         .collection('notes')
//         .doc(userId) // Assuming notes are user-specific
//         .collection('categories')
//         .doc(category) // Using category as the document ID
//         .get();
//
//     if (noteDoc.exists && noteDoc.data() != null) {
//       return noteDoc['note'] ?? ''; // Return note or empty string if no note is found
//     } else {
//       return ''; // If no note is found, return empty string
//     }
//   }
//
//   Future<Map<String, String>> getExpenseIncomeComparison(DateTime selectedDate) async {
//     final userId = await _getUserId();
//
//     // Get start of current, previous, and next month dates
//     final firstDayOfCurrentMonth = DateTime(selectedDate.year, selectedDate.month, 1);
//     final firstDayOfPreviousMonth = DateTime(selectedDate.year, selectedDate.month - 1, 1);
//     final firstDayOfNextMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);
//
//     String currentMonthStart = DateFormat('yyyy/MM/dd').format(firstDayOfCurrentMonth);
//     String previousMonthStart = DateFormat('yyyy/MM/dd').format(firstDayOfPreviousMonth);
//     String nextMonthStart = DateFormat('yyyy/MM/dd').format(firstDayOfNextMonth);
//
//     // Fetch records from Firestore
//     final incomeDocsCurrent = await _firestore
//         .collection('income')
//         .where('userId', isEqualTo: userId)
//         .where('date', isGreaterThanOrEqualTo: currentMonthStart)
//         .where('date', isLessThan: nextMonthStart)
//         .get();
//
//     final expenseDocsCurrent = await _firestore
//         .collection('expenses')
//         .where('userId', isEqualTo: userId)
//         .where('date', isGreaterThanOrEqualTo: currentMonthStart)
//         .where('date', isLessThan: nextMonthStart)
//         .get();
//
//     final incomeDocsPrevious = await _firestore
//         .collection('income')
//         .where('userId', isEqualTo: userId)
//         .where('date', isGreaterThanOrEqualTo: previousMonthStart)
//         .where('date', isLessThan: currentMonthStart)
//         .get();
//
//     final expenseDocsPrevious = await _firestore
//         .collection('expenses')
//         .where('userId', isEqualTo: userId)
//         .where('date', isGreaterThanOrEqualTo: previousMonthStart)
//         .where('date', isLessThan: currentMonthStart)
//         .get();
//
//     // Initialize category maps
//     Map<String, double> currentIncomeByCategory = {};
//     Map<String, double> currentExpenseByCategory = {};
//     Map<String, double> previousIncomeByCategory = {};
//     Map<String, double> previousExpenseByCategory = {};
//
//     // Function to sum amounts by category
//     void sumByCategory(List<QueryDocumentSnapshot> docs, Map<String, double> categoryMap) {
//       for (var doc in docs) {
//         String category = doc['category'] ?? 'Uncategorized';
//         double amount = (doc['amount'] ?? 0).toDouble();
//         categoryMap.update(category, (existingAmount) => existingAmount + amount, ifAbsent: () => amount);
//       }
//     }
//
//     // Sum the amounts for each category
//     sumByCategory(incomeDocsCurrent.docs, currentIncomeByCategory);
//     sumByCategory(expenseDocsCurrent.docs, currentExpenseByCategory);
//     sumByCategory(incomeDocsPrevious.docs, previousIncomeByCategory);
//     sumByCategory(expenseDocsPrevious.docs, previousExpenseByCategory);
//
//     Map<String, String> suggestions = {};
//
//     // Compare current vs previous income by category
//     currentIncomeByCategory.forEach((category, currentAmount) {
//       double previousAmount = previousIncomeByCategory[category] ?? 0.0;
//       if (currentAmount < previousAmount) {
//         suggestions['Income Alert - $category'] =
//         'Your income for $category is lower than last month. Consider increasing income.';
//       }
//     });
//
//     int currentExpenseCategoriesCount = currentExpenseByCategory.length;
//
//     // Fetch and add the note for each category
//     for (var category in currentExpenseByCategory.keys) {
//       String note = await _getCategoryNote(category); // Get the note for the category
//
//       // Debugging: Check the note fetched
//       print('Fetched note for $category: $note');
//
//       double currentAmount = currentExpenseByCategory[category] ?? 0.0;
//       double previousAmount = previousExpenseByCategory[category] ?? 0.0;
//
//       if (previousAmount == 0.0 && currentExpenseCategoriesCount == 1) {
//         // Show "New Expense" notification only if there's a single category
//         suggestions['New Expense - $category'] =
//         'You have added a new expense category: $category. $note';
//       } else if (currentAmount > previousAmount) {
//         suggestions['Expense Alert - $category'] =
//         'Your expenses for $category have increased. Consider reducing expenses. $note';
//       } else if (currentAmount < previousAmount) {
//         suggestions['Expense Alert - $category'] =
//         'Great job! Your expenses for $category have decreased compared to last month. $note';
//       } else {
//         suggestions['Expense Alert - $category'] =
//         'Your expenses for $category are the same as last month. $note';
//       }
//     }
//
//     return suggestions;
//   }
// }
