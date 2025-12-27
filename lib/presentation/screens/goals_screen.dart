// lib/presentation/screens/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/savings_goals_controller.dart';

class GoalsScreen extends StatelessWidget {
  GoalsScreen({Key? key}) : super(key: key);

  final SavingsGoalsController controller = Get.find<SavingsGoalsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎯 اهداف پس‌انداز'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadGoals(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flag, size: 100, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'هنوز هدفی ندارید',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _showAddGoalDialog(),
                  child: const Text('ایجاد اولین هدف'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // آمار سریع
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('اهداف', controller.goals.length.toString()),
                  _buildStatItem('فعال', controller.activeGoals.length.toString()),
                  _buildStatItem('تکمیل', controller.completedGoals.length.toString()),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.goals.length,
                itemBuilder: (context, index) {
                  final goal = controller.goals[index];
                  return _buildGoalCard(goal);
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final progress = controller.getProgress(goal);
    final daysLeft = controller.getDaysLeft(goal);
    final isCompleted = controller.isCompleted(goal);
    final color = controller.getColorFromHex(goal['color'] ?? '#2196F3');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Text(goal['icon'] ?? '💰'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal['name'] ?? 'بدون نام',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: color,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toStringAsFixed(1)}%'),
                Text('$daysLeft روز'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatCurrency(goal['currentAmount'])),
                Text(_formatCurrency(goal['targetAmount'])),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(goal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: Get.context!,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('افزودن هدف جدید'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'نام هدف',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'مبلغ هدف (تومان)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      title: const Text('تاریخ سررسید'),
                      subtitle: Text(_formatDate(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('انصراف'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final amountText = amountController.text.trim();

                    if (name.isEmpty) {
                      Get.snackbar('خطا', 'لطفاً نام هدف را وارد کنید');
                      return;
                    }

                    final amount = double.tryParse(amountText);
                    if (amount == null || amount <= 0) {
                      Get.snackbar('خطا', 'لطفاً مبلغ معتبر وارد کنید');
                      return;
                    }

                    controller.addGoal(
                      name: name,
                      targetAmount: amount,
                      targetDate: selectedDate,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text('ایجاد'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(Map<String, dynamic> goal) {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف هدف'),
          content: Text('آیا از حذف "${goal['name']}" مطمئن هستید؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                controller.deleteGoal(goal['id']);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  String _formatCurrency(dynamic amount) {
    try {
      if (amount is num) {
        final formatter = NumberFormat.decimalPattern('fa');
        return '${formatter.format(amount)} تومان';
      }
      return '0 تومان';
    } catch (e) {
      return '0 تومان';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }
}