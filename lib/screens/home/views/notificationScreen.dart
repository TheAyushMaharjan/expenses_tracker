// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../stats/popup_notification.dart';
//
// class NotificationScreen extends StatefulWidget {
//   final Function(double) updateExpenseLimit; // Callback to update the limit
//
//   const NotificationScreen({super.key, required this.updateExpenseLimit});
//
//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }
//
// class _NotificationScreenState extends State<NotificationScreen> {
//   double _expenseLimit = 20000.0; // Default limit is 20,000
//   double incomeTotal = 15000.0; // Example income
//   double expenseTotal = 25000.0; // Example expense
//   bool _isNewExpenseAdded = false; // Flag to track if a new expense is added
//
//   // Save the expense limit to SharedPreferences and update the callback
//   Future<void> _saveExpenseLimit() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setDouble('expenseLimit', _expenseLimit);
//
//     // Update the limit in MainScreen through the callback
//     widget.updateExpenseLimit(_expenseLimit);
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Expense limit saved!')),
//     );
//
//     // Optionally, navigate back to MainScreen after saving
//     Navigator.of(context).pop(); // This will navigate back to MainScreen
//   }
//
//   // Simulate adding a new expense and check if it exceeds the limit
//   void _addNewExpense(double amount) {
//     setState(() {
//       expenseTotal += amount;
//       if (expenseTotal > _expenseLimit) {
//         _isNewExpenseAdded = true; // New expense exceeds the limit
//       } else {
//         _isNewExpenseAdded = false; // Reset if expense doesn't exceed the limit
//       }
//     });
//
//     // Use Future.delayed to show the popup after state is updated
//     Future.delayed(Duration.zero, () {
//       if (_isNewExpenseAdded) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Expense Limit Exceeded!'),
//               content: Text('Your expenses have exceeded the limit of Rs. $_expenseLimit.'),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close the dialog
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Notifications'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Set Expense Limit:',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//
//             // Slider to adjust the expense limit
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Rs. ${_expenseLimit.toStringAsFixed(0)}',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 Slider(
//                   value: _expenseLimit,
//                   min: 5000.0,
//                   max: 50000.0,
//                   divisions: 9,
//                   label: _expenseLimit.toStringAsFixed(0),
//                   onChanged: (double value) {
//                     setState(() {
//                       _expenseLimit = value;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             // Save button to save the limit
//             ElevatedButton(
//               onPressed: _saveExpenseLimit,
//               child: const Text('Save Limit'),
//             ),
//             const SizedBox(height: 24),
//
//             // Simulate adding a new expense (just for testing purposes)
//             ElevatedButton(
//               onPressed: () => _addNewExpense(5000.0), // Example expense of 5000
//               child: const Text('Add New Expense of Rs. 5000'),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Trigger Popup Notification based on income and expense totals
//             PopupNotification(
//               incomeTotal: incomeTotal,
//               expenseTotal: expenseTotal,
//               expenseLimit: _expenseLimit,
//               isNewExpenseAdded: _isNewExpenseAdded, // Pass the flag here
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
