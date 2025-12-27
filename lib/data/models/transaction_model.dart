// lib/data/models/transaction_model.dart
import 'dart:convert';
import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // 'income' یا 'expense'
  final String? description;
  final String? goalId; // اگر مربوط به یک هدف پس‌انداز باشد
  final DateTime createdAt;
  final DateTime updatedAt;

  // دسته‌بندی‌های معتبر
  static const List<String> validIncomeCategories = [
    'حقوق', 'فروش', 'سود سرمایه‌گذاری', 'هدیه', 'سایر درآمدها'
  ];
  
  static const List<String> validExpenseCategories = [
    'خوراک', 'حمل‌ونقل', 'مسکن', 'تفریح', 'سلامت', 
    'آموزش', 'خرید', 'سایر'
  ];

  // آیکون‌های دسته‌بندی
  static const Map<String, String> categoryIcons = {
    'خوراک': '🍕',
    'حمل‌ونقل': '🚗',
    'مسکن': '🏠',
    'تفریح': '🎮',
    'سلامت': '🏥',
    'آموزش': '📚',
    'خرید': '🛍️',
    'سایر': '📦',
    'حقوق': '💰',
    'فروش': '💼',
    'سود سرمایه‌گذاری': '📈',
    'هدیه': '🎁',
    'سایر درآمدها': '💵',
  };

  // رنگ‌های دسته‌بندی
  static const Map<String, String> categoryColors = {
    'خوراک': '#FF6B6B',
    'حمل‌ونقل': '#4ECDC4',
    'مسکن': '#45B7D1',
    'تفریح': '#96CEB4',
    'سلامت': '#FFEAA7',
    'آموزش': '#DDA0DD',
    'خرید': '#98D8AA',
    'سایر': '#9E9E9E',
    'حقوق': '#4CAF50',
    'فروش': '#2196F3',
    'سود سرمایه‌گذاری': '#9C27B0',
    'هدیه': '#FF9800',
    'سایر درآمدها': '#F44336',
  };

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    DateTime? date,
    required this.category,
    required this.type,
    this.description,
    this.goalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        assert(title.trim().isNotEmpty, 'عنوان تراکنش نمی‌تواند خالی باشد'),
        assert(amount > 0, 'مبلغ تراکنش باید بزرگتر از صفر باشد'),
        assert(type == 'income' || type == 'expense', 'نوع تراکنش باید income یا expense باشد'),
        assert(_isValidCategory(category, type), 'دسته‌بندی نامعتبر برای نوع تراکنش') {
    // اعتبارسنجی دسته‌بندی
    if (!_isValidCategory(category, type)) {
      throw ArgumentError('دسته‌بندی "$category" برای تراکنش نوع "$type" معتبر نیست');
    }
  }

  // ==================== Factory Constructors ====================
  
  factory Transaction.fromMap(Map<String, dynamic> map) {
    try {
      return Transaction(
        id: map['id']?.toString(),
        title: map['title']?.toString() ?? 'بدون عنوان',
        amount: _parseDouble(map['amount']) ?? 0.0,
        date: map['date'] != null
            ? DateTime.parse(map['date'].toString()).toLocal()
            : DateTime.now(),
        category: map['category']?.toString() ?? 'سایر',
        type: (map['type']?.toString() == 'income') ? 'income' : 'expense',
        description: map['description']?.toString(),
        goalId: map['goalId']?.toString(),
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'].toString()).toLocal()
            : DateTime.now(),
        updatedAt: map['updatedAt'] != null
            ? DateTime.parse(map['updatedAt'].toString()).toLocal()
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException('خطا در ایجاد تراکنش از Map: $e');
    }
  }

  factory Transaction.fromJson(String json) => Transaction.fromMap(jsonDecode(json));

  // ==================== Validation Helpers ====================
  
  static bool _isValidCategory(String category, String type) {
    final validCategories = type == 'income' 
        ? validIncomeCategories 
        : validExpenseCategories;
    return validCategories.contains(category);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ==================== Conversion Methods ====================
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'type': type,
      'description': description,
      'goalId': goalId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  // ==================== Copy With ====================
  
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    String? type,
    String? description,
    String? goalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      goalId: goalId ?? this.goalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ==================== Getters ====================
  
  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  String get categoryIcon => categoryIcons[category] ?? '💰';
  
  String get categoryColor => categoryColors[category] ?? '#9E9E9E';

  // ==================== Date & Time Methods ====================
  
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  bool get isThisYear {
    final now = DateTime.now();
    return date.year == now.year;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) return 'همین الان';
    if (difference.inMinutes < 60) return '${difference.inMinutes} دقیقه پیش';
    if (difference.inHours < 24) return '${difference.inHours} ساعت پیش';
    if (difference.inDays == 1) return 'دیروز';
    if (difference.inDays < 7) return '${difference.inDays} روز پیش';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} هفته پیش';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} ماه پیش';
    return '${(difference.inDays / 365).floor()} سال پیش';
  }

  // ==================== Formatting Methods ====================
  
  String get formattedDate {
    final persianDate = DateFormat('yyyy/MM/dd', 'fa_IR');
    return persianDate.format(date);
  }

  String get formattedTime {
    final timeFormat = DateFormat('HH:mm', 'fa_IR');
    return timeFormat.format(date);
  }

  String get formattedDateTime {
    return '$formattedDate ساعت $formattedTime';
  }

  String get formattedWeekday {
    final weekdays = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];
    return weekdays[date.weekday % 7];
  }

  String get formattedAmount {
    final format = NumberFormat.decimalPattern('fa');
    final formatted = format.format(amount);
    return '$formatted تومان';
  }

  String get amountWithSign {
    final prefix = isIncome ? '+' : '-';
    final format = NumberFormat.decimalPattern('fa');
    final formatted = format.format(amount);
    return '$prefix $formatted تومان';
  }

  String get displayTitle {
    if (title.length <= 20) return title;
    return '${title.substring(0, 17)}...';
  }

  // ==================== Validation Methods ====================
  
  bool get isValid {
    return title.trim().isNotEmpty &&
        amount > 0 &&
        (type == 'income' || type == 'expense') &&
        _isValidCategory(category, type) &&
        date.isBefore(DateTime.now().add(const Duration(days: 1))) &&
        date.isAfter(DateTime.now().subtract(const Duration(days: 3650)));
  }

  List<String> validate() {
    final errors = <String>[];
    
    if (title.trim().isEmpty) errors.add('عنوان تراکنش نمی‌تواند خالی باشد');
    if (amount <= 0) errors.add('مبلغ تراکنش باید بزرگتر از صفر باشد');
    if (type != 'income' && type != 'expense') {
      errors.add('نوع تراکنش باید income یا expense باشد');
    }
    if (!_isValidCategory(category, type)) {
      errors.add('دسته‌بندی "$category" برای تراکنش نوع "$type" معتبر نیست');
    }
    if (date.isAfter(DateTime.now())) {
      errors.add('تاریخ تراکنش نمی‌تواند در آینده باشد');
    }
    
    return errors;
  }

  // ==================== Utility Methods ====================
  
  Transaction markAsRelatedToGoal(String goalId) => copyWith(goalId: goalId);

  Transaction removeGoalRelation() => copyWith(goalId: null);

  Transaction updateAmount(double newAmount) {
    if (newAmount <= 0) {
      throw ArgumentError('مبلغ جدید باید بزرگتر از صفر باشد');
    }
    return copyWith(amount: newAmount);
  }

  // ==================== Static Methods ====================
  
  static Transaction createSample({
    bool isIncome = false,
    String? category,
    double? amount,
    String? title,
  }) {
    final random = DateTime.now().microsecond;
    final type = isIncome ? 'income' : 'expense';
    final categories = isIncome ? validIncomeCategories : validExpenseCategories;
    
    return Transaction(
      title: title ?? (isIncome ? 'درآمد نمونه' : 'هزینه نمونه'),
      amount: amount ?? (10000 + (random % 990000)).toDouble(),
      category: category ?? categories[random % categories.length],
      type: type,
      description: 'این یک تراکنش نمونه است',
      date: DateTime.now().subtract(Duration(days: random % 30)),
    );
  }

  static List<Transaction> createSamples(int count, {bool isIncome = false}) {
    return List.generate(count, (index) => createSample(isIncome: isIncome));
  }

  // ==================== Comparison Methods ====================
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // ==================== String Representation ====================
  
  @override
  String toString() {
    return '''Transaction {
  id: $id,
  title: "$title",
  amount: $formattedAmount,
  type: $type,
  category: $category,
  date: $formattedDate,
  ${description != null ? 'description: "$description"' : ''}
}''';
  }
}