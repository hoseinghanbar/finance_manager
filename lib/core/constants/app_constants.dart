class AppConstants {
  static const String appName = 'مدیریت مالی';
  static const String appVersion = '1.0.0';
  static const String storageBox = 'finance_app';
  static const String currencySymbol = 'تومان';
  
  // کلیدهای ذخیره‌سازی
  static const String themeKey = 'app_theme';
  static const String currencyKey = 'selected_currency';
  static const String userNameKey = 'user_name';
  
  // مقادیر پیش‌فرض
  static const int defaultTransactionLimit = 50;
  static const double defaultBudgetAlertPercentage = 90.0;
}

class AppRoutes {
  static const String home = '/';
  static const String payments = '/payments';
  static const String goals = '/goals';
  static const String reports = '/reports';
  static const String statistics = '/statistics';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String addTransaction = '/add-transaction';
  static const String addGoal = '/add-goal';
  static const String editTransaction = '/edit-transaction';
  static const String editGoal = '/edit-goal';
  static const String notFound = '/not-found';
}

class AssetPaths {
  static const String logo = 'assets/images/logo.png';
  static const String splash = 'assets/images/splash.png';
  static const String emptyState = 'assets/images/empty_state.png';
  static const String success = 'assets/images/success.png';
}