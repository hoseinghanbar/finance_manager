// lib/presentation/controllers/payment_reminder_controller.dart
import 'package:flutter/material.dart'; // این خط رو اضافه کن
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

class PaymentReminder {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final String category;
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;

  PaymentReminder({
    String? id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.category,
    this.isPaid = false,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  PaymentReminder copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    String? category,
    bool? isPaid,
    String? notes,
  }) {
    return PaymentReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'category': category,
      'isPaid': isPaid,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentReminder.fromMap(Map<String, dynamic> map) {
    return PaymentReminder(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate']),
      category: map['category'],
      isPaid: map['isPaid'] ?? false,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class PaymentReminderController extends GetxController {
  final payments = <PaymentReminder>[].obs;
  final isLoading = false.obs;

  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    isLoading.value = true;
    try {
      final saved = _storage.read('payments');
      if (saved != null && saved is List) {
        payments.assignAll(
          saved.map((item) => PaymentReminder.fromMap(item as Map<String, dynamic>)).toList(),
        );
      }
      _sortPayments();
    } catch (e) {
      payments.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _savePayments() async {
    await _storage.write('payments', payments.map((p) => p.toMap()).toList());
  }

  void _sortPayments() {
    payments.sort((a, b) {
      if (a.isPaid && !b.isPaid) return 1;
      if (!a.isPaid && b.isPaid) return -1;
      return a.dueDate.compareTo(b.dueDate);
    });
  }

  Future<void> addPayment(PaymentReminder payment) async {
    payments.add(payment);
    _sortPayments();
    await _savePayments();
    Get.snackbar(
      'موفقیت',
      'یادآوری پرداخت اضافه شد',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> updatePayment(PaymentReminder payment) async {
    final index = payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      payments[index] = payment;
      _sortPayments();
      await _savePayments();
      Get.snackbar(
        'موفقیت',
        'یادآوری به‌روزرسانی شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deletePayment(String id) async {
    payments.removeWhere((p) => p.id == id);
    await _savePayments();
    Get.snackbar(
      'حذف شد',
      'یادآوری پرداخت حذف شد',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> togglePaid(String id) async {
    final index = payments.indexWhere((p) => p.id == id);
    if (index != -1) {
      payments[index] = payments[index].copyWith(isPaid: !payments[index].isPaid);
      _sortPayments();
      await _savePayments();
    }
  }
}