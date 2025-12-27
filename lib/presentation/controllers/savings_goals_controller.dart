// lib/presentation/controllers/savings_goals_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SavingsGoalsController extends GetxController {
  // لیست اهداف
  final RxList<Map<String, dynamic>> goals = <Map<String, dynamic>>[].obs;
  
  // وضعیت لودینگ
  final RxBool isLoading = false.obs;
  
  // ذخیره‌سازی
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    print('✅ SavingsGoalsController initialized - Hash: ${hashCode}');
    
    // 🔥 اضافه کردن تأخیر برای اطمینان از ثبت کامل
    Future.delayed(Duration.zero, () {
      loadGoals();
    });
  }

  // 🔥 متد ایمن‌تر برای بارگذاری
  Future<void> loadGoals() async {
    try {
      // بررسی ثبت بودن کنترلر
      if (!Get.isRegistered<SavingsGoalsController>()) {
        print('⚠️ کنترلر ثبت نشده! در حال ثبت...');
        Get.put(this, permanent: true);
      }
      
      isLoading.value = true;
      print('🔄 Loading goals...');
      
      // کمی تاخیر
      await Future.delayed(const Duration(milliseconds: 300));
      
      final saved = _storage.read('savingsGoals');
      
      if (saved != null && saved is List) {
        goals.value = List<Map<String, dynamic>>.from(saved);
        print('✅ Loaded ${goals.length} goals');
      } else {
        print('ℹ️ No saved goals found, initializing empty list');
        goals.value = [];
        // 🔥 مقدار پیش‌فرض برای تست
        _initializeSampleGoals();
      }
    } catch (e) {
      print('❌ Error loading goals: $e');
      // 🔥 مقدار پیش‌فرض در صورت خطا
      goals.value = [];
      _initializeSampleGoals();
      
      Get.snackbar(
        'خطا',
        'خطا در بارگذاری اهداف',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🔥 مقدار پیش‌فرض برای جلوگیری از خطا
  void _initializeSampleGoals() {
    try {
      // فقط اگر لیست خالی است
      if (goals.isEmpty) {
        goals.addAll([
          {
            'id': '1',
            'name': 'خرایش خودرو',
            'targetAmount': 50000000,
            'currentAmount': 15000000,
            'targetDate': DateTime.now().add(const Duration(days: 180)).toIso8601String(),
            'icon': '🚗',
            'color': '#2196F3',
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'id': '2',
            'name': 'تعطیلات',
            'targetAmount': 20000000,
            'currentAmount': 5000000,
            'targetDate': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
            'icon': '🏖️',
            'color': '#4CAF50',
            'createdAt': DateTime.now().toIso8601String(),
          },
        ]);
        print('✅ Sample goals initialized');
      }
    } catch (e) {
      print('❌ Error initializing sample goals: $e');
    }
  }

  // 🔥 متد ایمن‌تر برای افزودن هدف
  Future<void> addGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double currentAmount = 0.0,
    String icon = '💰',
    String color = '#2196F3',
  }) async {
    try {
      // بررسی ثبت بودن کنترلر
      if (!Get.isRegistered<SavingsGoalsController>()) {
        print('⚠️ کنترلر ثبت نشده در addGoal!');
        Get.put(this, permanent: true);
      }
      
      // اعتبارسنجی
      if (name.isEmpty) {
        throw Exception('نام هدف نمی‌تواند خالی باشد');
      }
      
      if (targetAmount <= 0) {
        throw Exception('مبلغ هدف باید بزرگتر از صفر باشد');
      }

      // ساخت هدف جدید
      final goal = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'targetDate': targetDate.toIso8601String(),
        'icon': icon,
        'color': color,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // اضافه کردن به لیست
      goals.add(goal);
      
      // ذخیره در حافظه
      await _saveGoals();

      // نمایش پیام موفقیت
      Get.snackbar(
        '🎯 موفقیت',
        'هدف "$name" با موفقیت ایجاد شد',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      print('✅ Goal added: $name');
    } catch (e) {
      print('❌ Error adding goal: $e');
      Get.snackbar(
        '❌ خطا',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🔥 متد ایمن‌تر برای ذخیره
  Future<void> _saveGoals() async {
    try {
      await _storage.write('savingsGoals', goals.toList());
      print('💾 Goals saved: ${goals.length} goals');
    } catch (e) {
      print('❌ Error saving goals: $e');
      // تلاش مجدد
      await Future.delayed(const Duration(milliseconds: 100));
      try {
        await _storage.write('savingsGoals', goals.toList());
      } catch (e2) {
        print('❌ Error in retry: $e2');
      }
    }
  }

  // 🔥 متد ایمن‌تر برای پاک‌سازی
  Future<void> resetAllData() async {
    try {
      print('🔄 Starting resetAllData...');
      
      // بررسی ثبت بودن کنترلر
      if (!Get.isRegistered<SavingsGoalsController>()) {
        print('⚠️ کنترلر ثبت نشده در resetAllData!');
        Get.put(this, permanent: true);
      }
      
      // پاک کردن لیست
      goals.clear();
      
      // پاک کردن از حافظه
      await _storage.remove('savingsGoals');
      
      // اضافه کردن اهداف نمونه
      await Future.delayed(const Duration(milliseconds: 500));
      _initializeSampleGoals();
      
      // نمایش پیام
      Get.snackbar(
        '🔄 پاک‌سازی شد',
        'تمامی اهداف حذف شدند و اهداف نمونه اضافه شدند',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      print('✅ All goals reset with sample data');
    } catch (e) {
      print('❌ Error in resetAllData: $e');
      Get.snackbar(
        '⚠️ توجه',
        'داده‌ها پاک شدند اما خطایی رخ داد',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  // 🔥 متد ایمن‌تر برای حذف
  Future<void> deleteGoal(String goalId) async {
    try {
      // بررسی ثبت بودن کنترلر
      if (!Get.isRegistered<SavingsGoalsController>()) {
        print('⚠️ کنترلر ثبت نشده در deleteGoal!');
        Get.put(this, permanent: true);
      }
      
      final goalToDelete = goals.firstWhereOrNull((goal) => goal['id'] == goalId);
      
      if (goalToDelete != null) {
        goals.removeWhere((goal) => goal['id'] == goalId);
        await _saveGoals();
        
        Get.snackbar(
          '🗑️ حذف شد',
          'هدف "${goalToDelete['name']}" حذف شد',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        
        print('🗑️ Goal deleted: ${goalToDelete['name']}');
        
        // اگر همه اهداف حذف شدند، نمونه اضافه کن
        if (goals.isEmpty) {
          await Future.delayed(const Duration(milliseconds: 300));
          _initializeSampleGoals();
        }
      }
    } catch (e) {
      print('❌ Error deleting goal: $e');
      Get.snackbar(
        '❌ خطا',
        'خطا در حذف هدف',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ... بقیه متدها (همانند قبل)
  // ========== Helper Methods ==========
  
  double getProgress(Map<String, dynamic> goal) {
    try {
      final target = (goal['targetAmount'] as num).toDouble();
      final current = (goal['currentAmount'] as num).toDouble();
      return target > 0 ? current / target : 0;
    } catch (e) {
      return 0;
    }
  }
  
  Color getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
  
  int getDaysLeft(Map<String, dynamic> goal) {
    try {
      final targetDate = DateTime.parse(goal['targetDate']);
      final difference = targetDate.difference(DateTime.now());
      return difference.inDays;
    } catch (e) {
      return 0;
    }
  }
  
  bool isCompleted(Map<String, dynamic> goal) {
    return getProgress(goal) >= 1;
  }
  
  bool isOverdue(Map<String, dynamic> goal) {
    return !isCompleted(goal) && getDaysLeft(goal) < 0;
  }

  // ========== Getters ==========
  
  List<Map<String, dynamic>> get activeGoals {
    try {
      return goals.where((goal) => !isCompleted(goal)).toList();
    } catch (e) {
      return [];
    }
  }
  
  List<Map<String, dynamic>> get completedGoals {
    try {
      return goals.where((goal) => isCompleted(goal)).toList();
    } catch (e) {
      return [];
    }
  }
  
  List<Map<String, dynamic>> get overdueGoals {
    try {
      return goals.where((goal) => isOverdue(goal)).toList();
    } catch (e) {
      return [];
    }
  }
  
  double get totalTargetAmount {
    try {
      return goals.fold(0.0, (sum, goal) => 
        sum + ((goal['targetAmount'] as num).toDouble()));
    } catch (e) {
      return 0.0;
    }
  }
  
  double get totalCurrentAmount {
    try {
      return goals.fold(0.0, (sum, goal) => 
        sum + ((goal['currentAmount'] as num).toDouble()));
    } catch (e) {
      return 0.0;
    }
  }
  
  double get totalRemainingAmount {
    return totalTargetAmount - totalCurrentAmount;
  }
  
  double get overallProgress {
    return totalTargetAmount > 0 ? totalCurrentAmount / totalTargetAmount : 0;
  }
}