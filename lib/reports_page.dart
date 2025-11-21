// lib/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("داشبورد تحلیلی"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ۱. کارت‌های خلاصه
            Row(
              children: [
                Expanded(child: _infoCard("کل درآمد ماه", "۲۳ میلیون", Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _infoCard("کل هزینه ماه", "۸٫۲ میلیون", Colors.red)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _infoCard("پس‌انداز ماه", "۱۴٫۸ میلیون", Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _infoCard("بیشترین هزینه", "دیجی‌کالا", Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),

            // ۲. نمودار دایره‌ای
            const Text("تقسیم‌بندی هزینه‌ها", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(value: 45, color: Colors.green, title: "درآمد\n۴۵٪", radius: 70, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(value: 30, color: Colors.red, title: "حمل‌ونقل\n۳۰٪", radius: 60, titleStyle: const TextStyle(color: Colors.white)),
                    PieChartSectionData(value: 15, color: Colors.orange, title: "غذا\n۱۵٪", radius: 60, titleStyle: const TextStyle(color: Colors.white)),
                    PieChartSectionData(value: 10, color: Colors.purple, title: "سرگرمی\n۱۰٪", radius: 60, titleStyle: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ۳. نمودار میله‌ای روند ۶ ماهه
            const Text("روند ۶ ماه اخیر", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 25,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                      const months = ['مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'];
                      return Text(months[value.toInt()]);
                    })),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  barGroups: [
                    _barGroup(0, 18, 6),
                    _barGroup(1, 20, 8),
                    _barGroup(2, 23, 8.2),
                    _barGroup(3, 19, 10),
                    _barGroup(4, 22, 9),
                    _barGroup(5, 23, 8.2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: income, color: Colors.green, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
        BarChartRodData(toY: expense, color: Colors.red, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
      ],
    );
  }

  Widget _infoCard(String title, String value, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}