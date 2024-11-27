import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _filteredEntries = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedType = "Expenses"; // Default filter type

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
            const Text(
              "Search Using Date and Type",
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
            // Dropdown for selecting type
            DropdownButton<String>(
              value: _selectedType,
              items: ["Income", "Expenses"]
                  .map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchEntries,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _filteredEntries.isEmpty
                  ? const Center(child: Text("No results found.", style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                itemCount: _filteredEntries.length,
                itemBuilder: (context, index) {
                  var entry = _filteredEntries[index];
                  return Card(
                    elevation: 4, // Subtle shadow for each card
                    margin: const EdgeInsets.symmetric(vertical: 8), // Vertical margin between items
                    shape: RoundedRectangleBorder( // Rounded corners for the card
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), // Padding inside each card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Note Text
                          Text(
                            entry['note'] ?? "No description", // Default text if note is empty
                            style: const TextStyle(
                              fontSize: 18, // Larger font size for title
                              fontWeight: FontWeight.bold, // Bold title
                              color: Colors.black87, // Darker color for text
                            ),
                          ),
                          const SizedBox(height: 8), // Space between text
                          // Amount Text
                          Text(
                            'Amount: Rs. ${entry['amount']}', // Ensure this displays correctly
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 8), // Space between text
                          // Date Text
                          Text(
                            'Date: ${_formatDate(entry['date'])}',
                            style: TextStyle(
                              fontSize: 14, // Smaller font size for date
                              color: Colors.grey[600], // Lighter color for date
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )

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
    if (_startDate == null) {
      // Show a warning or handle the case where start date is not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date first.')),
      );
      return;
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _startDate!, // Ensure end date is not earlier than the start date
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
      });
    }
  }

  // Search Entries Function
  Future<void> _searchEntries() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end dates")),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print("User not logged in.");
        return;
      }

      // Convert the selected dates to match the Firestore format
      String startDateString = DateFormat('yyyy/MM/dd').format(_startDate!);
      String endDateString = DateFormat('yyyy/MM/dd').format(_endDate!);

      print("Start Date (Formatted): $startDateString");
      print("End Date (Formatted): $endDateString");

      String collectionName = _selectedType == 'Expenses' ? 'expenses' : 'income';

      // Query the collection using the corrected date format
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('userId', isEqualTo: user.uid)
          .where('date', isGreaterThanOrEqualTo: startDateString)
          .where('date', isLessThanOrEqualTo: endDateString)
          .orderBy('date', descending: true)
          .get();

      print("Found ${snapshot.docs.length} documents in $collectionName");

      if (snapshot.docs.isEmpty) {
        print("No data found.");
      }

      List<Map<String, dynamic>> entries = snapshot.docs.map((doc) {
        String dateString = doc['date'];

        // Convert the date string to DateTime using the known format
        DateTime date = DateFormat('yyyy/MM/dd').parse(dateString);

        return {
          'amount': doc['amount'],
          'note': doc['note'],
          'date': date, // Use the parsed DateTime object here
        };
      }).toList();


      setState(() {
        _filteredEntries = entries;
      });
    } catch (e) {
      print("Error during query: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching results: $e")),
      );
    }
  }




}
