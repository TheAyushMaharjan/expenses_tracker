import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseController = TextEditingController();
  TextEditingController catagoryController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  DateTime selectDate = DateTime.now();
@override
  void initState() {
dateController.text =  DateFormat('yyyy/MM/dd').format(DateTime.now());
super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Expenses"),
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
                  "Add Expenses",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16.0),
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
                      borderSide: BorderSide(color: Colors.blue),
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
                ),
                const SizedBox(height: 16.0),

                //catagory
                TextFormField(
                  controller: catagoryController,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.list_alt_rounded,
                      color: Colors.grey[600],
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add, size: 16),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              title: Text('Select Category'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.fastfood),
                                    title: Text('Food'),
                                    onTap: () {
                                      setState(() {
                                        catagoryController.text = 'Food';
                                      });
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.shopping_cart),
                                    title: Text('Shopping'),
                                    onTap: () {
                                      setState(() {
                                        catagoryController.text = 'Shopping';
                                      });
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.airplanemode_active_outlined),
                                    title: Text('Traveling'),
                                    onTap: () {
                                      setState(() {
                                        catagoryController.text = 'Traveling';
                                      });
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.savings),
                                    title: Text('Saving'),
                                    onTap: () {
                                      setState(() {
                                        catagoryController.text = 'Saving';
                                      });
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.miscellaneous_services),
                                    title: Text('Miscellaneous Expenses'),
                                    onTap: () {
                                      setState(() {
                                        catagoryController.text = 'Miscellaneous Expenses';
                                      });
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
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
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Category',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.0,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16.0),
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
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Note',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.0,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16.0),

                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  onTap: () async {
                     DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                     dateController.text = DateFormat('yyyy/MM/dd').format(picked);
                      selectDate = picked;
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
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Today',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16.0,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24.0),
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFDA44bb),
                          Color(0xFF8921aa),
                        ],
                      ),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 28.0),
                      onPressed: () {
                        // Your onPressed function
                      },
                      child: Text(
                        "SAVE",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
