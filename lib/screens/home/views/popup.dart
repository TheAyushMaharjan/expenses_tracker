import 'package:flutter/material.dart';

class LimitExceededPopup {
  static void show(BuildContext context, String note, int amount) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limit Exceeded'),
          content: Text('Expense of amount \Rs.${amount} with exceeds the set limit.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); //Close the pop-up
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}