import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddExpense extends StatelessWidget {
  const AddExpense({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(


        appBar: AppBar(
        ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Add Expenses",style: TextStyle(fontSize: 22),),
              TextFormField(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Rs.',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
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
                  hintText: 'Enter amount',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 16.0),
              TextFormField(),
              SizedBox(height: 16.0),
              TextFormField(),
              SizedBox(height: 16.0),
              TextButton(onPressed: (){}, child: Text("Save")),
            ],
          ),
        ),
      ),
    );
  }
}
