// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// تم
import 'core/themes/app_theme.dart';

// Binding
import 'presentation/bindings/app_binding.dart';

// صفحات
import 'presentation/screens/home_screen.dart';

void main() async {
  // راه‌اندازی اولیه
  WidgetsFlutterBinding.ensureInitialized();
  
  // راه‌اندازی GetStorage
  await GetStorage.init();
  
  // 🔥🔥🔥 ابتدا GetX را راه‌اندازی می‌کنیم
  Get.reset(); // ریست GetX
  Get.testMode = false; // غیرفعال کردن حالت تست
  
  // اجرای برنامه
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'مدیریت مالی',
      debugShowCheckedModeBanner: false,
      
      // تم
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.system,
      
      // زبان فارسی
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [
        Locale('fa', 'IR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // راست‌چین
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      
      // 🔥🔥🔥 استفاده از GetPages به جای home مستقیم
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => HomeScreen(),
          binding: AppBinding(), // 🔥 Binding مستقیماً اینجا
        ),
      ],
    );
  }
}