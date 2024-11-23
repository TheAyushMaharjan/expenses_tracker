import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _filteredExpenses = [];
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Search Using Date",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start Date Selector
                ElevatedButton(
                  onPressed: () => _selectStartDate(context),
                  child: Text(
                    _startDate == null
                        ? 'Select Start Date'
                        : 'Start: ${_formatDate(_startDate!)}',
                  ),
                ),
                // End Date Selector
                ElevatedButton(
                  onPressed: () => _selectEndDate(context),
                  child: Text(
                    _endDate == null
                        ? 'Select End Date'
                        : 'End: ${_formatDate(_endDate!)}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchExpenses,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredExpenses.isEmpty
                  ? const Center(child: Text("No results found."))
                  : ListView.builder(
                itemCount: _filteredExpenses.length,
                itemBuilder: (context, index) {
                  var expense = _filteredExpenses[index];
                  return ListTile(
                    title: Text(expense['note']),
                    subtitle: Text(
                      'Amount: Rs. ${expense['amount']} \nCategory: ${expense['category']} \nDate: ${_formatDate(expense['date'])}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Select Start Date
  Future<void> _selectStartDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
      });
    }
  }

  // Select End Date
  Future<void> _selectEndDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
      });
    }
  }

  // Search Expenses Function
  Future<void> _searchExpenses() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both start and end dates")),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      // Adjust the start and end dates to cover the entire day
      DateTime adjustedStartDate = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, 0, 0, 0);
      DateTime adjustedEndDate = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);

      Timestamp startTimestamp = Timestamp.fromDate(adjustedStartDate);
      Timestamp endTimestamp = Timestamp.fromDate(adjustedEndDate);

      print("Adjusted Start Date: ${_formatDate(adjustedStartDate)} (Timestamp: $startTimestamp)");
      print("Adjusted End Date: ${_formatDate(adjustedEndDate)} (Timestamp: $endTimestamp)");

      // Query Firestore for expenses
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('expenses') // Query 'expenses' collection
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: startTimestamp)
          .where('createdAt', isLessThanOrEqualTo: endTimestamp)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        print("No expenses found for the selected dates.");
      }

      // Map the results
      List<Map<String, dynamic>> expenses = snapshot.docs.map((doc) {
        return {
          'amount': doc['amount'],
          'note': doc['note'],
          'date': doc['createdAt'].toDate(), // Convert Timestamp to DateTime
          'category': doc['category'],
        };
      }).toList();

      setState(() {
        _filteredExpenses = expenses;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching results: $e")),
      );
    }

// In the ListView.builder, apply the style to the category
    Expanded(
      child: ListView.builder(
        itemCount: _filteredExpenses.length,
        itemBuilder: (context, index) {
          var expense = _filteredExpenses[index];
          return ListTile(
            title: Text(expense['note']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: Rs. ${expense['amount']}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  'Category: ${expense['category']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Bold
                    fontSize: 16, // Font size 16
                  ),
                ),
                Text(
                  'Date: ${_formatDate(expense['date'])}',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );

  }

}
