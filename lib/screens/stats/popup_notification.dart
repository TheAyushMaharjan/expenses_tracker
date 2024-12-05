import 'package:flutter/material.dart';

class PopupNotification extends StatelessWidget {
  final double incomeTotal;
  final double expenseTotal;
  final double expenseLimit;
  final bool isNewExpenseAdded; // Flag to check if a new expense was added

  const PopupNotification({
    Key? key,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.expenseLimit,
    required this.isNewExpenseAdded, // Pass this flag to the widget
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the popup should be shown (only show for new expense added and total exceeds limit)
    if (isNewExpenseAdded && expenseTotal > expenseLimit) {
      // Show the popup if condition is met
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('High Transaction Alert!'),
              content: Text(
                'You have added more than $expenseLimit in Expenses.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      });
    }

    return const SizedBox.shrink(); // Return an empty widget since we're showing a dialog
  }
}
