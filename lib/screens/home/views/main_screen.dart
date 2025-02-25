import 'package:expenses_tracker/screens/home/views/popup.dart';
import 'package:expenses_tracker/screens/home/views/profile.dart';
import 'package:expenses_tracker/screens/home/views/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../stats/card.dart';
import '../../stats/extra_widget.dart';
import '../../stats/limitsetter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab = 0; // 0: ALL, 1: Income, 2: Expenses
  int _currentLimit = 0;

  @override
  void initState() {
    super.initState();
    _loadLimitAndCheckExpenses();
  }

  /// Load the limit from Firestore and check expenses
  Future<void> _loadLimitAndCheckExpenses() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      DocumentSnapshot limitSnapshot = await FirebaseFirestore.instance
          .collection('limits')
          .doc(userId)
          .get();

      if (limitSnapshot.exists) {
        int limit = limitSnapshot['expense_limit'] ?? 0;

        setState(() {
          _currentLimit = limit;
        });

        double totalExpenses = await getTotalAmount('expenses');

        if (totalExpenses > limit) {
          LimitExceededPopup.show(
              context, 'Total Expenses', totalExpenses.toInt());
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading limit or expenses: $e')),
      );
    }
  }

  /// Get the total amount for a collection (e.g., income or expenses)
  Future<double> getTotalAmount(String collection) async {
    double total = 0.0;
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in snapshot.docs) {
      total += doc['amount'];
    }
    return total;
  }

  Future<Map<String, dynamic>> getUserData() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getTransactionDetails(String collection) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .get();

    List<Map<String, dynamic>> transactions = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return {
        'id': doc.id,
        'category': data['category'] ?? 'Unknown',
        'note': data['note'] ?? '',
        'date': data['createdAt'] ?? Timestamp.now(),
        'amount': data['amount'] ?? 0.0,
        'type': collection,
      };
    }).toList();

    transactions.sort((a, b) {
      DateTime dateA = (a['date'] as Timestamp).toDate();
      DateTime dateB = (b['date'] as Timestamp).toDate();
      return dateB.compareTo(dateA);
    });

    return transactions;
  }

  Future<void> deleteTransaction(String collection, String docId) async {
    try {
      await FirebaseFirestore.instance.collection(collection).doc(docId).delete();
      setState(() {}); // Refresh UI after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete transaction: $e')),
      );
    }
  }

  void _onTabChange(int newTab) {
    setState(() {
      _selectedTab = newTab;
    });
  }

  /// Add a new transaction to Firestore (either income or expenses)
  Future<void> addTransaction(String collection, Map<String, dynamic> transactionData) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('User not authenticated');

      // Add the transaction to Firestore
      await FirebaseFirestore.instance.collection(collection).add(transactionData);

      // Reload the entire screen
      Get.off(() => const MainScreen());
      Get.to(() => const MainScreen());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add transaction: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadLimitAndCheckExpenses();
          },
          child: FutureBuilder(
            future: Future.wait([
              getUserData(),
              getTotalAmount('income'),
              getTotalAmount('expenses'),
              getTransactionDetails('income'),
              getTransactionDetails('expenses')
            ]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                var userData = snapshot.data![0] as Map<String, dynamic>;
                double incomeTotal = snapshot.data![1] as double;
                double expenseTotal = snapshot.data![2] as double;
                List<Map<String, dynamic>> incomeDetails = snapshot.data![3];
                List<Map<String, dynamic>> expenseDetails = snapshot.data![4];

                List<Map<String, dynamic>> allDetails = [
                  ...incomeDetails,
                  ...expenseDetails
                ];

                List<Map<String, dynamic>> selectedDetails =
                _selectedTab == 0
                    ? allDetails
                    : _selectedTab == 1
                    ? incomeDetails
                    : expenseDetails;

                return ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 40),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Welcome,',
                                    style:
                                    TextStyle(color: Colors.grey.shade700)),
                                Text(userData['username'],
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Get.to(() => const LimitSetter()),
                              icon: const Icon(Icons.notifications),
                            ),
                            IconButton(
                              onPressed: () => Get.to(() => const SearchScreen()),
                              icon: const Icon(Icons.search),
                            ),
                            IconButton(
                              onPressed: () => Get.to(() => ProfileScreen()),
                              icon: const Icon(Icons.settings),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    BalanceCard(
                        incomeTotal: incomeTotal, expenseTotal: expenseTotal),
                    const SizedBox(height: 16),
                    ExtraWidget(
                      selectedTab: _selectedTab,
                      onTabChange: _onTabChange,
                      selectedDetails: selectedDetails,
                      deleteTransaction: deleteTransaction,
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
