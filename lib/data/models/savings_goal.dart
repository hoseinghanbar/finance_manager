// lib/data/models/savings_goal.dart (اگر این فایل رو داری)
import 'dart:convert';
import 'package:intl/intl.dart';

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final DateTime createdAt;
  final String? icon;
  final String? color;

  SavingsGoal({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    DateTime? createdAt,
    this.icon,
    this.color,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now(),
        assert(name.trim().isNotEmpty, 'نام هدف نمی‌تواند خالی باشد'),
        assert(targetAmount > 0, 'مبلغ هدف باید بزرگتر از صفر باشد'),
        assert(currentAmount >= 0, 'مبلغ فعلی نمی‌تواند منفی باشد'),
        assert(currentAmount <= targetAmount, 'مبلغ فعلی نمی‌تواند از هدف بیشتر باشد'),
        assert(!targetDate.isBefore(DateTime.now()), 'تاریخ هدف نمی‌تواند در گذشته باشد');

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id']?.toString(),
      name: map['name']?.toString() ?? 'هدف جدید',
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['targetDate'] != null
          ? DateTime.parse(map['targetDate'].toString()).toLocal()
          : DateTime.now().add(const Duration(days: 30)),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString()).toLocal()
          : DateTime.now(),
      icon: map['icon']?.toString(),
      color: map['color']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'icon': icon,
      'color': color,
    };
  }

  String toJson() => jsonEncode(toMap());

  factory SavingsGoal.fromJson(String json) => SavingsGoal.fromMap(jsonDecode(json));

  // Getters
  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0;
  double get remainingAmount => targetAmount - currentAmount;
  int get daysLeft => targetDate.difference(DateTime.now()).inDays;
  bool get isCompleted => currentAmount >= targetAmount;
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  // Methods
  SavingsGoal addAmount(double amount) {
    final newAmount = currentAmount + amount;
    if (newAmount > targetAmount) {
      throw ArgumentError('مبلغ نمی‌تواند بیشتر از مبلغ هدف باشد');
    }
    return copyWith(currentAmount: newAmount);
  }

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    DateTime? createdAt,
    String? icon,
    String? color,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  String get progressPercentage => '${(progress * 100).toStringAsFixed(1)}%';
  
  String get formattedTargetAmount {
    return NumberFormat.decimalPattern('fa').format(targetAmount);
  }

  String get formattedCurrentAmount {
    return NumberFormat.decimalPattern('fa').format(currentAmount);
  }

  @override
  String toString() {
    return 'SavingsGoal(name: $name, progress: $progressPercentage)';
  }
}