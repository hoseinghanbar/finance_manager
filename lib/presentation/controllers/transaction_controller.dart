// lib/presentation/controllers/transaction_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../../data/models/goal_model.dart';
import '../../data/models/transaction_model.dart';

class TransactionController extends GetxController {
  // ========== Observable Variables ==========
  final balance = 0.0.obs;
  final totalIncome = 0.0.obs;
  final totalExpense = 0.0.obs;
  final transactions = <Transaction>[].obs;
  final savingsGoals = <SavingsGoal>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final selectedFilter = TransactionFilter.all.obs;
  final selectedMonth = DateTime.now().obs;
  
  final categories = <TransactionCategory>[
    TransactionCategory(name: 'خوراک', icon: '🍕', color: 'FF6B6B'),
    TransactionCategory(name: 'حمل‌ونقل', icon: '🚗', color: '4ECDC4'),
    TransactionCategory(name: 'مسکن', icon: '🏠', color: '45B7D1'),
    TransactionCategory(name: 'تفریح', icon: '🎮', color: '96CEB4'),
    TransactionCategory(name: 'سلامت', icon: '🏥', color: 'FFEAA7'),
    TransactionCategory(name: 'آموزش', icon: '📚', color: 'DDA0DD'),
    TransactionCategory(name: 'خرید', icon: '🛍️', color: '98D8AA'),
    TransactionCategory(name: 'حقوق', icon: '💰', color: '4CAF50'),
    TransactionCategory(name: 'سایر', icon: '📦', color: '9E9E9E'),
  ].obs;

  final _storage = GetStorage();
  Timer? _debounceTimer;

  // ========== Getters & Computed Properties ==========
  
  List<Transaction> get filteredTransactions {
    List<Transaction> result = transactions.toList();
    
    // اعمال فیلتر بر اساس نوع
    switch (selectedFilter.value) {
      case TransactionFilter.income:
        result = result.where((t) => t.isIncome).toList();
        break;
      case TransactionFilter.expense:
        result = result.where((t) => t.isExpense).toList();
        break;
      case TransactionFilter.month:
        result = _getTransactionsByMonth(selectedMonth.value);
        break;
      case TransactionFilter.all:
        break;
    }
    
    // اعمال جستجو
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((transaction) {
        return transaction.title.toLowerCase().contains(query) ||
            transaction.category.toLowerCase().contains(query) ||
            (transaction.description?.toLowerCase().contains(query) ?? false) ||
            _formatCurrency(transaction.amount).contains(query) ||
            _formatDate(transaction.date).contains(query);
      }).toList();
    }
    
    return result;
  }
  
  List<Transaction> get recentTransactions => 
      transactions.take(10).toList();
  
  List<SavingsGoal> get activeGoals => 
      savingsGoals.where((goal) => !goal.isCompleted).toList();
  
  List<SavingsGoal> get completedGoals => 
      savingsGoals.where((goal) => goal.isCompleted).toList();
  
  List<Transaction> get monthlyIncome => 
      transactions.where((t) => t.isIncome && t.isThisMonth).toList();
  
  List<Transaction> get monthlyExpense => 
      transactions.where((t) => t.isExpense && t.isThisMonth).toList();
  
  double get monthlyBalance {
    final income = monthlyIncome.fold(0.0, (sum, t) => sum + t.amount);
    final expense = monthlyExpense.fold(0.0, (sum, t) => sum + t.amount);
    return income - expense;
  }

  // ========== Lifecycle Methods ==========
  
  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }
  
  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  // ========== Initialization Methods ==========
  
  Future<void> _initializeData() async {
    isLoading.value = true;
    
    try {
      await Future.wait([
        _loadTransactions(),
        _loadGoals(),
        _loadCategories(),
      ]);
      
      _calculateTotals();
      
      if (transactions.isEmpty) {
        await _addSampleData();
      }
    } catch (e) {
      _showError('خطا در بارگذاری داده‌ها', e.toString());
      await _resetToDefaults();
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Transaction Management ==========
  
  /// اضافه کردن تراکنش جدید
  Future<void> addTransaction(Transaction transaction) async {
    try {
      // اعتبارسنجی
      _validateTransaction(transaction);
      
      // بررسی موجودی برای هزینه‌ها
      if (transaction.isExpense && transaction.amount > balance.value) {
        await _showInsufficientBalanceDialog(transaction.amount);
        return;
      }
      
      // افزودن تراکنش
      transactions.insert(0, transaction);
      
      // به‌روزرسانی آمار
      _updateTotals(transaction);
      
      // ذخیره در حافظه
      await _saveTransactions();
      
      // نمایش پیام موفقیت
      _showSuccessMessage(transaction);
      
      // به‌روزرسانی هدف مرتبط
      if (transaction.goalId != null && transaction.isExpense) {
        await _updateGoalProgress(transaction.goalId!, transaction.amount);
      }
      
    } catch (e) {
      _showError('خطا در ثبت تراکنش', e.toString());
      rethrow;
    }
  }
  
  /// حذف تراکنش
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transaction = transactions.firstWhereOrNull(
        (t) => t.id == transactionId
      );
      
      if (transaction == null) {
        throw Exception('تراکنش مورد نظر یافت نشد');
      }
      
      // حذف تراکنش
      transactions.removeWhere((t) => t.id == transactionId);
      
      // تنظیم مجدد آمار
      if (transaction.isIncome) {
        totalIncome.value -= transaction.amount;
        balance.value -= transaction.amount;
      } else {
        totalExpense.value -= transaction.amount;
        balance.value += transaction.amount;
      }
      
      // ذخیره تغییرات
      await _saveTransactions();
      
      _showInfo('حذف شد', 'تراکنش با موفقیت حذف شد');
      
    } catch (e) {
      _showError('خطا در حذف تراکنش', e.toString());
      rethrow;
    }
  }
  
  /// ویرایش تراکنش
  Future<void> updateTransaction(Transaction updatedTransaction) async {
    try {
      _validateTransaction(updatedTransaction);
      
      final index = transactions.indexWhere(
        (t) => t.id == updatedTransaction.id
      );
      
      if (index == -1) {
        throw Exception('تراکنش مورد نظر یافت نشد');
      }
      
      final oldTransaction = transactions[index];
      
      // تنظیم مجدد آمار برای تراکنش قدیمی
      if (oldTransaction.isIncome) {
        totalIncome.value -= oldTransaction.amount;
        balance.value -= oldTransaction.amount;
      } else {
        totalExpense.value -= oldTransaction.amount;
        balance.value += oldTransaction.amount;
      }
      
      // اعمال آمار جدید
      if (updatedTransaction.isIncome) {
        totalIncome.value += updatedTransaction.amount;
        balance.value += updatedTransaction.amount;
      } else {
        totalExpense.value += updatedTransaction.amount;
        balance.value -= updatedTransaction.amount;
      }
      
      // جایگزینی تراکنش
      transactions[index] = updatedTransaction;
      
      // ذخیره تغییرات
      await _saveTransactions();
      
      _showSuccess('به‌روزرسانی شد', 'تراکنش با موفقیت ویرایش شد');
      
    } catch (e) {
      _showError('خطا در ویرایش تراکنش', e.toString());
      rethrow;
    }
  }
  
  /// ریست کردن تمام داده‌ها
  Future<void> reset() async {
    isLoading.value = true;
    
    try {
      transactions.clear();
      savingsGoals.clear();
      balance.value = 0.0;
      totalIncome.value = 0.0;
      totalExpense.value = 0.0;
      searchQuery.value = '';
      selectedFilter.value = TransactionFilter.all;
      selectedMonth.value = DateTime.now();
      
      await _saveTransactions();
      await _saveGoals();
      
      if (kDebugMode) {
        print('🔄 TransactionController reset complete');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resetting TransactionController: $e');
      }
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ========== Goal Management ==========
  
  Future<void> addGoal(SavingsGoal goal) async {
  try {
    // اعتبارسنجی دستی
    if (goal.name.trim().isEmpty) {
      throw ArgumentError('نام هدف نمی‌تواند خالی باشد');
    }
    
    if (goal.targetAmount <= 0) {
      throw ArgumentError('مبلغ هدف باید بزرگتر از صفر باشد');
    }
    
    if (goal.currentAmount < 0) {
      throw ArgumentError('مبلغ فعلی نمی‌تواند منفی باشد');
    }
    
    if (goal.currentAmount > goal.targetAmount) {
      throw ArgumentError('مبلغ فعلی نمی‌تواند از هدف بیشتر باشد');
    }
    
    if (goal.targetDate.isBefore(DateTime.now())) {
      throw ArgumentError('تاریخ هدف نمی‌تواند در گذشته باشد');
    }
    
    // فقط یکبار اضافه کن
    savingsGoals.add(goal);
    await _saveGoals();
    
    _showSuccess('هدف اضافه شد', 'هدف جدید با موفقیت ثبت شد');
  } catch (e) {
    _showError('خطا در ثبت هدف', e.toString());
    rethrow;
  }
}

Future<void> updateGoal(SavingsGoal goal) async {
  try {
    // اعتبارسنجی برای update هم
    if (goal.name.trim().isEmpty) {
      throw ArgumentError('نام هدف نمی‌تواند خالی باشد');
    }
    
    if (goal.targetAmount <= 0) {
      throw ArgumentError('مبلغ هدف باید بزرگتر از صفر باشد');
    }
    
    if (goal.currentAmount < 0) {
      throw ArgumentError('مبلغ فعلی نمی‌تواند منفی باشد');
    }
    
    if (goal.currentAmount > goal.targetAmount) {
      throw ArgumentError('مبلغ فعلی نمی‌تواند از هدف بیشتر باشد');
    }
    
    if (goal.targetDate.isBefore(DateTime.now())) {
      throw ArgumentError('تاریخ هدف نمی‌تواند در گذشته باشد');
    }
    
    final index = savingsGoals.indexWhere((g) => g.id == goal.id);
    if (index == -1) {
      throw Exception('هدف مورد نظر یافت نشد');
    }
    
    savingsGoals[index] = goal;
    await _saveGoals();
    
    _showSuccess('به‌روزرسانی شد', 'هدف با موفقیت ویرایش شد');
  } catch (e) {
    _showError('خطا در به‌روزرسانی هدف', e.toString());
    rethrow;
  }
}

Future<void> deleteGoal(String goalId) async {
  try {
    savingsGoals.removeWhere((g) => g.id == goalId);
    await _saveGoals();
    
    _showInfo('حذف شد', 'هدف با موفقیت حذف شد');
  } catch (e) {
    _showError('خطا در حذف هدف', e.toString());
    rethrow;
  }
}

Future<void> addToGoal(String goalId, double amount) async {
  try {
    final goal = savingsGoals.firstWhereOrNull((g) => g.id == goalId);
    if (goal == null) {
      throw Exception('هدف مورد نظر یافت نشد');
    }
    
    if (amount <= 0) {
      throw ArgumentError('مبلغ باید بزرگتر از صفر باشد');
    }
    
    // بررسی که مبلغ اضافه شده باعث تجاوز از هدف نشود
    final newAmount = goal.currentAmount + amount;
    if (newAmount > goal.targetAmount) {
      final allowedAmount = goal.targetAmount - goal.currentAmount;
      if (allowedAmount <= 0) {
        throw ArgumentError('این هدف قبلاً تکمیل شده است');
      }
      throw ArgumentError('مبلغ نمی‌تواند بیشتر از ${_formatCurrency(allowedAmount)} باشد');
    }
    
    final updatedGoal = goal.addAmount(amount);
    await updateGoal(updatedGoal);
    
    _showSuccess('پرداخت ثبت شد', 'مبلغ به هدف اضافه شد');
  } catch (e) {
    _showError('خطا در پرداخت به هدف', e.toString());
    rethrow;
  }
}
  // ========== Filtering & Searching ==========
  
  void setSearchQuery(String query) {
    _debounceTimer?.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = query.trim();
    });
  }
  
  void setFilter(TransactionFilter filter) {
    selectedFilter.value = filter;
  }
  
  void setSelectedMonth(DateTime month) {
    selectedMonth.value = DateTime(month.year, month.month);
    selectedFilter.value = TransactionFilter.month;
  }
  
  void clearFilters() {
    searchQuery.value = '';
    selectedFilter.value = TransactionFilter.all;
    selectedMonth.value = DateTime.now();
  }

  // ========== Data Analysis Methods ==========
  
  List<Transaction> _getTransactionsByMonth(DateTime month) {
    return transactions.where((transaction) {
      return transaction.date.year == month.year &&
             transaction.date.month == month.month;
    }).toList();
  }
  
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> result = {};
    
    for (final transaction in transactions.where((t) => t.isExpense)) {
      result[transaction.category] = 
          (result[transaction.category] ?? 0) + transaction.amount;
    }
    
    return result;
  }
  
  Map<String, double> getMonthlyTrends(int monthsBack) {
    final Map<String, double> trends = {};
    final now = DateTime.now();
    
    for (int i = 0; i < monthsBack; i++) {
      final month = DateTime(now.year, now.month - i);
      final monthlyTransactions = _getTransactionsByMonth(month);
      
      double income = 0;
      double expense = 0;
      
      for (final transaction in monthlyTransactions) {
        if (transaction.isIncome) {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
        }
      }
      
      final monthName = DateFormat('MMM', 'fa_IR').format(month);
      trends['$monthName درآمد'] = income;
      trends['$monthName هزینه'] = expense;
    }
    
    return trends;
  }
  
  double getAverageMonthlyExpense() {
    if (transactions.isEmpty) return 0;
    
    final expenses = transactions.where((t) => t.isExpense);
    if (expenses.isEmpty) return 0;
    
    return expenses.fold(0.0, (sum, t) => sum + t.amount) / expenses.length;
  }
  
  String getMostFrequentCategory() {
    final Map<String, int> categoryCount = {};
    
    for (final transaction in transactions) {
      categoryCount[transaction.category] = 
          (categoryCount[transaction.category] ?? 0) + 1;
    }
    
    if (categoryCount.isEmpty) return 'هیچ';
    
    return categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  // ========== Data Persistence Methods ==========
  
  Future<void> _loadTransactions() async {
    try {
      final saved = _storage.read('transactions');
      if (saved != null && saved is List) {
        transactions.clear();
        for (final item in saved) {
          if (item is Map<String, dynamic>) {
            transactions.add(Transaction.fromMap(item));
          }
        }
        transactions.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در بارگذاری تراکنش‌ها: $e');
      }
      throw e;
    }
  }
  
  Future<void> _saveTransactions() async {
    try {
      final transactionsToSave = transactions
          .map((transaction) => transaction.toMap())
          .toList();
      await _storage.write('transactions', transactionsToSave);
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در ذخیره تراکنش‌ها: $e');
      }
      throw e;
    }
  }
  
  Future<void> _loadGoals() async {
    try {
      final saved = _storage.read('savingsGoals');
      if (saved != null && saved is List) {
        savingsGoals.clear();
        for (final item in saved) {
          if (item is Map<String, dynamic>) {
            savingsGoals.add(SavingsGoal.fromMap(item));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در بارگذاری اهداف: $e');
      }
      throw e;
    }
  }
  
  Future<void> _saveGoals() async {
    try {
      final goalsToSave = savingsGoals
          .map((goal) => goal.toMap())
          .toList();
      await _storage.write('savingsGoals', goalsToSave);
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در ذخیره اهداف: $e');
      }
      throw e;
    }
  }
  
  Future<void> _loadCategories() async {
    try {
      final saved = _storage.read('categories');
      if (saved != null && saved is List) {
        categories.clear();
        for (final item in saved) {
          if (item is Map<String, dynamic>) {
            categories.add(TransactionCategory.fromMap(item));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در بارگذاری دسته‌بندی‌ها: $e');
      }
      throw e;
    }
  }
  
  Future<void> _saveCategories() async {
    try {
      final categoriesToSave = categories
          .map((category) => category.toMap())
          .toList();
      await _storage.write('categories', categoriesToSave);
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در ذخیره دسته‌بندی‌ها: $e');
      }
      throw e;
    }
  }

  // ========== Helper Methods ==========
  
  void _calculateTotals() {
    double income = 0;
    double expense = 0;
    
    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }
    
    totalIncome.value = income;
    totalExpense.value = expense;
    balance.value = income - expense;
  }
  
  void _updateTotals(Transaction transaction) {
    if (transaction.isIncome) {
      totalIncome.value += transaction.amount;
      balance.value += transaction.amount;
    } else {
      totalExpense.value += transaction.amount;
      balance.value -= transaction.amount;
    }
  }
  
  Future<void> _updateGoalProgress(String goalId, double amount) async {
    try {
      final goal = savingsGoals.firstWhereOrNull((g) => g.id == goalId);
      if (goal == null) return;
      
      final updatedGoal = goal.addAmount(amount);
      await updateGoal(updatedGoal);
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در به‌روزرسانی هدف: $e');
      }
    }
  }
  
  void _validateTransaction(Transaction transaction) {
    if (transaction.title.trim().isEmpty) {
      throw ArgumentError('عنوان تراکنش نمی‌تواند خالی باشد');
    }
    
    if (transaction.amount <= 0) {
      throw ArgumentError('مبلغ تراکنش باید بزرگتر از صفر باشد');
    }
    
    if (!categories.any((c) => c.name == transaction.category)) {
      throw ArgumentError('دسته‌بندی نامعتبر است');
    }
    
    if (transaction.type != 'income' && transaction.type != 'expense') {
      throw ArgumentError('نوع تراکنش نامعتبر است');
    }
    
    if (transaction.date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      throw ArgumentError('تاریخ تراکنش نمی‌تواند در آینده باشد');
    }
  }

  // ========== Sample Data ==========
  
  Future<void> _addSampleData() async {
    try {
      transactions.addAll([
        Transaction(
          title: 'حقوق ماهیانه',
          amount: 5000000,
          category: 'حقوق',
          type: 'income',
          date: DateTime.now().subtract(const Duration(days: 2)),
          description: 'حقوق شرکت',
        ),
        Transaction(
          title: 'خرید مواد غذایی',
          amount: 300000,
          category: 'خوراک',
          type: 'expense',
          date: DateTime.now().subtract(const Duration(days: 1)),
          description: 'فروشگاه رفاه',
        ),
        Transaction(
          title: 'شارژ اینترنت',
          amount: 100000,
          category: 'سایر',
          type: 'expense',
          date: DateTime.now(),
          description: 'اینترنت ماهیانه',
        ),
      ]);
      
      savingsGoals.addAll([
        SavingsGoal(
          name: 'خرید لپ‌تاپ',
          targetAmount: 50000000,
          currentAmount: 15000000,
          targetDate: DateTime.now().add(const Duration(days: 180)),
        ),
        SavingsGoal(
          name: 'سفر به شمال',
          targetAmount: 20000000,
          currentAmount: 5000000,
          targetDate: DateTime.now().add(const Duration(days: 90)),
        ),
      ]);
      
      await _saveTransactions();
      await _saveGoals();
      _calculateTotals();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در افزودن داده‌های نمونه: $e');
      }
    }
  }
  
  Future<void> _resetToDefaults() async {
    try {
      transactions.clear();
      savingsGoals.clear();
      balance.value = 0.0;
      totalIncome.value = 0.0;
      totalExpense.value = 0.0;
      
      await _saveTransactions();
      await _saveGoals();
    } catch (e) {
      if (kDebugMode) {
        print('❌ خطا در بازنشانی داده‌ها: $e');
      }
    }
  }

  // ========== UI Helper Methods ==========
  
  Future<void> _showInsufficientBalanceDialog(double amount) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('❌ موجودی ناکافی'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• موجودی فعلی: ${_formatCurrency(balance.value)}'),
            const SizedBox(height: 10),
            Text('• مبلغ درخواستی: ${_formatCurrency(amount)}'),
            const SizedBox(height: 10),
            Text(
              '• کمبود: ${_formatCurrency(amount - balance.value)}',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'لطفاً درآمد اضافه کنید یا مبلغ کمتری وارد نمایید.',
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
  
  void _showSuccessMessage(Transaction transaction) {
    Get.snackbar(
      transaction.isIncome ? '✅ درآمد ثبت شد' : '💸 هزینه ثبت شد',
      '«${transaction.title}» با موفقیت ${transaction.isIncome ? 'افزوده' : 'کسر'} شد',
      backgroundColor: transaction.isIncome ? Colors.green : Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
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
  
  void _showError(String title, String message) {
    Get.snackbar(
      '❌ $title',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
  
  void _showInfo(String title, String message) {
    Get.snackbar(
      'ℹ️ $title',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
  
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPattern('fa');
    return '${formatter.format(amount)} تومان';
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }
  
  // ========== Export & Backup ==========
  
  Future<String> exportToJson() async {
    final data = {
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'goals': savingsGoals.map((g) => g.toMap()).toList(),
      'summary': {
        'balance': balance.value,
        'totalIncome': totalIncome.value,
        'totalExpense': totalExpense.value,
        'exportDate': DateTime.now().toIso8601String(),
      }
    };
    
    return jsonEncode(data);
  }
  
  Future<void> importFromJson(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      
      if (data['transactions'] is List) {
        transactions.clear();
        for (final item in data['transactions'] as List) {
          transactions.add(Transaction.fromMap(item as Map<String, dynamic>));
        }
      }
      
      if (data['goals'] is List) {
        savingsGoals.clear();
        for (final item in data['goals'] as List) {
          savingsGoals.add(SavingsGoal.fromMap(item as Map<String, dynamic>));
        }
      }
      
      await _saveTransactions();
      await _saveGoals();
      _calculateTotals();
      
      _showSuccess('واردات موفق', 'داده‌ها با موفقیت وارد شدند');
    } catch (e) {
      _showError('خطا در واردات', 'فایل JSON نامعتبر است');
      rethrow;
    }
  }
}

// ========== Supporting Classes & Enums ==========

enum TransactionFilter { all, income, expense, month }

class TransactionCategory {
  final String name;
  final String icon;
  final String color;
  
  TransactionCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
  
  factory TransactionCategory.fromMap(Map<String, dynamic> map) {
    return TransactionCategory(
      name: map['name']?.toString() ?? '',
      icon: map['icon']?.toString() ?? '📦',
      color: map['color']?.toString() ?? '9E9E9E',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
    };
  }
  
  Color get colorValue {
    try {
      return Color(int.parse('0xFF$color'));
    } catch (e) {
      return Colors.grey;
    }
  }
}