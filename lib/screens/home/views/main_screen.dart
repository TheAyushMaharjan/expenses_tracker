import 'package:expenses_tracker/screens/home/views/profile.dart';
import 'package:expenses_tracker/screens/home/views/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../stats/card.dart';
import '../../stats/extra_widget.dart';
import 'notificationScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab = 0; // 0: ALL, 1: Income, 2: Expenses

  Future<Map<String, dynamic>> getUserData() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  Future<double> getTotalAmount(String collection) async {
    double total = 0.0;
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      throw Exception('User not authenticated');
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .where('userId', isEqualTo: userId) // Ensure we are only fetching the current user's data
        .get();

    for (var doc in snapshot.docs) {
      total += doc['amount'];
    }
    return total;
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
        'id': doc.id, // Document ID
        'category': data.containsKey('category') ? data['category'] : 'Unknown', // Handle missing field
        'note': data.containsKey('note') ? data['note'] : '', // Handle missing note
        'date': data.containsKey('createdAt') ? data['createdAt'] : Timestamp.now(),
        'amount': data.containsKey('amount') ? data['amount'] : 0.0,
        'type': collection,
      };
    }).toList();

    transactions.sort((a, b) {
      DateTime dateA = (a['date'] as Timestamp).toDate();
      DateTime dateB = (b['date'] as Timestamp).toDate();
      return dateB.compareTo(dateA); // Sort by recent date
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Trigger UI refresh by reloading data
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
                List<Map<String, dynamic>> incomeDetails =
                snapshot.data![3] as List<Map<String, dynamic>>;
                List<Map<String, dynamic>> expenseDetails =
                snapshot.data![4] as List<Map<String, dynamic>>;

                List<Map<String, dynamic>> allDetails = [
                  ...incomeDetails,
                  ...expenseDetails
                ];

                List<Map<String, dynamic>> selectedDetails;
                if (_selectedTab == 0) {
                  selectedDetails = allDetails;
                } else if (_selectedTab == 1) {
                  selectedDetails = incomeDetails;
                } else {
                  selectedDetails = expenseDetails;
                }

                return ListView(
                  children: [
                    // Header Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const Icon(Icons.person, color: Colors.white),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome,',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  userData['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.to(() => const());
                              },
                              icon: const Icon(Icons.notifications, color: Colors.grey),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.to(() => const SearchScreen());
                              },
                              icon: const Icon(Icons.search, color: Colors.grey),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.to(() => ProfileScreen());
                              },
                              icon: const Icon(Icons.settings, color: Colors.grey),
                            ),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    BalanceCard(
                      incomeTotal: incomeTotal,
                      expenseTotal: expenseTotal,
                    ),



                    const SizedBox(height: 16),
                    // ExtraWidget Section
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
