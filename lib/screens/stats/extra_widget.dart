import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExtraWidget extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChange;
  final List<Map<String, dynamic>> selectedDetails;
  final Function(String, String) deleteTransaction;
  // final int currentLimit; // Add the currentLimit property

  const ExtraWidget({
    Key? key,
    required this.selectedTab,
    required this.onTabChange,
    required this.selectedDetails,
    required this.deleteTransaction,
    // required this.currentLimit, // Pass the current limit value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Limit display at the top
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8.0),
        //   child: Row(
        //     children: [
        //       const Text(
        //         'Limit Set: ',
        //         style: TextStyle(fontWeight: FontWeight.bold),
        //       ),
        //       Text(
        //         'Rs. $currentLimit',
        //         style: const TextStyle(fontWeight: FontWeight.bold),
        //       ),
        //     ],
        //   ),
        // ),
        const SizedBox(height: 16),
        // Tab Section
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTabButton(context, 0, 'ALL'),
              _buildTabButton(context, 1, 'Income'),
              _buildTabButton(context, 2, 'Expenses'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between the items
          children: [
            Text(
              'Particular',
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
            Row(
              children: [
                Text(
                  'Credit/ ',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Debit',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Transaction List with Swipe-to-Delete
        ...selectedDetails.map(
              (transaction) => Dismissible(
            key: Key(transaction['id']),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Transaction'),
                  content: const Text(
                      'Are you sure you want to delete this transaction?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              deleteTransaction(
                  transaction['type'], transaction['id']);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${transaction['note']} (${transaction['category']})',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        (transaction['date'] as Timestamp)
                            .toDate()
                            .toString()
                            .split(' ')[0],
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Rs.${transaction['amount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: transaction['type'] == 'income'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(BuildContext context, int index, String label) {
    return GestureDetector(
      onTap: () => onTabChange(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: selectedTab == index
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selectedTab == index ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
