// lib/presentation/screens/add_savings_goal_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/goal_model.dart';
import '../controllers/transaction_controller.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  final SavingsGoal? existingGoal;
  
  const AddSavingsGoalScreen({
    super.key,
    this.existingGoal,
  });

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final TransactionController _controller = Get.find<TransactionController>();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _currentAmountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  String _selectedIcon = '💰';
  int _selectedColor = 0xFF10B981;
  bool _isLoading = false;
  Timer? _debounceTimer;

  final List<String> _availableIcons = [
    '💰', '🏠', '🚗', '💻', '📱', '✈️', '🎓', '💍', 
    '🎮', '🏥', '👕', '🍔', '📚', '🎵', '🏋️', '🌴'
  ];

  final List<int> _availableColors = [
    0xFF10B981, 0xFF3B82F6, 0xFF8B5CF6, 0xFFEF4444,
    0xFFF59E0B, 0xFF06B6D4, 0xFFEC4899, 0xFF6366F1,
    0xFF84CC16, 0xFFF97316,
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _descriptionController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  void _initializeForm() {
    if (widget.existingGoal != null) {
      final goal = widget.existingGoal!;
      _nameController.text = goal.name;
      _targetAmountController.text = goal.targetAmount.toStringAsFixed(0);
      _currentAmountController.text = goal.currentAmount.toStringAsFixed(0);
      _selectedDate = goal.targetDate;
    } else {
      _currentAmountController.text = '0';
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    
    final targetAmount = _parseAmount(_targetAmountController.text);
    final currentAmount = _parseAmount(_currentAmountController.text);
    
    if (targetAmount == null || targetAmount <= 0) {
      _showError('مبلغ هدف باید بزرگتر از صفر باشد');
      return false;
    }
    
    if (currentAmount == null || currentAmount < 0) {
      _showError('مبلغ فعلی نمی‌تواند منفی باشد');
      return false;
    }
    
    if (currentAmount > targetAmount) {
      _showError('مبلغ فعلی نمی‌تواند از هدف بیشتر باشد');
      return false;
    }
    
    if (_selectedDate.isBefore(DateTime.now())) {
      _showError('تاریخ هدف باید در آینده باشد');
      return false;
    }
    
    return true;
  }
  
  double? _parseAmount(String text) {
    final cleanText = text.replaceAll(',', '').trim();
    if (cleanText.isEmpty) return null;
    return double.tryParse(cleanText);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('fa', 'IR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(_selectedColor),
              onPrimary: Colors.white,
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

  Future<void> _saveGoal() async {
    if (!_validateForm()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final targetAmount = _parseAmount(_targetAmountController.text)!;
      final currentAmount = _parseAmount(_currentAmountController.text)!;
      
      final goal = SavingsGoal(
        name: _nameController.text.trim(),
        targetAmount: targetAmount,
        targetDate: _selectedDate,
      );
      
      if (widget.existingGoal != null) {
        final updatedGoal = goal.copyWith(id: widget.existingGoal!.id);
        await _controller.updateGoal(updatedGoal);
        _showSuccess('هدف ویرایش شد', 'هدف با موفقیت به‌روزرسانی شد');
      } else {
        await _controller.addGoal(goal);
        _showSuccess('هدف ایجاد شد', 'هدف جدید با موفقیت ثبت شد');
      }
      
      await Future.delayed(const Duration(milliseconds: 1500));
      Get.back(result: true);
      
    } catch (e) {
      _showError('خطا در ذخیره هدف', e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _daysRemaining {
    final now = DateTime.now();
    final difference = _selectedDate.difference(now);
    return difference.inDays.clamp(0, 9999);
  }
  
  double get _progressPercentage {
    final target = _parseAmount(_targetAmountController.text) ?? 0;
    final current = _parseAmount(_currentAmountController.text) ?? 0;
    if (target <= 0) return 0;
    return (current / target * 100).clamp(0, 100);
  }
  
  Color get _selectedColorValue => Color(_selectedColor);
  
  String _formatAmount(String value) {
    if (value.isEmpty) return '';
    final clean = value.replaceAll(',', '');
    final number = double.tryParse(clean);
    if (number == null) return value;
    return NumberFormat.decimalPattern('fa').format(number);
  }
  
  void _showError(String message, [String? title]) {
    Get.snackbar(
      title ?? '❌ خطا',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
  
  void _showSuccess(String title, String message) {
    Get.snackbar(
      '✅ $title',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingGoal != null ? 'ویرایش هدف' : 'ایجاد هدف جدید',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'نام هدف *',
                          hintText: 'مثال: خرید لپ‌تاپ، سفر به شمال...',
                          prefixIcon: const Icon(Icons.flag, color: Colors.blue),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                        ),
                        maxLength: 50,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'لطفاً نام هدف را وارد کنید';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _targetAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'مبلغ هدف *',
                                hintText: '5,000,000',
                                prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                suffixText: 'تومان',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'لطفاً مبلغ را وارد کنید';
                                }
                                final amount = _parseAmount(value);
                                if (amount == null) {
                                  return 'مبلغ نامعتبر است';
                                }
                                if (amount <= 0) {
                                  return 'مبلغ باید بزرگتر از صفر باشد';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _debounceTimer?.cancel();
                                _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                                  if (value.isNotEmpty) {
                                    final formatted = _formatAmount(value);
                                    if (formatted != value) {
                                      _targetAmountController.text = formatted;
                                      _targetAmountController.selection = TextSelection.collapsed(offset: formatted.length);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _currentAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'مبلغ فعلی',
                                hintText: '1,000,000',
                                prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.green),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                suffixText: 'تومان',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تاریخ هدف *',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month, color: _selectedColorValue),
                                  const SizedBox(width: 12),
                                  Text(
                                    DateFormat('yyyy/MM/dd', 'fa_IR').format(_selectedDate),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _daysRemaining == 0 ? 'امروز' : '$_daysRemaining روز دیگر',
                                    style: TextStyle(
                                      color: _daysRemaining < 30 ? Colors.red : Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('لغو', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveGoal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedColorValue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      widget.existingGoal != null ? 'ذخیره تغییرات' : 'ایجاد هدف',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
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