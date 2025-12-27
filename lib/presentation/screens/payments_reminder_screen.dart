// lib/presentation/screens/payments_reminder_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/payment_reminder_controller.dart';

class PaymentsReminderScreen extends StatelessWidget {
  PaymentsReminderScreen({super.key});

  final PaymentReminderController controller = Get.put(PaymentReminderController());

  // ========== Helper Methods ==========
  
  String _formatCurrency(double amount) {
    return NumberFormat.decimalPattern('fa').format(amount);
  }
  
  Color _getStatusColor(PaymentReminder payment) {
    if (payment.isPaid) return Colors.green;
    if (payment.dueDate.isBefore(DateTime.now())) return Colors.red;
    if (payment.dueDate.difference(DateTime.now()).inDays == 0) return Colors.orange;
    if (payment.dueDate.difference(DateTime.now()).inDays <= 3) return Colors.orange;
    return Colors.blue;
  }
  
  IconData _getStatusIcon(PaymentReminder payment) {
    if (payment.isPaid) return Icons.check_circle;
    if (payment.dueDate.isBefore(DateTime.now())) return Icons.warning;
    if (payment.dueDate.difference(DateTime.now()).inDays == 0) return Icons.today;
    if (payment.dueDate.difference(DateTime.now()).inDays <= 3) return Icons.schedule;
    return Icons.calendar_today;
  }
  
  String _getStatusText(PaymentReminder payment) {
    if (payment.isPaid) return 'پرداخت شده';
    if (payment.dueDate.isBefore(DateTime.now())) return 'دیر شده';
    if (payment.dueDate.difference(DateTime.now()).inDays == 0) return 'امروز';
    if (payment.dueDate.difference(DateTime.now()).inDays <= 3) {
      return '${payment.dueDate.difference(DateTime.now()).inDays} روز دیگر';
    }
    return '${payment.dueDate.difference(DateTime.now()).inDays} روز دیگر';
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }
  
  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // ========== UI Widgets ==========
  
  Widget _buildStatsHeader() {
    return Obx(() {
      final unpaidPayments = controller.payments.where((p) => !p.isPaid).toList();
      final overduePayments = unpaidPayments.where((p) => p.dueDate.isBefore(DateTime.now())).toList();
      final dueSoonPayments = unpaidPayments.where((p) => 
        p.dueDate.difference(DateTime.now()).inDays <= 3 && 
        p.dueDate.difference(DateTime.now()).inDays > 0
      ).toList();
      final totalDue = unpaidPayments.fold(0.0, (sum, payment) => sum + payment.amount);
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade700,
              Colors.red.shade700,
            ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
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
                    const Text(
                      'یادآوری پرداخت',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'مدیریت قبوض و سررسیدها',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
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
                  child: Text(
                    '${unpaidPayments.length} پرداخت',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'کل مبالغ معوق',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_formatCurrency(totalDue)} تومان',
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
                  'دیر شده',
                  overduePayments.length,
                  Colors.red,
                  Icons.warning,
                ),
                _buildStatCard(
                  'به زودی',
                  dueSoonPayments.length,
                  Colors.orange,
                  Icons.schedule,
                ),
                _buildStatCard(
                  'کل پرداخت',
                  unpaidPayments.length,
                  Colors.white,
                  Icons.payments,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
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
            color: Colors.white,
            fontSize: 11,
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final payments = controller.payments;
      
      if (payments.isEmpty) {
        return _buildEmptyState();
      }

      final unpaidPayments = payments.where((p) => !p.isPaid).toList();
      final paidPayments = payments.where((p) => p.isPaid).toList();
      
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (unpaidPayments.isNotEmpty) ...[
            _buildListSection('پرداخت‌های معوق', unpaidPayments.length),
            ...unpaidPayments.map((payment) => _buildPaymentItem(payment)).toList(),
          ],
          
          if (paidPayments.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildListSection('پرداخت‌های انجام شده', paidPayments.length),
            ...paidPayments.map((payment) => _buildPaymentItem(payment)).toList(),
          ],
        ],
      );
    });
  }
  
  Widget _buildListSection(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count مورد',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentItem(PaymentReminder payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(payment).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getStatusIcon(payment),
            color: _getStatusColor(payment),
            size: 24,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                payment.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(payment).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(payment),
                  width: 1,
                ),
              ),
              child: Text(
                _getStatusText(payment),
                style: TextStyle(
                  fontSize: 10,
                  color: _getStatusColor(payment),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payment.category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  _formatDate(payment.dueDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatCurrency(payment.amount)} تومان',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (payment.notes != null && payment.notes!.isNotEmpty)
                  Icon(
                    Icons.note,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
              ],
            ),
          ],
        ),
        trailing: payment.isPaid
            ? IconButton(
                icon: const Icon(Icons.check_box, color: Colors.green),
                onPressed: () => controller.togglePaid(payment.id),
              )
            : IconButton(
                icon: const Icon(Icons.check_box_outline_blank),
                onPressed: () => controller.togglePaid(payment.id),
              ),
        onTap: () => _showPaymentDetails(payment),
        onLongPress: () => _showActionMenu(payment),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'هنوز یادآوری پرداختی ثبت نکرده‌اید',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'با ثبت پرداخت‌های آینده، هیچ قسطی را فراموش نخواهید کرد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddPaymentDialog(),
              icon: const Icon(Icons.add_alert),
              label: const Text('اولین یادآوری را اضافه کنید'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== Action Methods ==========
  
  void _showAddPaymentDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    
    final categories = [
      'قبض برق',
      'قبض آب',
      'قبض گاز',
      'اجاره خانه',
      'قسط وام',
      'اشتراک اینترنت',
      'اشتراک موبایل',
      'بیمه',
      'مالیات',
      'حق عضویت',
      'سایر',
    ];
    
    Get.dialog(
      AlertDialog(
        title: const Text('➕ افزودن یادآوری پرداخت'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان پرداخت *',
                  hintText: 'مثال: قبض آب فروردین',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              
              const SizedBox(height: 12),
              
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'مبلغ (تومان) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'دسته‌بندی',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: categories[0],
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  categoryController.text = value ?? categories[0];
                },
              ),
              
              const SizedBox(height: 12),
              
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'توضیحات (اختیاری)',
                  hintText: 'شماره قبض یا توضیحات اضافی',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('تاریخ سررسید'),
                subtitle: Text(
                  '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || amountController.text.isEmpty) {
                Get.snackbar(
                  'خطا',
                  'عنوان و مبلغ را وارد کنید',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              try {
                final amount = double.parse(amountController.text);
                if (amount <= 0) {
                  Get.snackbar(
                    'خطا',
                    'مبلغ باید مثبت باشد',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                
                final payment = PaymentReminder(
                  title: titleController.text,
                  amount: amount,
                  dueDate: selectedDate,
                  category: categoryController.text.isNotEmpty ? categoryController.text : categories[0],
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );
                
                controller.addPayment(payment);
                Get.back();
              } catch (e) {
                Get.snackbar(
                  'خطا',
                  'لطفاً اعداد معتبر وارد کنید',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  
  void _showPaymentDetails(PaymentReminder payment) {
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
        child: SingleChildScrollView(
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
                      color: _getStatusColor(payment).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(payment),
                      color: _getStatusColor(payment),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          payment.category,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildDetailRow('💰 مبلغ', '${_formatCurrency(payment.amount)} تومان'),
              _buildDetailRow('📅 تاریخ سررسید', _formatDate(payment.dueDate)),
              _buildDetailRow('🕒 زمان', _formatTime(payment.dueDate)),
              _buildDetailRow('🏷️ وضعیت', _getStatusText(payment)),
              _buildDetailRow('📝 تاریخ ایجاد', _formatDate(payment.createdAt)),
              
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  '📋 توضیحات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(payment.notes!),
                ),
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
                        _showEditPaymentDialog(payment);
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
                        controller.togglePaid(payment.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: payment.isPaid ? Colors.grey : Colors.green,
                      ),
                      child: Text(payment.isPaid ? 'بازگشت به معوق' : 'علامت‌گذاری'),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
            ],
          ),
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
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showEditPaymentDialog(PaymentReminder payment) {
    final titleController = TextEditingController(text: payment.title);
    final amountController = TextEditingController(text: payment.amount.toString());
    final categoryController = TextEditingController(text: payment.category);
    final notesController = TextEditingController(text: payment.notes ?? '');
    DateTime selectedDate = payment.dueDate;
    
    final categories = [
      'قبض برق',
      'قبض آب',
      'قبض گاز',
      'اجاره خانه',
      'قسط وام',
      'اشتراک اینترنت',
      'اشتراک موبایل',
      'بیمه',
      'مالیات',
      'حق عضویت',
      'سایر',
    ];
    
    Get.dialog(
      AlertDialog(
        title: const Text('✏️ ویرایش یادآوری پرداخت'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان پرداخت',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              
              const SizedBox(height: 12),
              
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'مبلغ (تومان)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              
              const SizedBox(height: 12),
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'دسته‌بندی',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: payment.category,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  categoryController.text = value ?? payment.category;
                },
              ),
              
              const SizedBox(height: 12),
              
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'توضیحات',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('تاریخ سررسید'),
                subtitle: Text(
                  '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: Get.context!,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) {
                    selectedDate = picked;
                  }
                },
              ),
              
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: const Text('پرداخت شده'),
                value: payment.isPaid,
                onChanged: (value) {
                  // Update will be handled in save
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || amountController.text.isEmpty) {
                Get.snackbar(
                  'خطا',
                  'عنوان و مبلغ را وارد کنید',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              
              try {
                final amount = double.parse(amountController.text);
                if (amount <= 0) {
                  Get.snackbar(
                    'خطا',
                    'مبلغ باید مثبت باشد',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }
                
                final updatedPayment = payment.copyWith(
                  title: titleController.text,
                  amount: amount,
                  dueDate: selectedDate,
                  category: categoryController.text,
                  notes: notesController.text.isNotEmpty ? notesController.text : null,
                );
                
                controller.updatePayment(updatedPayment);
                Get.back();
              } catch (e) {
                Get.snackbar(
                  'خطا',
                  'لطفاً اعداد معتبر وارد کنید',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('ذخیره تغییرات'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
  
  void _showActionMenu(PaymentReminder payment) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                payment.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_formatCurrency(payment.amount)} تومان - ${_formatDate(payment.dueDate)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('ویرایش'),
                onTap: () {
                  Get.back();
                  _showEditPaymentDialog(payment);
                },
              ),
              
              ListTile(
                leading: Icon(
                  payment.isPaid ? Icons.undo : Icons.check_circle,
                  color: payment.isPaid ? Colors.grey : Colors.green,
                ),
                title: Text(payment.isPaid ? 'بازگشت به معوق' : 'علامت‌گذاری به عنوان پرداخت شده'),
                onTap: () {
                  Get.back();
                  controller.togglePaid(payment.id);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.orange),
                title: const Text('کپی کردن'),
                onTap: () {
                  Get.back();
                  _copyPayment(payment);
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف'),
                onTap: () {
                  Get.back();
                  _showDeleteDialog(payment);
                },
              ),
              
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('انصراف'),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  void _copyPayment(PaymentReminder payment) {
    final newPayment = payment.copyWith(
      id: null, // New ID will be generated
      title: '${payment.title} (کپی)',
      dueDate: payment.dueDate.add(const Duration(days: 30)),
      isPaid: false,
    );
    
    controller.addPayment(newPayment);
  }
  
  void _showDeleteDialog(PaymentReminder payment) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('حذف یادآوری پرداخت'),
          ],
        ),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید "${payment.title}" را حذف کنید؟\nاین عمل قابل بازگشت نیست.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deletePayment(payment.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
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
          '📅 یادآوری پرداخت',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.orange.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(),
            tooltip: 'فیلتر',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'جستجو',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
                controller.payments.refresh();
              },
              child: _buildPaymentList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddPaymentDialog(),
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_alert),
          label: const Text('یادآوری جدید'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
      ),
    );
  }
  
  void _showFilterDialog() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'فیلتر پرداخت‌ها',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              ListTile(
                leading: const Icon(Icons.all_inclusive, color: Colors.grey),
                title: const Text('همه پرداخت‌ها'),
                trailing: const Icon(Icons.check),
                onTap: () => Get.back(),
              ),
              
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('دیر شده'),
                onTap: () => Get.back(),
              ),
              
              ListTile(
                leading: const Icon(Icons.today, color: Colors.orange),
                title: const Text('امروز'),
                onTap: () => Get.back(),
              ),
              
              ListTile(
                leading: const Icon(Icons.schedule, color: Colors.orange),
                title: const Text('به زودی (تا ۳ روز)'),
                onTap: () => Get.back(),
              ),
              
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('پرداخت شده'),
                onTap: () => Get.back(),
              ),
              
              const SizedBox(height: 20),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text('اعمال فیلتر'),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSearchDialog() {
    final searchController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: const Text('🔍 جستجوی پرداخت'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'جستجو در عنوان، دسته‌بندی یا توضیحات',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement search functionality here
              Get.back();
            },
            child: const Text('جستجو'),
          ),
        ],
      ),
    );
  }
}