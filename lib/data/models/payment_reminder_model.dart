// lib/data/models/payment_reminder_model.dart
class PaymentReminder {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String? description;
  final DateTime createdAt;

  PaymentReminder({
    String? id,
    required this.title,
    required this.category,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.description,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  // Getter برای daysLeft
  int get daysLeft {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays;
  }

  // Getter برای بررسی سررسید
  bool get isOverdue => !isPaid && DateTime.now().isAfter(dueDate);

  factory PaymentReminder.fromMap(Map<String, dynamic> map) {
    return PaymentReminder(
      id: map['id']?.toString(),
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? 'سایر',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: map['dueDate'] != null 
          ? DateTime.parse(map['dueDate'].toString()) 
          : DateTime.now().add(const Duration(days: 7)),
      isPaid: map['isPaid'] == true,
      description: map['description']?.toString(),
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  PaymentReminder copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? description,
    DateTime? createdAt,
  }) {
    return PaymentReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  PaymentReminder markAsPaid() {
    return copyWith(isPaid: true);
  }

  @override
  String toString() {
    return 'PaymentReminder(title: $title, amount: $amount, daysLeft: $daysLeft)';
  }
}