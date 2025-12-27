import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  // ========== متغیرهای اصلی ==========
  final GetStorage _storage = GetStorage();
  
  // حالت فعلی تم
  final Rx<ThemeMode> _currentTheme = ThemeMode.system.obs;
  
  // رنگ‌های تم روشن
  final Map<String, Color> _lightThemeColors = {
    'primary': const Color(0xFF2196F3),      // آبی
    'secondary': const Color(0xFF4CAF50),    // سبز
    'accent': const Color(0xFFFF9800),       // نارنجی
    'background': const Color(0xFFF5F5F5),   // خاکستری روشن
    'surface': Colors.white,
    'error': const Color(0xFFF44336),        // قرمز
    'onPrimary': Colors.white,
    'onSecondary': Colors.white,
    'onBackground': Colors.black,
    'onSurface': Colors.black,
    'onError': Colors.white,
  };
  
  // رنگ‌های تم تاریک
  final Map<String, Color> _darkThemeColors = {
    'primary': const Color(0xFF64B5F6),      // آبی روشن
    'secondary': const Color(0xFF81C784),    // سبز روشن
    'accent': const Color(0xFFFFB74D),       // نارنجی روشن
    'background': const Color(0xFF121212),   // سیاه
    'surface': const Color(0xFF1E1E1E),      // خاکستری تیره
    'error': const Color(0xFFEF5350),        // قرمز روشن
    'onPrimary': Colors.black,
    'onSecondary': Colors.black,
    'onBackground': Colors.white,
    'onSurface': Colors.white,
    'onError': Colors.black,
  };
  
  // ========== گت‌ترها ==========
  
  // حالت فعلی تم
  ThemeMode get currentThemeMode => _currentTheme.value;
  
  // آیا تم تاریک است؟
  bool get isDarkMode {
    if (_currentTheme.value == ThemeMode.system) {
      return Get.isDarkMode;
    }
    return _currentTheme.value == ThemeMode.dark;
  }
  
  // آیا تم روشن است؟
  bool get isLightMode => !isDarkMode;
  
  // آیا تم سیستم انتخاب شده؟
  bool get isSystemTheme => _currentTheme.value == ThemeMode.system;
  
  // رنگ‌های فعلی
  Map<String, Color> get currentColors {
    return isDarkMode ? _darkThemeColors : _lightThemeColors;
  }
  
  // رنگ اصلی فعلی
  Color get primaryColor => currentColors['primary']!;
  
  // رنگ پس‌زمینه فعلی
  Color get backgroundColor => currentColors['background']!;
  
  // ========== متدهای چرخه حیات ==========
  
  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
    _setupThemeListener();
  }
  
  @override
  void onClose() {
    super.onClose();
  }
  
  // ========== متدهای داخلی ==========
  
  // بارگذاری تم ذخیره شده
  Future<void> _loadSavedTheme() async {
    try {
      final savedTheme = _storage.read<String>('app_theme_mode');
      
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _currentTheme.value = ThemeMode.light;
            break;
          case 'dark':
            _currentTheme.value = ThemeMode.dark;
            break;
          case 'system':
            _currentTheme.value = ThemeMode.system;
            break;
          default:
            _currentTheme.value = ThemeMode.system;
        }
      } else {
        // اگر اولین بار است، از حالت سیستم استفاده کن
        _currentTheme.value = ThemeMode.system;
      }
      
      // اعمال تم
      _applyTheme();
    } catch (e) {
      debugPrint('❌ خطا در بارگذاری تم: $e');
      _currentTheme.value = ThemeMode.system;
    }
  }
  
  // ذخیره تم
  Future<void> _saveTheme(ThemeMode theme) async {
    try {
      String themeString;
      switch (theme) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      
      await _storage.write('app_theme_mode', themeString);
    } catch (e) {
      debugPrint('❌ خطا در ذخیره تم: $e');
    }
  }
  
  // اعمال تم روی برنامه
  void _applyTheme() {
    if (_currentTheme.value == ThemeMode.system) {
      Get.changeThemeMode(ThemeMode.system);
    } else if (_currentTheme.value == ThemeMode.light) {
      Get.changeThemeMode(ThemeMode.light);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
    }
    
    // آپدیت UI
    update();
  }
  
  // تنظیم شنود تغییرات سیستم
  void _setupThemeListener() {
    // اگر کاربر تم سیستم را انتخاب کرد، به تغییرات سیستم گوش کن
    if (_currentTheme.value == ThemeMode.system) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // اینجا می‌توانید برای گوش دادن به تغییرات سیستم کد بنویسید
      });
    }
  }
  
  // ========== متدهای عمومی ==========
  
  // تغییر تم
  Future<void> changeTheme(ThemeMode newTheme) async {
    try {
      _currentTheme.value = newTheme;
      await _saveTheme(newTheme);
      _applyTheme();
      
      // نمایش پیام موفقیت
      _showThemeChangeSuccess(newTheme);
    } catch (e) {
      debugPrint('❌ خطا در تغییر تم: $e');
      _showThemeChangeError(e.toString());
    }
  }
  
  // تغییر به تم روشن
  Future<void> switchToLightTheme() async {
    await changeTheme(ThemeMode.light);
  }
  
  // تغییر به تم تاریک
  Future<void> switchToDarkTheme() async {
    await changeTheme(ThemeMode.dark);
  }
  
  // تغییر به تم سیستم
  Future<void> switchToSystemTheme() async {
    await changeTheme(ThemeMode.system);
  }
  
  // تغییر وضعیت تم (روشن/تاریک)
  Future<void> toggleTheme() async {
    if (_currentTheme.value == ThemeMode.light) {
      await switchToDarkTheme();
    } else if (_currentTheme.value == ThemeMode.dark) {
      await switchToLightTheme();
    } else {
      // اگر سیستم است، بر اساس وضعیت فعلی تغییر کن
      if (Get.isDarkMode) {
        await switchToLightTheme();
      } else {
        await switchToDarkTheme();
      }
    }
  }
  
  // دریافت نام تم فعلی
  String getCurrentThemeName() {
    switch (_currentTheme.value) {
      case ThemeMode.light:
        return 'روشن';
      case ThemeMode.dark:
        return 'تاریک';
      case ThemeMode.system:
        return 'سیستم';
    }
  }
  
  // دریافت آیکون تم فعلی
  IconData getCurrentThemeIcon() {
    switch (_currentTheme.value) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings;
    }
  }
  
  // ========== متدهای کمکی UI ==========
  
  // نمایش پیام موفقیت تغییر تم
  void _showThemeChangeSuccess(ThemeMode theme) {
    String message;
    IconData icon;
    
    switch (theme) {
      case ThemeMode.light:
        message = '🌞 تم روشن فعال شد';
        icon = Icons.light_mode;
        break;
      case ThemeMode.dark:
        message = '🌙 تم تاریک فعال شد';
        icon = Icons.dark_mode;
        break;
      case ThemeMode.system:
        message = '⚙️ تم سیستم فعال شد';
        icon = Icons.settings;
        break;
    }
    
    Get.rawSnackbar(
      message: message,
      backgroundColor: isDarkMode ? Colors.green.shade800 : Colors.green.shade600,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(icon, color: Colors.white),
      shouldIconPulse: true,
    );
  }
  
  // نمایش خطای تغییر تم
  void _showThemeChangeError(String error) {
    Get.rawSnackbar(
      message: '❌ خطا در تغییر تم',
      backgroundColor: Colors.red.shade600,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }
  
  // ========== ایجاد تم سفارشی ==========
  
  // دریافت ThemeData برای تم روشن
  ThemeData getLightTheme() {
    return ThemeData(
      useMaterial3: true, // استفاده از Material 3
      
      // رنگ اصلی - استفاده از ColorScheme
      colorScheme: ColorScheme.light(
        primary: _lightThemeColors['primary']!,
        secondary: _lightThemeColors['secondary']!,
        tertiary: _lightThemeColors['accent']!, // accent در Material 3 به tertiary تغییر کرده
        surface: _lightThemeColors['surface']!,
        background: _lightThemeColors['background']!,
        error: _lightThemeColors['error']!,
        onPrimary: _lightThemeColors['onPrimary']!,
        onSecondary: _lightThemeColors['onSecondary']!,
        onSurface: _lightThemeColors['onSurface']!,
        onBackground: _lightThemeColors['onBackground']!,
        onError: _lightThemeColors['onError']!,
      ),
      
      // رنگ‌های اضافی
      scaffoldBackgroundColor: _lightThemeColors['background']!,
      cardColor: _lightThemeColors['surface']!,
      dialogBackgroundColor: _lightThemeColors['surface']!,
      
      // دکمه‌ها - استفاده از ButtonStyle
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightThemeColors['primary']!,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 2,
        ),
      ),
      
      // دکمه‌های outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightThemeColors['primary']!,
          side: BorderSide(color: _lightThemeColors['primary']!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      // دکمه‌های متنی
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightThemeColors['primary']!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // آپ‌بار
      appBarTheme: AppBarTheme(
        backgroundColor: _lightThemeColors['surface']!,
        foregroundColor: _lightThemeColors['onSurface']!,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.1),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _lightThemeColors['onSurface']!,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: _lightThemeColors['onSurface']!),
      ),
      
      // کارت‌ها - اصلاح شده: استفاده از CardThemeData
      cardTheme: CardThemeData(
        color: _lightThemeColors['surface']!,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      
      // ورودی‌ها
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightThemeColors['primary']!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightThemeColors['error']!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _lightThemeColors['error']!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        errorStyle: TextStyle(color: _lightThemeColors['error']!),
      ),
      
      // تایپوگرافی
      fontFamily: 'Vazir', // فونت فارسی
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _lightThemeColors['onBackground']!,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _lightThemeColors['onBackground']!,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _lightThemeColors['onBackground']!,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: _lightThemeColors['onBackground']!,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _lightThemeColors['onBackground']!,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _lightThemeColors['onBackground']!,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      
      // آیکون‌ها
      iconTheme: IconThemeData(
        color: _lightThemeColors['onBackground']!,
        size: 24,
      ),
      
      // دایوردرها
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 0,
      ),
      
      // انیمیشن‌ها
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: _lightThemeColors['primary']!,
        unselectedLabelColor: Colors.grey.shade600,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _lightThemeColors['primary']!.withOpacity(0.1),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _lightThemeColors['primary']!,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  // دریافت ThemeData برای تم تاریک
  ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true, // استفاده از Material 3
      
      // رنگ اصلی - استفاده از ColorScheme
      colorScheme: ColorScheme.dark(
        primary: _darkThemeColors['primary']!,
        secondary: _darkThemeColors['secondary']!,
        tertiary: _darkThemeColors['accent']!, // accent در Material 3 به tertiary تغییر کرده
        surface: _darkThemeColors['surface']!,
        background: _darkThemeColors['background']!,
        error: _darkThemeColors['error']!,
        onPrimary: _darkThemeColors['onPrimary']!,
        onSecondary: _darkThemeColors['onSecondary']!,
        onSurface: _darkThemeColors['onSurface']!,
        onBackground: _darkThemeColors['onBackground']!,
        onError: _darkThemeColors['onError']!,
      ),
      
      // رنگ‌های اضافی
      scaffoldBackgroundColor: _darkThemeColors['background']!,
      cardColor: _darkThemeColors['surface']!,
      dialogBackgroundColor: _darkThemeColors['surface']!,
      
      // دکمه‌ها - استفاده از ButtonStyle
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkThemeColors['primary']!,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 2,
        ),
      ),
      
      // دکمه‌های outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkThemeColors['primary']!,
          side: BorderSide(color: _darkThemeColors['primary']!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      
      // دکمه‌های متنی
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkThemeColors['primary']!,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      
      // آپ‌بار
      appBarTheme: AppBarTheme(
        backgroundColor: _darkThemeColors['surface']!,
        foregroundColor: _darkThemeColors['onSurface']!,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _darkThemeColors['onSurface']!,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: _darkThemeColors['onSurface']!),
      ),
      
      // کارت‌ها - اصلاح شده: استفاده از CardThemeData
      cardTheme: CardThemeData(
        color: _darkThemeColors['surface']!,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      
      // ورودی‌ها
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade700!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkThemeColors['primary']!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkThemeColors['error']!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _darkThemeColors['error']!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: Colors.grey.shade400),
        hintStyle: TextStyle(color: Colors.grey.shade500),
        errorStyle: TextStyle(color: _darkThemeColors['error']!),
      ),
      
      // تایپوگرافی
      fontFamily: 'Vazir', // فونت فارسی
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: _darkThemeColors['onBackground']!,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _darkThemeColors['onBackground']!,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _darkThemeColors['onBackground']!,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: _darkThemeColors['onBackground']!,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _darkThemeColors['onBackground']!,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _darkThemeColors['onBackground']!,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade500,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      
      // آیکون‌ها
      iconTheme: IconThemeData(
        color: _darkThemeColors['onBackground']!,
        size: 24,
      ),
      
      // دایوردرها
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade700,
        thickness: 1,
        space: 0,
      ),
      
      // انیمیشن‌ها
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      
      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: _darkThemeColors['primary']!,
        unselectedLabelColor: Colors.grey.shade400,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _darkThemeColors['primary']!.withOpacity(0.2),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _darkThemeColors['primary']!,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  // ========== متدهای کاربردی ==========
  
  // تنظیم رنگ‌های سفارشی
  void setCustomColors({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? background,
    Color? surface,
    bool isDarkMode = false,
  }) {
    if (isDarkMode) {
      if (primary != null) _darkThemeColors['primary'] = primary;
      if (secondary != null) _darkThemeColors['secondary'] = secondary;
      if (accent != null) _darkThemeColors['accent'] = accent;
      if (background != null) _darkThemeColors['background'] = background;
      if (surface != null) _darkThemeColors['surface'] = surface;
    } else {
      if (primary != null) _lightThemeColors['primary'] = primary;
      if (secondary != null) _lightThemeColors['secondary'] = secondary;
      if (accent != null) _lightThemeColors['accent'] = accent;
      if (background != null) _lightThemeColors['background'] = background;
      if (surface != null) _lightThemeColors['surface'] = surface;
    }
    
    // آپدیت UI
    update();
  }
  
  // ریست کردن به تنظیمات پیش‌فرض
  Future<void> resetToDefault() async {
    // ریست رنگ‌های روشن
    _lightThemeColors['primary'] = const Color(0xFF2196F3);
    _lightThemeColors['secondary'] = const Color(0xFF4CAF50);
    _lightThemeColors['accent'] = const Color(0xFFFF9800);
    _lightThemeColors['background'] = const Color(0xFFF5F5F5);
    _lightThemeColors['surface'] = Colors.white;
    
    // ریست رنگ‌های تاریک
    _darkThemeColors['primary'] = const Color(0xFF64B5F6);
    _darkThemeColors['secondary'] = const Color(0xFF81C784);
    _darkThemeColors['accent'] = const Color(0xFFFFB74D);
    _darkThemeColors['background'] = const Color(0xFF121212);
    _darkThemeColors['surface'] = const Color(0xFF1E1E1E);
    
    // بازگشت به تم سیستم
    await changeTheme(ThemeMode.system);
    
    _showSuccess('✅ تنظیمات تم به حالت پیش‌فرض بازگشت');
  }
  
  // نمایش موفقیت
  void _showSuccess(String message) {
    Get.rawSnackbar(
      message: message,
      backgroundColor: isDarkMode ? Colors.green.shade800 : Colors.green.shade600,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }
  
  // گرفتن رنگ بر اساس کلید
  Color? getColor(String key) {
    return currentColors[key];
  }
  
  // چک کردن اینکه آیا رنگ‌ها ذخیره شده‌اند
  Future<bool> hasSavedTheme() async {
    return _storage.read('app_theme_mode') != null;
  }
  
  // گرفتن تاریخ آخرین تغییر
  Future<DateTime?> getLastThemeChangeDate() async {
    final date = _storage.read('last_theme_change_date');
    return date != null ? DateTime.parse(date) : null;
  }
  
  // ذخیره تاریخ آخرین تغییر
  Future<void> _saveLastChangeDate() async {
    await _storage.write('last_theme_change_date', DateTime.now().toIso8601String());
  }
}