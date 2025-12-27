import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String colorHex; // ذخیره به صورت hex string
  final String category;
  final String? notes;
  final DateTime createdAt;

  // سازنده اصلی
  SavingsGoal({
    String? id,
    required this.name,
    required this.targetAmount,
    required this.targetDate,
    this.currentAmount = 0,
    this.colorHex = '10B981', // سبز پیش‌فرض (متناسب با تم)
    this.category = 'عمومی',
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  // لیست رنگ‌های پیش‌فرض (hex بدون #)
  static List<String> get defaultColors => [
    '10B981', // سبز اصلی
    '3B82F6', // آبی
    '8B5CF6', // بنفش
    'EF4444', // قرمز
    'F59E0B', // نارنجی
    '06B6D4', // فیروزه‌ای
    '8B5CF6', // بنفش
  ];

  // Propertyهای محاسباتی
  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;
  bool get isCompleted => currentAmount >= targetAmount;
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(targetDate);
  bool get isAlmostComplete => progress >= 0.8 && !isCompleted;
  double get remainingAmount => targetAmount - currentAmount;
  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  // تبدیل hex string به Color
  Color get colorValue {
    try {
      if (colorHex.startsWith('0xFF') || colorHex.startsWith('0xff')) {
        return Color(int.parse(colorHex));
      } else if (colorHex.startsWith('#')) {
        return Color(int.parse('0xFF${colorHex.substring(1)}'));
      }
      return Color(int.parse('0xFF$colorHex'));
    } catch (e) {
      return const Color(0xFF10B981); // رنگ پیش‌فرض در صورت خطا
    }
  }

  // رنگ پیشرفت
  Color get progressColor {
    if (isCompleted) return const Color(0xFF10B981); // سبز
    if (isOverdue) return const Color(0xFFEF4444); // قرمز
    if (isAlmostComplete) return const Color(0xFFF59E0B); // نارنجی
    return const Color(0xFF3B82F6); // آبی
  }

  // ✅ متد copyWith کامل
  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? colorHex,
    String? category,
    String? notes,
    bool? isCompleted, // پارامتر اختیاری برای مدیریت وضعیت completion
  }) {
    // مدیریت currentAmount بر اساس isCompleted
    double updatedCurrentAmount = currentAmount ?? this.currentAmount;
    if (isCompleted == true && updatedCurrentAmount < (targetAmount ?? this.targetAmount)) {
      updatedCurrentAmount = targetAmount ?? this.targetAmount;
    } else if (isCompleted == false && updatedCurrentAmount >= (targetAmount ?? this.targetAmount)) {
      updatedCurrentAmount = 0;
    }

    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      currentAmount: updatedCurrentAmount,
      colorHex: colorHex ?? this.colorHex,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: this.createdAt,
    );
  }

  // ✅ متد برای اضافه کردن مبلغ
  SavingsGoal addAmount(double amount) {
    return copyWith(
      currentAmount: currentAmount + amount,
    );
  }

  // ✅ متد برای برداشت مبلغ
  SavingsGoal withdrawAmount(double amount) {
    final newAmount = currentAmount - amount;
    return copyWith(
      currentAmount: newAmount < 0 ? 0 : newAmount,
    );
  }

  // ✅ متد برای کامل‌سازی هدف
  SavingsGoal complete() {
    return copyWith(
      currentAmount: targetAmount,
      isCompleted: true,
    );
  }

  // ✅ متد برای ریست هدف
  SavingsGoal reset() {
    return copyWith(
      currentAmount: 0,
      isCompleted: false,
    );
  }

  // تبدیل به Map برای ذخیره
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'colorHex': colorHex,
      'category': category,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ایجاد از Map
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'],
      name: map['name'],
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      targetDate: DateTime.parse(map['targetDate']),
      colorHex: map['colorHex'],
      category: map['category'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  String toString() {
    return 'SavingsGoal{id: $id, name: $name, progress: ${(progress * 100).toStringAsFixed(1)}%}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsGoal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}