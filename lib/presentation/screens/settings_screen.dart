// lib/presentation/screens/settings_screen.dart
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;

// کنترلرهای اصلی
import '../controllers/transaction_controller.dart';
import '../controllers/payment_reminder_controller.dart';
import '../controllers/savings_goals_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> 
    with SingleTickerProviderStateMixin {
  final GetStorage _storage = GetStorage();
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // تنظیمات
  late bool _notificationsEnabled;
  late bool _biometricAuth;
  late String _currency;
  late String _language;
  late bool _autoBackup;
  late bool _analyticsEnabled;
  late bool _monthlyReports;
  late bool _soundEnabled;
  late bool _vibrationEnabled;
  late bool _darkMode;
  late bool _showSampleData;
  late bool _autoSync;
  late bool _showTips;
  late bool _autoCategorize;
  late bool _cloudSync;
  late bool _dataEncryption;
  late bool _dailyReminders;
  late String _backupFrequency;
  late String _exportFormat;
  
  File? _profileImage;
  String _userName = 'کاربر مالی';
  String _userEmail = 'user@example.com';
  String _appVersion = '2.1.0';
  String _lastBackupDate = 'هرگز';
  String _appSize = '45.2 MB';
  String _dataSize = 'در حال محاسبه...';
  
  // لیست برای مدیریت تنظیمات پیشرفته
  final List<Map<String, dynamic>> _advancedSettings = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 600)
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _loadSettings();
    _loadProfileInfo();
    _initAdvancedSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initAdvancedSettings() {
    _advancedSettings.addAll([
      {
        'title': 'همگام‌سازی ابری',
        'subtitle': 'همگام‌سازی خودکار با سرور ابری',
        'type': 'switch',
        'key': 'cloud_sync',
        'value': false,
        'icon': Icons.cloud,
        'color': Colors.blue,
      },
      {
        'title': 'رمزنگاری داده‌ها',
        'subtitle': 'رمزنگاری پیشرفته برای امنیت بیشتر',
        'type': 'switch',
        'key': 'data_encryption',
        'value': true,
        'icon': Icons.lock,
        'color': Colors.green,
      },
      {
        'title': 'دسته‌بندی خودکار',
        'subtitle': 'تشخیص خودکار دسته‌بندی تراکنش‌ها',
        'type': 'switch',
        'key': 'auto_categorize',
        'value': true,
        'icon': Icons.category,
        'color': Colors.purple,
      },
      {
        'title': 'یادآوری روزانه',
        'subtitle': 'یادآوری ثبت تراکنش‌های روزانه',
        'type': 'switch',
        'key': 'daily_reminders',
        'value': true,
        'icon': Icons.notifications,
        'color': Colors.orange,
      },
      {
        'title': 'فرکانس پشتیبان',
        'subtitle': 'دفعات پشتیبان‌گیری خودکار',
        'type': 'dropdown',
        'key': 'backup_frequency',
        'value': 'هفتگی',
        'options': ['روزانه', 'هفتگی', 'ماهانه', 'هیچگاه'],
        'icon': Icons.backup,
        'color': Colors.teal,
      },
      {
        'title': 'فرمت خروجی',
        'subtitle': 'فرمت فایل‌های صادراتی',
        'type': 'dropdown',
        'key': 'export_format',
        'value': 'JSON',
        'options': ['JSON', 'CSV', 'Excel', 'PDF'],
        'icon': Icons.insert_drive_file,
        'color': Colors.indigo,
      },
    ]);
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(1024)).floor();
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  void _loadProfileInfo() {
    final savedName = _storage.read('user_name');
    final savedEmail = _storage.read('user_email');
    final savedImagePath = _storage.read('profile_image_path');
    final lastBackup = _storage.read('last_backup_date');

    if (savedName != null) _userName = savedName;
    if (savedEmail != null) _userEmail = savedEmail;
    if (lastBackup != null) {
      try {
        _lastBackupDate = intl.DateFormat.yMd('fa').format(DateTime.parse(lastBackup));
      } catch (e) {
        _lastBackupDate = lastBackup.toString();
      }
    }
    if (savedImagePath != null && savedImagePath is String) {
      final file = File(savedImagePath);
      if (file.existsSync()) {
        _profileImage = file;
      }
    }
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _storage.read('notifications_enabled') ?? true;
      _biometricAuth = _storage.read('biometric_auth') ?? false;
      _currency = _storage.read('currency') ?? 'تومان';
      _language = _storage.read('language') ?? 'فارسی';
      _autoBackup = _storage.read('auto_backup') ?? true;
      _analyticsEnabled = _storage.read('analytics_enabled') ?? true;
      _monthlyReports = _storage.read('monthly_reports') ?? true;
      _soundEnabled = _storage.read('sound_enabled') ?? true;
      _vibrationEnabled = _storage.read('vibration_enabled') ?? true;
      _darkMode = _storage.read('dark_mode') ?? false;
      _showSampleData = _storage.read('show_sample_data') ?? true;
      _autoSync = _storage.read('auto_sync') ?? false;
      _showTips = _storage.read('show_tips') ?? true;
      _cloudSync = _storage.read('cloud_sync') ?? false;
      _dataEncryption = _storage.read('data_encryption') ?? true;
      _autoCategorize = _storage.read('auto_categorize') ?? true;
      _dailyReminders = _storage.read('daily_reminders') ?? true;
      _backupFrequency = _storage.read('backup_frequency') ?? 'هفتگی';
      _exportFormat = _storage.read('export_format') ?? 'JSON';
    });
  }

  void _saveSetting<T>(String key, T value) {
    _storage.write(key, value);
  }

  // ========== Profile ==========

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        _saveSetting('profile_image_path', image.path);
        _showSuccess('تصویر پروفایل تغییر کرد');
      }
    } catch (e) {
      _showError('خطا در انتخاب تصویر');
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('ویرایش پروفایل', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: _profileImage != null 
                          ? FileImage(_profileImage!) as ImageProvider
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 60, color: Colors.blue.shade700)
                          : null,
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'نام کامل',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'ایمیل',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(), 
            child: const Text('انصراف')
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) {
                _showError('نام نمی‌تواند خالی باشد');
                return;
              }
              setState(() {
                _userName = nameController.text.trim();
                _userEmail = emailController.text.trim();
              });
              _saveSetting('user_name', _userName);
              _saveSetting('user_email', _userEmail);
              Get.back();
              _showSuccess('پروفایل به‌روزرسانی شد');
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  // ========== پاک‌سازی کامل ==========

  Future<void> _clearAllData() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 32),
            SizedBox(width: 12),
            Text('پاک‌سازی کامل', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'همه داده‌های زیر پاک خواهند شد:\n\n'
                '• تمام تراکنش‌های مالی\n'
                '• اهداف پس‌انداز\n'
                '• یادآوری پرداخت‌ها\n'
                '• گزارش‌ها و تحلیل‌ها\n'
                '• موجودی و حساب‌ها\n\n'
                '⚠️ این عمل غیرقابل بازگشت است!',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تنها تنظیمات برنامه باقی خواهند ماند',
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false), 
            child: const Text('لغو')
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('پاک‌سازی کامل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // 1. پاک کردن داده‌های storage
      final allKeys = _storage.getKeys();
      final dataKeys = allKeys.where((key) => 
        !key.startsWith('settings_') && 
        key != 'user_name' && 
        key != 'user_email' && 
        key != 'profile_image_path' &&
        key != 'language' &&
        key != 'currency' &&
        key != 'theme_mode' &&
        key != 'first_run'
      ).toList();

      for (final key in dataKeys) {
        _storage.remove(key);
      }

      // 2. ریست کردن کنترلرها
      try {
        final transactionController = Get.find<TransactionController>();
        // ریست کردن مقادیر
        transactionController.totalIncome.value = 0.0;
        transactionController.totalExpense.value = 0.0;
        transactionController.balance.value = 0.0;
        
        // پاک کردن لیست تراکنش‌ها
        if (transactionController.transactions is List) {
          (transactionController.transactions as List).clear();
        }
        
        // فراخوانی متد ریفرش اگر وجود دارد
        if (transactionController.refresh is Function) {
          transactionController.refresh();
        }
      } catch (e) {
        print('خطا در ریست کردن کنترلر تراکنش: $e');
      }

      try {
        final paymentController = Get.find<PaymentReminderController>();
        if (paymentController.payments is List) {
          (paymentController.payments as List).clear();
        }
        if (paymentController.refresh is Function) {
          paymentController.refresh();
        }
      } catch (e) {
        print('خطا در ریست کردن کنترلر یادآوری: $e');
      }

      try {
        final goalsController = Get.find<SavingsGoalsController>();
        if (goalsController.goals is List) {
          (goalsController.goals as List).clear();
        }
        if (goalsController.refresh is Function) {
          goalsController.refresh();
        }
      } catch (e) {
        print('خطا در ریست کردن کنترلر اهداف: $e');
      }

      await Future.delayed(const Duration(milliseconds: 1000));

      Get.back();

      Get.defaultDialog(
        title: '✅ پاک‌سازی کامل',
        content: Column(
          children: [
            Icon(Icons.check_circle, size: 60, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'تمامی داده‌های مالی با موفقیت پاک شدند.\n\n'
              'برنامه اکنون مانند اولین روز نصب است.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed('/');
            },
            child: const Text('بازگشت به خانه'),
          ),
        ],
      );

    } catch (e) {
      Get.back();
      _showError('خطا در پاک‌سازی: ${e.toString()}');
    }
  }

  // ========== پاک‌سازی انتخابی ==========

  Future<void> _selectiveClearData() async {
    final selectedItems = <String>[];

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('پاک‌سازی انتخابی', textAlign: TextAlign.center),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildClearOption(
                    'تراکنش‌ها',
                    'تمام تراکنش‌های مالی',
                    Icons.receipt,
                    selectedItems.contains('transactions'),
                    (val) {
                      setState(() {
                        if (val) {
                          selectedItems.add('transactions');
                        } else {
                          selectedItems.remove('transactions');
                        }
                      });
                    },
                  ),
                  _buildClearOption(
                    'اهداف پس‌انداز',
                    'تمام اهداف و پس‌اندازها',
                    Icons.savings,
                    selectedItems.contains('goals'),
                    (val) {
                      setState(() {
                        if (val) {
                          selectedItems.add('goals');
                        } else {
                          selectedItems.remove('goals');
                        }
                      });
                    },
                  ),
                  _buildClearOption(
                    'یادآوری‌ها',
                    'یادآوری پرداخت‌ها',
                    Icons.notifications,
                    selectedItems.contains('reminders'),
                    (val) {
                      setState(() {
                        if (val) {
                          selectedItems.add('reminders');
                        } else {
                          selectedItems.remove('reminders');
                        }
                      });
                    },
                  ),
                  _buildClearOption(
                    'گزارش‌ها',
                    'گزارش‌های تاریخی',
                    Icons.analytics,
                    selectedItems.contains('reports'),
                    (val) {
                      setState(() {
                        if (val) {
                          selectedItems.add('reports');
                        } else {
                          selectedItems.remove('reports');
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('انصراف'),
              ),
              ElevatedButton(
                onPressed: selectedItems.isEmpty ? null : () => _executeSelectiveClear(selectedItems),
                child: const Text('پاک‌سازی انتخاب‌ها'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClearOption(String title, String subtitle, IconData icon, bool selected, Function(bool) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      secondary: Icon(icon, color: selected ? Colors.blue : Colors.grey),
      value: selected,
      onChanged: (val) => onChanged(val ?? false),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Future<void> _executeSelectiveClear(List<String> items) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      for (final item in items) {
        switch (item) {
          case 'transactions':
            try {
              final tc = Get.find<TransactionController>();
              if (tc.transactions is List) {
                (tc.transactions as List).clear();
              }
              tc.totalIncome.value = 0.0;
              tc.totalExpense.value = 0.0;
              tc.balance.value = 0.0;
              if (tc.refresh is Function) {
                tc.refresh();
              }
              _storage.remove('transactions');
            } catch (e) {
              print('خطا در پاک کردن تراکنش‌ها: $e');
            }
            break;
            
          case 'goals':
            try {
              final gc = Get.find<SavingsGoalsController>();
              if (gc.goals is List) {
                (gc.goals as List).clear();
              }
              if (gc.refresh is Function) {
                gc.refresh();
              }
              _storage.remove('goals');
            } catch (e) {
              print('خطا در پاک کردن اهداف: $e');
            }
            break;
            
          case 'reminders':
            try {
              final pc = Get.find<PaymentReminderController>();
              if (pc.payments is List) {
                (pc.payments as List).clear();
              }
              if (pc.refresh is Function) {
                pc.refresh();
              }
              _storage.remove('reminders');
            } catch (e) {
              print('خطا در پاک کردن یادآوری‌ها: $e');
            }
            break;
            
          case 'reports':
            _storage.remove('reports');
            _storage.remove('monthly_reports');
            _storage.remove('analytics_data');
            break;
        }
      }

      await Future.delayed(const Duration(milliseconds: 800));
      Get.back();

      _showSuccess('${items.length} مورد با موفقیت پاک شدند');

    } catch (e) {
      Get.back();
      _showError('خطا در پاک‌سازی انتخابی: $e');
    }
  }

  // ========== ریست برنامه ==========

  Future<void> _resetApp() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restart_alt, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Text('بازنشانی برنامه', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'تمام داده‌ها و تنظیمات پاک می‌شوند و برنامه به حالت اولیه بازمی‌گردد.\n\n'
            'برنامه مانند روز اول نصب خواهد بود.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('بازنشانی کامل', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // 1. پاک کردن کامل storage
      await _storage.erase();

      // 2. ریست کردن کنترلرها
      try {
        Get.delete<TransactionController>(force: true);
      } catch (e) {
        print('خطا در حذف کنترلر تراکنش: $e');
      }
      
      try {
        Get.delete<PaymentReminderController>(force: true);
      } catch (e) {
        print('خطا در حذف کنترلر یادآوری: $e');
      }
      
      try {
        Get.delete<SavingsGoalsController>(force: true);
      } catch (e) {
        print('خطا در حذف کنترلر اهداف: $e');
      }

      await Future.delayed(const Duration(seconds: 2));

      Get.back();

      // بازگشت به صفحه splash یا لاگین
      Get.offAllNamed('/welcome');

    } catch (e) {
      Get.back();
      _showError('خطا در بازنشانی: $e');
    }
  }

  // ========== پشتیبان‌گیری ==========

  Future<void> _createBackup() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      await Future.delayed(const Duration(seconds: 1));

      // ساخت داده‌های پشتیبان
      final Map<String, dynamic> backupData = {
        'backup_info': {
          'app': 'مالی من',
          'version': _appVersion,
          'created_at': DateTime.now().toIso8601String(),
          'user': _userName,
        },
        'settings': {
          'currency': _currency,
          'language': _language,
          'notifications': _notificationsEnabled,
          'auto_backup': _autoBackup,
          'monthly_reports': _monthlyReports,
          'dark_mode': _darkMode,
        }
      };

      final jsonData = const JsonEncoder.withIndent('  ').convert(backupData);
      
      Get.back();

      // اشتراک‌گذاری فایل پشتیبان
      await Share.share(
        '🔐 پشتیبان برنامه مالی من\n\n'
        '📅 تاریخ: ${DateTime.now().toLocal()}\n'
        '👤 کاربر: $_userName\n'
        '📱 نسخه: $_appVersion\n\n'
        '--- تنظیمات پشتیبان شده ---\n\n'
        '$jsonData\n\n'
        '⚠️ این فایل حاوی تنظیمات برنامه است.',
        subject: 'پشتیبان مالی من - ${DateTime.now().toString()}',
      );

      // ذخیره تاریخ آخرین پشتیبان
      _saveSetting('last_backup_date', DateTime.now().toIso8601String());
      setState(() {
        _lastBackupDate = intl.DateFormat.yMd('fa').format(DateTime.now());
      });

      _showSuccess('پشتیبان‌گیری با موفقیت انجام شد');

    } catch (e) {
      Get.back();
      _showError('خطا در ایجاد پشتیبان: $e');
    }
  }

  // ========== UI Helpers ==========

  void _showSuccess(String message) {
    Get.snackbar(
      '✅ موفقیت', 
      message, 
      backgroundColor: Colors.green, 
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      '❌ خطا', 
      message, 
      backgroundColor: Colors.red, 
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('⚙️ تنظیمات پیشرفته'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.blue.shade700,
      actions: [
        IconButton(
          icon: const Icon(Icons.backup, color: Colors.blue),
          onPressed: _createBackup,
          tooltip: 'پشتیبان‌گیری',
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _editProfile,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3), 
                blurRadius: 20, 
                offset: const Offset(0, 10)
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: _profileImage != null 
                        ? FileImage(_profileImage!) as ImageProvider
                        : null,
                    child: _profileImage == null 
                        ? const Icon(Icons.person, size: 50, color: Colors.white) 
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.edit, 
                        size: 18, 
                        color: Colors.blue.shade600
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName, 
                      style: const TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white
                      )
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail, 
                      style: TextStyle(
                        fontSize: 14, 
                        color: Colors.white.withOpacity(0.9)
                      )
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.backup, size: 14, color: Colors.white.withOpacity(0.8)),
                        const SizedBox(width: 6),
                        Text(
                          'آخرین پشتیبان: $_lastBackupDate',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right, 
                color: Colors.white, 
                size: 30
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(String title, IconData icon, List<Widget> children, {Color? color}) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 5)
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color ?? Colors.blue.shade600, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title, 
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: color ?? Colors.blue.shade600,
                    )
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value, Function(bool) onChanged, String storageKey) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      value: value,
      activeColor: Colors.blue,
      onChanged: (val) {
        setState(() => onChanged(val));
        _saveSetting(storageKey, val);
      },
    );
  }

  Widget _buildDropdownItem(String title, String subtitle, String value, List<String> options, Function(String) onChanged, String storageKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                    _saveSetting(storageKey, newValue);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, Color color, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.red : Colors.black,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildAdvancedSettingItem(Map<String, dynamic> setting) {
    if (setting['type'] == 'switch') {
      return _buildSwitchItem(
        setting['title'],
        setting['subtitle'],
        setting['value'] as bool,
        (val) {
          setState(() {
            setting['value'] = val;
          });
          _saveSetting(setting['key'] as String, val);
        },
        setting['key'] as String,
      );
    } else if (setting['type'] == 'dropdown') {
      return _buildDropdownItem(
        setting['title'] as String,
        setting['subtitle'] as String,
        setting['value'] as String,
        (setting['options'] as List).cast<String>(),
        (val) {
          setState(() {
            setting['value'] = val;
          });
          _saveSetting(setting['key'] as String, val);
        },
        setting['key'] as String,
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileCard(),

            // تنظیمات پیشرفته
            _buildSettingCard('⚙️ تنظیمات پیشرفته', Icons.settings, [
              ..._advancedSettings.map(_buildAdvancedSettingItem).toList(),
            ], color: Colors.indigo),

            // مدیریت داده‌ها
            _buildSettingCard('🗃️ مدیریت داده‌ها', Icons.manage_accounts, [
              _buildActionItem(
                'پاک‌سازی انتخابی',
                'حذف بخش‌های خاص از داده‌ها',
                Icons.cleaning_services,
                Colors.teal,
                _selectiveClearData,
              ),
              _buildActionItem(
                'ایجاد پشتیبان',
                'ذخیره تنظیمات در فایل',
                Icons.cloud_upload,
                Colors.green,
                _createBackup,
              ),
              const Divider(),
              _buildActionItem(
                'پاک‌سازی کامل داده‌ها',
                'حذف تمام تراکنش‌ها و داده‌های مالی',
                Icons.delete_forever,
                Colors.red,
                _clearAllData,
                isDanger: true,
              ),
              _buildActionItem(
                'بازنشانی کامل برنامه',
                'حذف همه چیز و شروع مجدد',
                Icons.restart_alt,
                Colors.orange,
                _resetApp,
                isDanger: true,
              ),
            ], color: Colors.red),

            // تنظیمات عمومی
            _buildSettingCard('🔔 تنظیمات عمومی', Icons.settings_applications, [
              _buildSwitchItem(
                'اعلان‌ها',
                'یادآوری پرداخت‌ها و اهداف',
                _notificationsEnabled,
                (val) => setState(() => _notificationsEnabled = val),
                'notifications_enabled',
              ),
              _buildSwitchItem(
                'گزارش ماهانه',
                'ارسال گزارش ماهانه عملکرد',
                _monthlyReports,
                (val) => setState(() => _monthlyReports = val),
                'monthly_reports',
              ),
              _buildSwitchItem(
                'حالت تاریک',
                'استفاده از تم تاریک',
                _darkMode,
                (val) => setState(() => _darkMode = val),
                'dark_mode',
              ),
              _buildSwitchItem(
                'پشتیبان خودکار',
                'ذخیره خودکار در فضای ابری',
                _autoBackup,
                (val) => setState(() => _autoBackup = val),
                'auto_backup',
              ),
            ]),

            // امنیت و حریم خصوصی
            _buildSettingCard('🔒 امنیت و حریم خصوصی', Icons.security, [
              _buildSwitchItem(
                'قفل بیومتریک',
                'ورود با اثر انگعت یا چهره',
                _biometricAuth,
                (val) => setState(() => _biometricAuth = val),
                'biometric_auth',
              ),
              _buildSwitchItem(
                'رمزنگاری داده‌ها',
                'محافظت پیشرفته از داده‌ها',
                _dataEncryption,
                (val) => setState(() => _dataEncryption = val),
                'data_encryption',
              ),
              _buildActionItem(
                'تغییر رمز عبور',
                'تغییر رمز عبور برنامه',
                Icons.lock,
                Colors.blue,
                () => _showInfo('این قابلیت در نسخه بعدی اضافه خواهد شد'),
              ),
              _buildActionItem(
                'سیاست حفظ حریم خصوصی',
                'مشاهده سیاست‌های برنامه',
                Icons.privacy_tip,
                Colors.indigo,
                () => _launchUrl('https://yourapp.com/privacy'),
              ),
            ]),

            // پشتیبانی و درباره
            _buildSettingCard('ℹ️ پشتیبانی و درباره', Icons.help, [
              _buildActionItem(
                'تماس با پشتیبانی',
                'ارسال پیام به تیم پشتیبانی',
                Icons.support_agent,
                Colors.purple,
                () => _launchUrl('mailto:support@financeapp.com'),
              ),
              _buildActionItem(
                'امتیازدهی در فروشگاه',
                'امتیاز دادن به برنامه',
                Icons.star,
                Colors.amber,
                () => _launchUrl('https://play.google.com/store/apps/details?id=com.yourapp'),
              ),
              _buildActionItem(
                'اشتراک‌گذاری برنامه',
                'معرفی برنامه به دوستان',
                Icons.share,
                Colors.green,
                _shareApp,
              ),
            ]),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'نکته مهم',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'قبل از پاک‌سازی کامل، حتماً از داده‌های خود پشتیبان بگیرید.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'مالی من • نسخه $_appVersion',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'توسعه‌یافته با ❤️ در ایران',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© ۲۰۲۴ - تمامی حقوق محفوظ است',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showError('امکان باز کردن لینک وجود ندارد');
      }
    } catch (e) {
      _showError('خطا در باز کردن لینک: $e');
    }
  }

  Future<void> _shareApp() async {
    try {
      await Share.share(
        'اپلیکیشن مدیریت مالی "مالی من" رو امتحان کن! '
        'برنامه‌ای کامل و پیشرفته برای مدیریت تمام امور مالی شما.\n\n'
        '🌟 ویژگی‌های اصلی:\n'
        '✅ ثبت و دسته‌بندی تراکنش‌ها\n'
        '✅ نمودارهای تحلیلی پیشرفته\n'
        '✅ اهداف پس‌انداز هوشمند\n'
        '✅ یادآوری پرداخت خودکار\n'
        '✅ گزارش‌های حرفه‌ای\n'
        '✅ پشتیبان‌گیری ابری\n'
        '✅ امنیت پیشرفته\n\n'
        '📱 برای اندروید و iOS\n'
        '🔗 دانلود: https://financeapp.com\n\n'
        '#مدیریت_مالی #برنامه_مالی #پس_انداز',
        subject: 'برنامه مالی من - مدیریت مالی هوشمند',
      );
    } catch (e) {
      _showError('خطا در اشتراک‌گذاری');
    }
  }

  void _showInfo(String message) {
    Get.snackbar(
      'ℹ️ اطلاع', 
      message, 
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}