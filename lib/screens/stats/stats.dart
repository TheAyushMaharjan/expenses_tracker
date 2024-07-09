import 'package:expenses_tracker/screens/stats/chart.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
        child: Column(
          children: [
            Text('Transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),

            ),
            SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              // color: Colors.red,
            child: const MyChart(),

            )
          ],
        ),
      ),
    );
  }
}
