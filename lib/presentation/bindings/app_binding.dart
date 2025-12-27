// lib/presentation/bindings/app_binding.dart
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../controllers/payment_reminder_controller.dart';
import '../controllers/savings_goals_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    print('🚀 شروع AppBinding');
    
    // 🔥 ثبت همه کنترلرها با Get.put (نه lazyPut)
    // 1. TransactionController
    _registerController<TransactionController>(
      () => TransactionController(),
      'TransactionController',
    );
    
    // 2. PaymentReminderController
    _registerController<PaymentReminderController>(
      () => PaymentReminderController(),
      'PaymentReminderController',
    );
    
    // 3. SavingsGoalsController 🔥 مهم
    _registerController<SavingsGoalsController>(
      () => SavingsGoalsController(),
      'SavingsGoalsController',
    );
  }
  
  void _registerController<T>(
    T Function() builder,
    String name,
  ) {
    try {
      if (!Get.isRegistered<T>()) {
        print('🔄 ثبت $name...');
        // 🔥 حتما permanent: true
        Get.put<T>(builder(), permanent: true);
        print('✅ $name با موفقیت ثبت شد');
      } else {
        print('⚠️ $name قبلاً ثبت شده است');
      }
    } catch (e) {
      print('❌ خطا در ثبت $name: $e');
      // تلاش مجدد
      Get.put<T>(builder(), permanent: true);
    }
  }
}

// 🔥 کلاس کمکی برای دسترسی ایمن
class AppControllers {
  // متد عمومی برای دسترسی ایمن
  static T get<T>() {
    try {
      return Get.find<T>();
    } catch (e) {
      print('❌ خطا در دریافت کنترلر: $e');
      print('🔄 تلاش برای ثبت اضطراری...');
      
      // ثبت اضطراری بر اساس نوع
      if (T == SavingsGoalsController) {
        Get.put(SavingsGoalsController(), permanent: true);
        return Get.find<T>();
      }
      throw Exception('کنترلر ${T.toString()} یافت نشد');
    }
  }
  
  // متدهای سریع دسترسی
  static SavingsGoalsController get savingsGoals => get<SavingsGoalsController>();
  static TransactionController get transaction => get<TransactionController>();
  static PaymentReminderController get paymentReminder => get<PaymentReminderController>();
}