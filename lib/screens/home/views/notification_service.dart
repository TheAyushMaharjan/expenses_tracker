import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the user ID from Firebase Auth
  Future<String> _getUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('User not authenticated');
    }
  }

  // Method to compare income and expense categories for the previous month vs. this month
  Future<Map<String, String>> getExpenseIncomeComparison(DateTime selectedDate) async {
    final userId = await _getUserId();

    // Get the first day of the current and previous month
    final firstDayOfCurrentMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final firstDayOfPreviousMonth = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    final firstDayOfNextMonth = DateTime(selectedDate.year, selectedDate.month + 1, 1);

    // Format dates as strings for Firestore querying
    String currentMonthStart = DateFormat('yyyy/MM/dd').format(firstDayOfCurrentMonth);
    String previousMonthStart = DateFormat('yyyy/MM/dd').format(firstDayOfPreviousMonth);
    String nextMonthStart = DateFormat('yyyy/MM/dd').format(firstDayOfNextMonth);

    // Fetch current month income documents
    final incomeDocsCurrent = await _firestore
        .collection('income')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: currentMonthStart)
        .where('date', isLessThan: nextMonthStart)
        .get();

    // Fetch current month expense documents
    final expenseDocsCurrent = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: currentMonthStart)
        .where('date', isLessThan: nextMonthStart)
        .get();

    // Fetch previous month income documents
    final incomeDocsPrevious = await _firestore
        .collection('income')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: previousMonthStart)
        .where('date', isLessThan: currentMonthStart)
        .get();

    // Fetch previous month expense documents
    final expenseDocsPrevious = await _firestore
        .collection('expenses')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: previousMonthStart)
        .where('date', isLessThan: currentMonthStart)
        .get();

    // Maps to hold sums by category
    Map<String, double> currentIncomeByCategory = {};
    Map<String, double> currentExpenseByCategory = {};
    Map<String, double> previousIncomeByCategory = {};
    Map<String, double> previousExpenseByCategory = {};

    // Helper function to sum amounts by category
    void sumByCategory(List<QueryDocumentSnapshot> docs, Map<String, double> categoryMap) {
      for (var doc in docs) {
        String category = doc['category'] ?? 'Uncategorized';
        double amount = (doc['amount'] ?? 0).toDouble();

        if (categoryMap.containsKey(category)) {
          categoryMap[category] = categoryMap[category]! + amount;
        } else {
          categoryMap[category] = amount;
        }
      }
    }

    // Calculate sums for current and previous month
    sumByCategory(incomeDocsCurrent.docs, currentIncomeByCategory);
    sumByCategory(expenseDocsCurrent.docs, currentExpenseByCategory);
    sumByCategory(incomeDocsPrevious.docs, previousIncomeByCategory);
    sumByCategory(expenseDocsPrevious.docs, previousExpenseByCategory);

    // Compare and provide suggestions
    Map<String, String> suggestions = {};

    // Compare income
    currentIncomeByCategory.forEach((category, currentAmount) {
      double previousAmount = previousIncomeByCategory[category] ?? 0.0;
      if (currentAmount < previousAmount) {
        suggestions['Income Alert - $category'] =
        'Your income for $category is lower than last month. Consider increasing income.';
      }
    });

    // Compare expenses
    currentExpenseByCategory.forEach((category, currentAmount) {
      double previousAmount = previousExpenseByCategory[category] ?? 0.0;
      if (currentAmount > previousAmount) {
        suggestions['Expense Alert - $category'] =
        'Your expenses for $category have increased. Consider reducing expenses.';
      } else if (currentAmount < previousAmount) {
        suggestions['Expense Alert - $category'] =
        'Great job! Your expenses for $category have decreased compared to last month.';
      } else {
        suggestions['Expense Alert - $category'] =
        'Your expenses for $category are the same as last month.';
      }
    });

    return suggestions;
  }
}
