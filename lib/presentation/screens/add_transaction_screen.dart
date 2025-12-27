// presentation/screens/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../../data/models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TransactionController _controller = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // State variables
  String _transactionType = 'expense'; // 'income' یا 'expense'
  String _selectedCategory = 'خوراک';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String _lastValidatedAmount = '';
  
  // Categories
  static const List<String> _expenseCategories = [
    'خوراک', 'حمل‌ونقل', 'مسکن', 'تفریح',
    'سلامت', 'آموزش', 'خرید', 'سایر'
  ];
  
  static const List<String> _incomeCategories = [
    'حقوق', 'فروش', 'سود سرمایه‌گذاری', 
    'هدیه', 'سایر درآمدها'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ==================== Helper Methods ====================
  
  /// تبدیل اعداد فارسی/عربی به انگلیسی
  String _convertToEnglishNumbers(String text) {
    const Map<String, String> numberMap = {
      '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
      '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };
    
    return text
        .split('')
        .map((char) => numberMap[char] ?? char)
        .join('')
        .replaceAll(',', '')
        .replaceAll(' ', '');
  }

  /// فرمت کردن مبلغ برای نمایش
  String _formatCurrency(double amount) {
    return NumberFormat.decimalPattern('fa').format(amount);
  }

  /// انتخاب تاریخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('fa', 'IR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  /// اعتبارسنجی فرم
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;
    
    final rawAmount = _convertToEnglishNumbers(_amountController.text);
    if (rawAmount == _lastValidatedAmount) return true;
    
    _lastValidatedAmount = rawAmount;
    final amount = double.tryParse(rawAmount);
    
    // اعتبارسنجی مبلغ
    if (amount == null || amount <= 0) {
      _showErrorSnackbar('مبلغ نامعتبر', 'لطفاً مبلغ معتبر وارد کنید');
      return false;
    }
    
    // اعتبارسنجی موجودی برای هزینه
    if (_transactionType == 'expense' && amount > _controller.balance.value) {
      _showInsufficientBalanceDialog(amount);
      return false;
    }
    
    return true;
  }

  /// نمایش خطا
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      '❌ $title',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// دیالوگ موجودی ناکافی
  void _showInsufficientBalanceDialog(double requestedAmount) {
    final currentBalance = _controller.balance.value;
    final shortage = requestedAmount - currentBalance;
    
    Get.dialog(
      AlertDialog(
        title: const Text('💰 موجودی ناکافی'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• موجودی فعلی: ${_formatCurrency(currentBalance)} تومان'),
            const SizedBox(height: 8),
            Text('• مبلغ درخواستی: ${_formatCurrency(requestedAmount)} تومان'),
            const SizedBox(height: 8),
            Text(
              '• کمبود: ${_formatCurrency(shortage)} تومان',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'لطفاً مبلغ کمتری وارد کنید یا درآمد اضافه کنید.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('متوجه شدم'),
          ),
        ],
      ),
    );
  }

  /// دیالوگ تأیید نهایی
  Future<bool> _showConfirmationDialog() async {
    final amount = double.tryParse(
      _convertToEnglishNumbers(_amountController.text)
    ) ?? 0;
    
    return await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          _transactionType == 'income' ? '📥 ثبت درآمد' : '📤 ثبت هزینه',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConfirmationRow('عنوان:', _titleController.text),
              _buildConfirmationRow('مبلغ:', '${_formatCurrency(amount)} تومان'),
              _buildConfirmationRow('دسته‌بندی:', _selectedCategory),
              _buildConfirmationRow('تاریخ:', 
                DateFormat('yyyy/MM/dd').format(_selectedDate)),
              if (_descriptionController.text.isNotEmpty)
                _buildConfirmationRow('توضیحات:', _descriptionController.text),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('لغو', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _transactionType == 'income' 
                  ? Colors.green 
                  : Colors.blue,
            ),
            child: const Text('تأیید و ذخیره', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// ذخیره تراکنش
  Future<void> _saveTransaction() async {
    if (!_validateForm()) return;
    
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;
    
    setState(() => _isLoading = true);
    
    try {
      final amount = double.parse(
        _convertToEnglishNumbers(_amountController.text)
      );
      
      final transaction = Transaction(
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        type: _transactionType,
        date: _selectedDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      
      _controller.addTransaction(transaction);
      
      Get.snackbar(
        _transactionType == 'income' ? '✅ درآمد ثبت شد' : '💸 هزینه ثبت شد',
        'تراکنش با موفقیت ذخیره شد',
        backgroundColor: _transactionType == 'income' 
            ? Colors.green 
            : Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.back(result: true);
      
    } catch (e) {
      _showErrorSnackbar('خطای سیستمی', 'خطا در ذخیره تراکنش: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==================== UI Widgets ====================
  
  /// دکمه نوع تراکنش
  Widget _buildTypeSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(child: _buildTypeButton('درآمد', 'income', Icons.arrow_downward)),
            const SizedBox(width: 8),
            Expanded(child: _buildTypeButton('هزینه', 'expense', Icons.arrow_upward)),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String type, IconData icon) {
    final isSelected = _transactionType == type;
    final color = type == 'income' ? Colors.green : Colors.blue;
    
    return InkWell(
      onTap: () {
        setState(() {
          _transactionType = type;
          _selectedCategory = type == 'income' 
              ? _incomeCategories.first 
              : _expenseCategories.first;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// دسته‌بندی‌ها
  Widget _buildCategorySelector() {
    final categories = _transactionType == 'income' 
        ? _incomeCategories 
        : _expenseCategories;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 دسته‌بندی',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                  selectedColor: _transactionType == 'income'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected 
                        ? (_transactionType == 'income' ? Colors.green : Colors.blue)
                        : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? (_transactionType == 'income' ? Colors.green : Colors.blue)
                          : Colors.grey[300]!,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// نمایش موجودی
  Widget _buildBalanceInfo() {
    return Obx(() {
      final balance = _controller.balance.value;
      final rawAmount = _convertToEnglishNumbers(_amountController.text);
      final amount = double.tryParse(rawAmount) ?? 0;
      
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _transactionType == 'income' ? '💰 موجودی فعلی' : '💳 موجودی قابل برداشت',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_formatCurrency(balance)} تومان',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              if (_transactionType == 'expense' && amount > 0) ...[
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📊 پس از این تراکنش:',
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      '${_formatCurrency(balance - amount)} تومان',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: (balance - amount) < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ==================== Main Build ====================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('➕ ثبت تراکنش جدید'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _saveTransaction,
              tooltip: 'ذخیره',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('در حال ذخیره تراکنش...'),
                ],
              ),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نوع تراکنش
                      _buildTypeSelector(),
                      const SizedBox(height: 24),
                      
                      // عنوان
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: '📝 عنوان تراکنش',
                          prefixIcon: const Icon(Icons.short_text),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً عنوان وارد کنید';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // مبلغ
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '💰 مبلغ (تومان)',
                          prefixIcon: const Icon(Icons.currency_exchange),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          suffixText: 'تومان',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً مبلغ وارد کنید';
                          }
                          final converted = _convertToEnglishNumbers(value);
                          if (double.tryParse(converted) == null) {
                            return 'مبلغ نامعتبر است';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // دسته‌بندی
                      _buildCategorySelector(),
                      
                      const SizedBox(height: 16),
                      
                      // تاریخ
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.calendar_month, color: Colors.blue),
                          title: const Text('📅 تاریخ تراکنش'),
                          subtitle: Text(
                            DateFormat('EEEE, d MMMM yyyy', 'fa_IR').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _selectDate(context),
                          ),
                          onTap: () => _selectDate(context),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // توضیحات
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: '📄 توضیحات (اختیاری)',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // نمایش موجودی
                      _buildBalanceInfo(),
                      
                      const SizedBox(height: 32),
                      
                      // دکمه ذخیره
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _transactionType == 'income' 
                                ? Colors.green 
                                : Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_alt, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'ذخیره تراکنش',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}