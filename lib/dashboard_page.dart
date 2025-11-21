// lib/dashboard_page.dart
import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("داشبورد"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _bigCard("موجودی کل", "۱۲,۷۵۰,۰۰۰ تومان", Colors.indigo),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _bigCard("درآمد ماه", "۲۳ میلیون", Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _bigCard("هزینه ماه", "۸٫۲ میلیون", Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _bigCard("پس‌انداز", "۱۴٫۸ میلیون", Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _bigCard("هدف بودجه", "۸۰٪", Colors.orange)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigCard(String title, String value, Color color) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}