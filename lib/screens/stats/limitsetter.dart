import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LimitSetter extends StatefulWidget {
  const LimitSetter({Key? key}) : super(key: key);

  @override
  State<LimitSetter> createState() => _LimitSetterState();
}

class _LimitSetterState extends State<LimitSetter> {
  final TextEditingController _limitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLimit();
  }

  Future<void> _loadLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int limit = prefs.getInt('expense_limit') ?? 0;
    setState(() {
      _limitController.text = limit.toString();
    });
  }

  Future<void> _saveLimit() async {
    int? newLimit = int.tryParse(_limitController.text);
    if (newLimit != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('expense_limit', newLimit);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense limit updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Expense Limit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _limitController,
              decoration: const InputDecoration(labelText: 'Enter Expense Limit'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveLimit,
              child: const Text('Save Limit'),
            ),
          ],
        ),
      ),
    );
  }
}
