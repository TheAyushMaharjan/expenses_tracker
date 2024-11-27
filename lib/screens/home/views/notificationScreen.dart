import 'package:flutter/material.dart';
import 'notification_service.dart'; // Make sure to import the NotificationService

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {

  Future<Map<String, String>> _getSuggestions() async {
    // Get the current date or any selected date
    DateTime currentDate = DateTime.now();

    // Instantiate NotificationService and fetch the suggestions
    return await NotificationService().getExpenseIncomeComparison(currentDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _getSuggestions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // If there are suggestions
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: snapshot.data!.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  ),
                );
              }).toList(),
            );
          } else {
            // No suggestions
            return const Center(child: Text('No suggestions available.'));
          }
        },
      ),
    );
  }
}
