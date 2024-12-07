import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LimitSetter extends StatefulWidget {
  const LimitSetter({Key? key}) : super(key: key);

  @override
  State<LimitSetter> createState() => _LimitSetterState();
}

class _LimitSetterState extends State<LimitSetter> {
  final TextEditingController _limitController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid;
        });
        _loadLimit();
      } else {
        // Handle the case when no user is logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize user: $e')),
      );
    }
  }

  Future<void> _loadLimit() async {
    if (userId == null) return;
    try {
      DocumentSnapshot snapshot =
      await _firestore.collection('limits').doc(userId).get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int limit = data['expense_limit'] ?? 0;

        setState(() {
          _limitController.text = limit.toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load limit: $e')),
      );
    }
  }

  Future<void> _saveLimit() async {
    if (userId == null) return;
    int? newLimit = int.tryParse(_limitController.text);
    if (newLimit != null) {
      try {
        await _firestore.collection('limits').doc(userId).set(
          {'expense_limit': newLimit},
          SetOptions(merge: true),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense limit updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update limit: $e')),
        );
      }
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