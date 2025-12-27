// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/payment_reminder_controller.dart';
import 'add_transaction_screen.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'payments_reminder_screen.dart';
import 'goals_screen.dart';
import 'reports_screen.dart';
import 'package:finance_manager/presentation/controllers/theme_controller.dart';
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TransactionController controller = Get.find<TransactionController>();
  final PaymentReminderController paymentController = Get.find<PaymentReminderController>();

  // ========== Helper Methods ==========
  
  String _formatCurrency(double amount) {
    return NumberFormat.decimalPattern('fa').format(amount);
  }
  
  Color _getTransactionColor(bool isIncome) {
    return isIncome ? Colors.green : Colors.red;
  }
  
  IconData _getTransactionIcon(bool isIncome) {
    return isIncome ? Icons.arrow_downward : Icons.arrow_upward;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }
  
  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} سال پیش';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ماه پیش';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} روز پیش';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعت پیش';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقیقه پیش';
    } else {
      return 'همین الان';
    }
  }

  // ========== UI Widgets ==========
  
  Widget _buildBalanceHeader() {
    return Obx(() {
      final balance = controller.balance.value;
      final monthlyBalance = controller.monthlyBalance;
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade800,
              Colors.indigo.shade800,
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE', 'fa_IR').format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      DateFormat('d MMMM', 'fa_IR').format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, size: 16, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'مالی',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'موجودی کل',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatCurrency(balance)} تومان',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'درآمد',
                  controller.totalIncome.value,
                  Colors.green,
                  Icons.arrow_upward,
                ),
                _buildStatCard(
                  'هزینه',
                  controller.totalExpense.value,
                  Colors.red,
                  Icons.arrow_downward,
                ),
                _buildStatCard(
                  'مانده',
                  monthlyBalance,
                  monthlyBalance >= 0 ? Colors.green : Colors.red,
                  monthlyBalance >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildStatCard(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        Text(
          _formatCurrency(amount.abs()),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingPayments() {
    return Obx(() {
      final unpaidPayments = paymentController.payments
          .where((p) => !p.isPaid)
          .toList();
      
      final upcomingPayments = unpaidPayments
          .where((p) => p.dueDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
          .toList()
          .take(3)
          .toList();
      
      if (upcomingPayments.isEmpty) return const SizedBox();
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'پرداخت‌های نزدیک',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.to(() => PaymentsReminderScreen()),
                  child: Text(
                    'مشاهده همه',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: upcomingPayments.map((payment) => _buildPaymentItem(payment)).toList(),
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildPaymentItem(PaymentReminder payment) {
    final now = DateTime.now();
    final dueDate = payment.dueDate;
    final daysLeft = dueDate.difference(now).inDays;
    
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    if (daysLeft < 0) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'دیر شده';
    } else if (daysLeft == 0) {
      statusColor = Colors.orange;
      statusIcon = Icons.today;
      statusText = 'امروز';
    } else if (daysLeft <= 3) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = '$daysLeft روز دیگر';
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.calendar_today;
      statusText = '$daysLeft روز دیگر';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  payment.category,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatCurrency(payment.amount)} تومان',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsProgress() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'پیشرفت اهداف',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.purple.shade700),
                onPressed: () {
                  // به سادگی به صفحه اهداف برو بدون Binding پیچیده
                  Get.to(() => GoalsScreen());
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'برای مشاهده و مدیریت اهداف مالی خود کلیک کنید',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentTransactions() {
    return Obx(() {
      final recent = controller.recentTransactions;
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'آخرین تراکنش‌ها',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => SearchScreen()),
                  child: const Row(
                    children: [
                      Text(
                        'همه',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_left, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            
            if (recent.isEmpty) ...[
              _buildEmptyState(),
            ] else ...[
              Column(
                children: recent.take(4).map((transaction) => _buildTransactionItem(transaction)).toList(),
              ),
            ],
          ],
        ),
      );
    });
  }
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'هنوز تراکنشی ثبت نکرده‌اید',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => AddTransactionScreen()),
            icon: const Icon(Icons.add),
            label: const Text('شروع کنید'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionItem(dynamic transaction) {
    final isIncome = transaction.isIncome ?? false;
    final title = transaction.title ?? 'بدون عنوان';
    final category = transaction.category ?? 'سایر';
    final amount = transaction.amount ?? 0;
    final date = transaction.date ?? DateTime.now();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTransactionDetails(transaction),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$category • ${_getTimeAgo(date)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isIncome ? '+${_formatCurrency(amount)}' : '-${_formatCurrency(amount)}',
                      style: TextStyle(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showTransactionDetails(dynamic transaction) {
    final isIncome = transaction.isIncome ?? false;
    final title = transaction.title ?? 'بدون عنوان';
    final category = transaction.category ?? 'سایر';
    final amount = transaction.amount ?? 0;
    final date = transaction.date ?? DateTime.now();
    final description = transaction.description;
    
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTransactionColor(isIncome).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTransactionIcon(isIncome),
                    color: _getTransactionColor(isIncome),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  isIncome ? '+${_formatCurrency(amount)}' : '-${_formatCurrency(amount)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTransactionColor(isIncome),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildDetailRow('📅 تاریخ', _formatDate(date)),
            _buildDetailRow('🕒 زمان', DateFormat('HH:mm').format(date)),
            _buildDetailRow('🏷️ نوع', isIncome ? 'درآمد' : 'هزینه'),
            
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '📝 توضیحات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(description),
            ],
            
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('بستن'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.to(() => AddTransactionScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('ویرایش'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.deleteTransaction(transaction.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('حذف'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'مدیریت مالی',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.blue.shade700),
            onPressed: () => Get.to(() => SearchScreen()),
            tooltip: 'جستجو',
          ),
          IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.blue.shade700),
            onPressed: () => Get.to(() => const ReportsScreen()),
            tooltip: 'گزارش‌ها',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          controller.update();
          paymentController.update();
        },
        color: Colors.blue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildBalanceHeader(),
              const SizedBox(height: 20),
              _buildUpcomingPayments(),
              _buildGoalsProgress(),
              _buildRecentTransactions(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () => Get.to(() => AddTransactionScreen()),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add, size: 24),
          label: const Text('تراکنش جدید'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  break;
                case 1:
                  Get.to(() => PaymentsReminderScreen());
                  break;
                case 2:
                  Get.to(() => GoalsScreen());
                  break;
                case 3:
                  Get.to(() => const SettingsScreen());
                  break;
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue.shade700,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            unselectedLabelStyle: const TextStyle(fontSize: 11),
            elevation: 10,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_filled, size: 22),
                ),
                label: 'خانه',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_outlined, size: 24),
                activeIcon: Icon(Icons.notifications_active, size: 24),
                label: 'یادآوری‌ها',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.flag_outlined, size: 24),
                activeIcon: Icon(Icons.flag, size: 24),
                label: 'اهداف',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined, size: 24),
                activeIcon: Icon(Icons.settings, size: 24),
                label: 'تنظیمات',
              ),
            ],
          ),
        ),
      ),
    );
  }
}