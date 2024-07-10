import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyChart extends StatefulWidget {
  const MyChart({super.key});

  @override
  State<MyChart> createState() => _MyChartState();
}

class _MyChartState extends State<MyChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BarChart(
          mainBarChart(),
        ),
      ),
    );
  }

  BarChartData mainBarChart() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 20,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              switch (value.toInt()) {
                case 0:
                  return const Text('One');
                case 1:
                  return const Text('Two');
                case 2:
                  return const Text('Three');
                case 3:
                  return const Text('Four');
                default:
                  return const Text('');
              }
            },
            reservedSize: 28,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString());
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: 8,
              color: Colors.lightBlueAccent,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 1,
          barRods: [
            BarChartRodData(
              toY: 10,
              color: Colors.lightBlueAccent,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 2,
          barRods: [
            BarChartRodData(
              toY: 14,
              color: Colors.lightBlueAccent,
            )
          ],
          showingTooltipIndicators: [0],
        ),
        BarChartGroupData(
          x: 3,
          barRods: [
            BarChartRodData(
              toY: 15,
              color: Colors.lightBlueAccent,
            )
          ],
          showingTooltipIndicators: [0],
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MyChart(),
  ));
}
