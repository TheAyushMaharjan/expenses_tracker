import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/services.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}
class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  DateTime selectDate = DateTime.now();

  // Dropdown for type (Expenses/Income)
  String selectedType = 'Expenses'; // Default selection
  List<String> types = ['Expenses', 'Income'];

  // Dropdown for category (initialized with the first option in the list)
  String selectedCategory = 'Food & Dining'; // Default category selection
  List<String> categories = [
    'Food & Dining', 'Transport', 'Housing', 'Entertainment', 'Health & Fitness',
    'Shopping', 'Education', 'Bills & Subscriptions', 'Savings & Investments',
    'Miscellaneous'
  ];

  @override
  void initState() {
    dateController.text = DateFormat('yyyy/MM/dd').format(DateTime.now());
    super.initState();
  }

  Future<void> saveData() async {
    String amount = expenseController.text;
    String note = noteController.text;
    String date = dateController.text;
    String category = selectedCategory;

    if (amount.isEmpty || note.isEmpty || date.isEmpty || category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    String? userId = user?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    CollectionReference collection =
    FirebaseFirestore.instance.collection(selectedType.toLowerCase());

    try {
      await collection.add({
        'userId': userId,
        'amount': double.parse(amount),
        'note': note,
        'date': date,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$selectedType added successfully")),
      );

      // Pop the screen and return true to indicate that a new transaction was added
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add $selectedType: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Expenses/Income"),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Add Entry",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16.0),

                // Dropdown for selecting type
                DropdownButtonFormField<String>(
                  value: selectedType,
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                  items: types.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Select Type',
                  ),
                ),
                const SizedBox(height: 16.0),
                  //Amount field
                TextFormField(
                  controller: expenseController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Rs.',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 24.0,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 24.0,
                    color: Colors.black,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(9), // Limit to 9 digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    double? amount = double.tryParse(value);
                    if (amount != null && amount < 0) {
                      return 'Amount cannot be negative';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Note field
                TextFormField(
                  controller: noteController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.note,
                      color: Colors.grey[600],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.0,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]')), // Only letters and spaces
                  ],
                ),
                const SizedBox(height: 16.0),


                // Category dropdown
                DropdownButtonFormField<String>(
                  value: selectedCategory, // Set the initial value to be a valid category
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Select Category',
                  ),
                ),
                const SizedBox(height: 16.0),

                // Date field
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(), // Restrict selection to current date or past dates
                    );
                    if (picked != null) {
                      setState(() {
                        selectDate = picked; // Update the DateTime object
                        dateController.text = DateFormat('yyyy/MM/dd').format(picked); // Update the display format
                      });
                    }
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.date_range_rounded,
                      color: Colors.grey[600],
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Date',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.0,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                )
                ,
                const SizedBox(height: 16.0),

                // Save button
                ElevatedButton(
                  onPressed: saveData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 60.0),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
