// lib/transactions_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  // لیست نمونه تراکنش‌ها (بعداً واقعی می‌کنیم)
  final List<Map<String, dynamic>> transactions = const [
    {
      'title': 'دریافت حقوق',
      'amount': 18000000,
      'type': 'income', // income = درآمد, expense = هزینه
      'date': '1404/08/28',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
    },
    {
      'title': 'خرید از دیجی‌کالا',
      'amount': 1250000,
      'type': 'expense',
      'date': '1404/08/27',
      'icon': Icons.shopping_cart,
      'color': Colors.red,
    },
    {
      'title': 'فریلنس پروژه',
      'amount': 5000000,
      'type': 'income',
      'date': '1404/08/25',
      'icon': Icons.code,
      'color': Colors.green,
    },
    {
      'title': 'قهوه با دوستان',
      'amount': 185000,
      'type': 'expense',
      'date': '1404/08/24',
      'icon': Icons.coffee,
      'color': Colors.red,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // محاسبه جمع درآمد و هزینه
    int totalIncome = transactions
        .where((t) => t['type'] == 'income')
        .fold(0, (sum, t) => sum + t['amount'] as int);

    int totalExpense = transactions
        .where((t) => t['type'] == 'expense')
        .fold(0, (sum, t) => sum + t['amount'] as int);

    return Scaffold(
      appBar: AppBar(
        title: const Text("تراکنش‌های مالی"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // کارت خلاصه ماه
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.indigo, Colors.indigoAccent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("درآمد کل", totalIncome, Colors.green),
                _summaryItem("هزینه کل", totalExpense, Colors.red),
                _summaryItem("موجودی", totalIncome - totalExpense, Colors.white),
              ],
            ),
          ),

          // لیست تراکنش‌ها
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t['color'].withOpacity(0.2),
                      child: Icon(t['icon'], color: t['color']),
                    ),
                    title: Text(t['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(t['date']),
                    trailing: Text(
                      NumberFormat.currency(locale: 'fa', symbol: '').format(t['amount']),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: t['type'] == 'income' ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // دکمه اضافه کردن تراکنش
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("فرم اضافه کردن تراکنش باز شد!")),
          );
        },
      ),
    );
  }

  Widget _summaryItem(String label, int amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          NumberFormat.compactCurrency(locale: 'fa', symbol: 'ت').format(amount),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }
}