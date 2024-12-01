import 'package:expenses_tracker/screens/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartScreen extends StatefulWidget {
  const PieChartScreen({super.key});

  @override
  _PieChartScreenState createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? userId; // Current user ID
  double totalIncome = 0;
  double totalExpense = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: const Text('Income vs Expense'),
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : totalIncome == 0 && totalExpense == 0
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Income vs Expense",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 300,
                width: 300,
                child: PieChart(
                  key: ValueKey('$totalIncome-$totalExpense'), // PieChart state maintained
                  PieChartData(
                    sections: _generatePieChartSections(),
                    centerSpaceRadius: 60,
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Total Income: Rs. ${totalIncome.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
            Text(
              "Total Expense: Rs. ${totalExpense.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                future: _fetchNotes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                    return const Center(child: Text("No notes found."));
                  }

                  final notes = snapshot.data as List<Map<String, dynamic>>;
                  return ListView.separated(
                    itemCount: notes.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final isIncome = note['type'] == 'income';

                      return ListTile(
                        key: ValueKey(note['note']),
                        tileColor: isIncome ? Colors.green[50] : Colors.red[50],
                        title: Text(
                          note['note'],
                          style: TextStyle(color: isIncome ? Colors.green : Colors.red),
                        ),
                        subtitle: Text(
                          "Category: ${note['category']}\nAmount: Rs. ${note['amount'].toStringAsFixed(2)}",
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchNotes() async {
    if (userId == null) return [];

    List<Map<String, dynamic>> notes = [];

    try {
      final incomeQuery = await _firestore
          .collection('income')
          .where('userId', isEqualTo: userId)
          .get();
      final expenseQuery = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in incomeQuery.docs) {
        notes.add({
          'note': doc['note'],
          'amount': (doc['amount'] as num).toDouble(),
          'category': doc['category'],
          'type': 'income',
        });
      }
      for (var doc in expenseQuery.docs) {
        notes.add({
          'note': doc['note'],
          'amount': (doc['amount'] as num).toDouble(),
          'category': doc['category'],
          'type': 'expense',
        });
      }
    } catch (e) {
      debugPrint('Error fetching notes: $e');
    }

    return notes;
  }

  List<PieChartSectionData> _generatePieChartSections() {
    final total = totalIncome + totalExpense;
    if (total == 0) return [];

    return [
      PieChartSectionData(
        color: Colors.green,
        value: totalIncome,
        title: "${((totalIncome / total) * 100).toStringAsFixed(1)}%",
        radius: 90,
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        showTitle: true,
      ),
      PieChartSectionData(
        color: Colors.red,
        value: totalExpense,
        title: "${((totalExpense / total) * 100).toStringAsFixed(1)}%",
        radius: 90,
        titleStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        showTitle: true,
      ),
    ];
  }
}
