// lib/presentation/screens/reports_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:fl_chart/fl_chart.dart';
import 'package:get_storage/get_storage.dart';

// کنترلرها
import '../controllers/transaction_controller.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedIndex = -1;
  String _selectedTimeRange = 'ماه جاری';
  String _selectedChartType = 'دایره‌ای';
  bool _isLoading = false;
  
  // کنترلر اصلی
  late TransactionController _controller;
  final GetStorage _storage = GetStorage();

  // رنگ‌ها
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _cardColor = Colors.white;
  final Color _textColor = const Color(0xFF212529);
  final Color _subtextColor = const Color(0xFF6C757D);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _dangerColor = const Color(0xFFF44336);
  final Color _infoColor = const Color(0xFF2196F3);

  // داده‌ها
  final List<ChartData> _expensesData = [];
  double _totalExpense = 0.0;
  double _totalIncome = 0.0;
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeController().then((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    try {
      _controller = Get.find<TransactionController>();
    } catch (e) {
      // اگر کنترلر پیدا نشد، آن را بساز و ثبت کن
      _controller = TransactionController();
      Get.put(_controller, permanent: true);
    }
    
    // منتظر بمانید تا کنترلر مقداردهی شود
    await Future.delayed(const Duration(milliseconds: 100));
    
    // داده‌ها را بارگذاری کن
    await _refreshTransactions();
  }

  Future<void> _refreshTransactions() async {
    try {
      // استفاده از متدهای موجود در کنترلر
      // ممکن است متدهای مختلفی در کنترلر شما وجود داشته باشد
      
      // روش ۱: اگر متد fetchTransactions یا getAllTransactions وجود دارد
      if (_controller.transactions.isEmpty) {
        // بررسی کنید چه متدهایی در کنترلر شما موجود است
        // اینها ممکن است در کنترلر شما متفاوت باشند
        if (_controller.hasListeners) {
          // کنترلر GetX معمولا به صورت خودکار آپدیت می‌شود
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (e) {
      print('خطا در بارگذاری تراکنش‌ها: $e');
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // ابتدا مطمئن شوید کنترلر مقداردهی شده است
      if (!Get.isRegistered<TransactionController>()) {
        await _initializeController();
      }
      
      // منتظر بمانید تا کنترلر آماده شود
      await Future.delayed(const Duration(milliseconds: 300));
      
      // محاسبه داده‌ها
      _calculateAllData();
      
      setState(() {
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('خطا در بارگذاری داده‌ها: $e');
    }
  }

  void _calculateAllData() {
    try {
      // پاک کردن داده‌های قبلی
      _expensesData.clear();
      _totalExpense = 0.0;
      _totalIncome = 0.0;
      _balance = 0.0;
      
      // محاسبه داده‌های هزینه
      _calculateExpensesData();
      
      // محاسبه مجموع‌ها
      _calculateTotals();
      
    } catch (e) {
      print('❌ خطا در محاسبه داده‌ها: $e');
    }
  }

  void _calculateExpensesData() {
    try {
      print('📊 تعداد تراکنش‌های موجود: ${_controller.transactions.length}');
      
      // برای دیباگ: نمایش ۵ تراکنش اول
      if (_controller.transactions.isNotEmpty) {
        for (int i = 0; i < (_controller.transactions.length > 5 ? 5 : _controller.transactions.length); i++) {
          final trans = _controller.transactions[i];
          print('   تراکنش $i: ${trans.category} - ${trans.amount} - ${trans.type}');
        }
      }
      
      final Map<String, double> categoryTotals = {};
      
      // محاسبه مجموع هر دسته‌بندی برای هزینه‌ها
      for (final trans in _controller.transactions) {
        try {
          final amount = trans.amount;
          
          // تبدیل مقدار به double
          double amountValue;
          if (amount is int) {
            amountValue = amount.toDouble();
          } else if (amount is double) {
            amountValue = amount;
          } else {
            amountValue = double.tryParse(amount.toString()) ?? 0.0;
          }
          
          // اگر مقدار منفی است (هزینه) یا type برابر expense است
          bool isExpense = false;
          
          // بررسی بر اساس type اگر وجود دارد
          if (trans.type != null) {
            isExpense = trans.type!.toLowerCase().contains('expense') || 
                       trans.type!.toLowerCase().contains('هزینه');
          } 
          // اگر type ندارد، بر اساس مقدار منفی بررسی کن
          else if (amountValue < 0) {
            isExpense = true;
          }
          
          if (isExpense) {
            final category = trans.category ?? 'سایر';
            final absAmount = amountValue.abs();
            
            // اضافه کردن به مجموع دسته‌بندی
            categoryTotals.update(
              category, 
              (value) => value + absAmount,
              ifAbsent: () => absAmount
            );
          }
        } catch (e) {
          print('خطا در پردازش تراکنش: $e');
          continue;
        }
      }
      
      print('📊 تعداد دسته‌بندی‌های هزینه: ${categoryTotals.length}');
      
      // 🔥 تبدیل به لیست ChartData و مرتب‌سازی
      _expensesData.addAll(
        categoryTotals.entries.map((e) => ChartData(
          name: e.key,
          value: e.value,
          color: _getCategoryColor(e.key),
        ))
      );
      
      // مرتب‌سازی بر اساس مقدار
      _expensesData.sort((a, b) => b.value.compareTo(a.value));
      
      print('📊 اولین دسته‌بندی: ${_expensesData.isNotEmpty ? _expensesData[0].name : "خالی"}');
      print('📊 مجموع مقادیر: ${_expensesData.fold<double>(0.0, (sum, item) => sum + item.value)}');
      
    } catch (e) {
      print('❌ خطا در محاسبه داده‌های هزینه: $e');
    }
  }

  void _calculateTotals() {
    try {
      // محاسبه کل هزینه‌ها
      _totalExpense = _expensesData.fold<double>(0.0, (sum, item) => sum + item.value);
      
      // محاسبه درآمد کل (جمع مقادیر مثبت یا type=income)
      _totalIncome = _controller.transactions.fold<double>(0.0, (sum, trans) {
        try {
          final amount = trans.amount;
          double amountValue;
          if (amount is int) {
            amountValue = amount.toDouble();
          } else if (amount is double) {
            amountValue = amount;
          } else {
            amountValue = double.tryParse(amount.toString()) ?? 0.0;
          }
          
          bool isIncome = false;
          
          // بررسی بر اساس type اگر وجود دارد
          if (trans.type != null) {
            isIncome = trans.type!.toLowerCase().contains('income') || 
                      trans.type!.toLowerCase().contains('درآمد');
          } 
          // اگر type ندارد، بر اساس مقدار مثبت بررسی کن
          else if (amountValue > 0) {
            isIncome = true;
          }
          
          return isIncome ? sum + amountValue.abs() : sum;
        } catch (e) {
          return sum;
        }
      });
      
      // محاسبه مانده
      _balance = _totalIncome - _totalExpense;
      
      print('💰 کل هزینه: $_totalExpense');
      print('💰 کل درآمد: $_totalIncome');
      print('💰 مانده: $_balance');
      
    } catch (e) {
      print('❌ خطا در محاسبه مجموع: $e');
    }
  }

  // ========== Utility Methods ==========

  String _formatCurrency(double amount) {
    try {
      if (amount.isInfinite || amount.isNaN) return '۰ تومان';
      return '${intl.NumberFormat.decimalPattern('fa').format(amount)} تومان';
    } catch (e) {
      return '${amount.toStringAsFixed(0)} تومان';
    }
  }

  Color _getCategoryColor(String category) {
    final Map<String, Color> colors = {
      'خوراک': const Color(0xFFFF6B6B),
      'غذا': const Color(0xFFFF6B6B),
      'رستوران': const Color(0xFFE57373),
      'حمل‌ونقل': const Color(0xFF4ECDC4),
      'سوخت': const Color(0xFFFF8A65),
      'تاکسی': const Color(0xFFA1887F),
      'مسکن': const Color(0xFF45B7D1),
      'اجاره': const Color(0xFF29B6F6),
      'قبض': const Color(0xFF81D4FA),
      'تفریح': const Color(0xFF96CEB4),
      'سرگرمی': const Color(0xFFCE93D8),
      'خرید': const Color(0xFF98D8AA),
      'پوشاک': const Color(0xFF9575CD),
      'سلامت': const Color(0xFFFFEAA7),
      'درمان': const Color(0xFF5C6BC0),
      'آموزش': const Color(0xFFDDA0DD),
      'حقوق': Colors.green,
      'درآمد': Colors.green,
      'سایر': const Color(0xFF9E9E9E),
      'متفرقه': const Color(0xFF9E9E9E),
    };
    return colors[category] ?? Colors.primaries[category.hashCode % Colors.primaries.length];
  }

  // ========== UI Components ==========

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'در حال بارگذاری گزارش...',
            style: TextStyle(color: _subtextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          Text(
            'داده‌ای برای نمایش وجود ندارد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _subtextColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'برای مشاهده گزارش، ابتدا تراکنشی ثبت کنید',
            style: TextStyle(color: _subtextColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // هدایت به صفحه اضافه کردن تراکنش
              Get.toNamed('/add-transaction');
            },
            icon: const Icon(Icons.add),
            label: const Text('اضافه کردن تراکنش جدید'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ========== Chart Components ==========

  Widget _buildChartTypeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, size: 20, color: _primaryColor),
              const SizedBox(width: 8),
              Text('نوع نمودار:', style: TextStyle(fontWeight: FontWeight.bold, color: _textColor)),
            ],
          ),
          Row(
            children: ['دایره‌ای', 'میله‌ای'].map((type) {
              final isSelected = _selectedChartType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedChartType = type),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? _primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? _primaryColor : Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        type == 'دایره‌ای' ? Icons.pie_chart : Icons.bar_chart,
                        size: 14,
                        color: isSelected ? Colors.white : _subtextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : _textColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    if (_expensesData.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              Text(
                'هزینه‌ای برای نمایش وجود ندارد',
                style: TextStyle(color: _subtextColor),
              ),
            ],
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions || 
                  pieTouchResponse == null || 
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: _buildPieChartSections(),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    
    for (int i = 0; i < _expensesData.length; i++) {
      final item = _expensesData[i];
      final isTouched = i == _touchedIndex;
      final percentage = _totalExpense > 0 ? (item.value / _totalExpense * 100) : 0;
      
      sections.add(
        PieChartSectionData(
          color: item.color,
          value: item.value,
          title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
          radius: isTouched ? 55 : 50,
          titleStyle: TextStyle(
            fontSize: isTouched ? 14 : 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.6,
        ),
      );
    }
    return sections;
  }

  Widget _buildBarChart() {
    if (_expensesData.isEmpty) {
      return SizedBox(
        height: 250,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              Text(
                'هزینه‌ای برای نمایش وجود ندارد',
                style: TextStyle(color: _subtextColor),
              ),
            ],
          ),
        ),
      );
    }

    final displayData = _expensesData.take(6).toList();
    final maxValue = displayData.fold<double>(0.0, (max, item) => item.value > max ? item.value : max);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: _primaryColor.withOpacity(0.9),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${displayData[groupIndex].name}\n${_formatCurrency(rod.toY)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < displayData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: 50,
                      child: Text(
                        displayData[index].name,
                        style: TextStyle(
                          fontSize: 10,
                          color: _subtextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        barGroups: displayData.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value,
                width: 22,
                color: entry.value.color,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCurrentChart() {
    return SizedBox(
      height: 250,
      child: _selectedChartType == 'دایره‌ای' ? _buildPieChart() : _buildBarChart(),
    );
  }

  // ========== Stats Components ==========

  Widget _buildStatsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'آمار کلی مالی',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('درآمد', _totalIncome, _successColor, Icons.trending_up),
              _buildStatItem('هزینه', _totalExpense, _dangerColor, Icons.trending_down),
              _buildStatItem('مانده', _balance, 
                _balance >= 0 ? _infoColor : Colors.orange,
                _balance >= 0 ? Icons.account_balance_wallet : Icons.warning),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatCurrency(amount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: _subtextColor,
          ),
        ),
      ],
    );
  }

  // ========== Categories List ==========

  Widget _buildCategoriesList() {
    if (_expensesData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            'دسته‌بندی هزینه‌ای ثبت نشده است',
            style: TextStyle(color: _subtextColor),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list, color: _primaryColor),
              const SizedBox(width: 8),
              Text(
                'جزئیات هزینه‌ها',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._expensesData.map((item) => _buildCategoryItem(item)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(ChartData item) {
    final percentage = _totalExpense > 0 ? (item.value / _totalExpense * 100) : 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: item.color, width: 2),
            ),
            child: Center(
              child: Text(
                item.name.substring(0, 1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: item.color.withOpacity(0.1),
                  color: item.color,
                  minHeight: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(item.value),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: _subtextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== تب اول - خلاصه ==========

  Widget _buildSummaryTab() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_controller.transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔥 آمار کلی
            _buildStatsSummary(),
            const SizedBox(height: 20),
            
            // 🔥 انتخاب نوع نمودار
            _buildChartTypeSelector(),
            const SizedBox(height: 16),
            
            // 🔥 نمودار
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'توزیع هزینه‌ها',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'کل هزینه: ${_formatCurrency(_totalExpense)}',
                    style: TextStyle(color: _subtextColor),
                  ),
                  const SizedBox(height: 16),
                  _buildCurrentChart(),
                  const SizedBox(height: 16),
                  
                  // راهنما
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _primaryColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, size: 20, color: _primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'برای مشاهده جزئیات هر بخش، روی آن کلیک کنید',
                            style: TextStyle(
                              fontSize: 12,
                              color: _subtextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 🔥 لیست دسته‌بندی‌ها
            _buildCategoriesList(),
            const SizedBox(height: 20),
            
            // 🔥 اطلاعات اضافی
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'اطلاعات تکمیلی',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem('تعداد تراکنش‌ها', '${_controller.transactions.length}'),
                  _buildInfoItem('تعداد دسته‌بندی‌ها', '${_expensesData.length}'),
                  _buildInfoItem('میانگین هزینه', _formatCurrency(_totalExpense / (_expensesData.length > 0 ? _expensesData.length : 1))),
                  _buildInfoItem('آخرین به‌روزرسانی', _formatDateTime(DateTime.now())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: _subtextColor),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
        ],
      )
      );
      
  }

  String _formatDateTime(DateTime date) {
    try {
      final formatter = intl.DateFormat('yyyy/MM/dd - HH:mm', 'fa_IR');
      return formatter.format(date);
    } catch (e) {
      return '${date.year}/${date.month}/${date.day}';
    }
  }

  // ========== تب دوم - تحلیل ==========

  Widget _buildAnalysisTab() {
    if (_isLoading) {
      return _buildLoadingIndicator();
    }

    if (_controller.transactions.isEmpty) {
      return _buildEmptyState();
    }

    // محاسبه شاخص‌های مالی
    final savingsRate = _totalIncome > 0 ? ((_totalIncome - _totalExpense) / _totalIncome * 100) : 0.0;
    final expenseRatio = _totalIncome > 0 ? (_totalExpense / _totalIncome * 100) : 0.0;
    final averageDailyExpense = _totalExpense / 30;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: _primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'تحلیل مالی',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // شاخص‌های کلیدی
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildAnalysisCard(
                        'نرخ پس‌انداز',
                        '${savingsRate.toStringAsFixed(1)}%',
                        savingsRate >= 20 ? _successColor : savingsRate >= 10 ? Colors.orange : _dangerColor,
                        Icons.savings,
                      ),
                      _buildAnalysisCard(
                        'نسبت هزینه',
                        '${expenseRatio.toStringAsFixed(1)}%',
                        expenseRatio <= 70 ? _successColor : expenseRatio <= 85 ? Colors.orange : _dangerColor,
                        Icons.compare_arrows,
                      ),
                      _buildAnalysisCard(
                        'میانگین روزانه',
                        _formatCurrency(averageDailyExpense),
                        _primaryColor,
                        Icons.calendar_today,
                      ),
                      _buildAnalysisCard(
                        'تعداد دسته‌بندی',
                        '${_expensesData.length}',
                        _infoColor,
                        Icons.category,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // توصیه‌های مالی
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'توصیه‌های مالی',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // تولید توصیه‌ها
                  ..._generateFinancialAdvice(savingsRate, expenseRatio),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String value, Color color, IconData icon) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: _subtextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _generateFinancialAdvice(double savingsRate, double expenseRatio) {
    final List<Widget> advice = [];

    if (savingsRate < 10) {
      advice.add(_buildAdviceItem(
        'افزایش پس‌انداز',
        'سعی کنید حداقل ۱۰-۲۰٪ از درآمد خود را پس‌انداز کنید.',
        Icons.warning,
        Colors.orange,
      ));
    }

    if (expenseRatio > 80) {
      advice.add(_buildAdviceItem(
        'کنترل هزینه‌ها',
        'هزینه‌های شما بیش از ۸۰٪ درآمد است. صرفه‌جویی کنید.',
        Icons.money_off,
        _dangerColor,
      ));
    }

    if (_totalExpense > _totalIncome * 0.5) {
      advice.add(_buildAdviceItem(
        'مدیریت هزینه‌ها',
        'بیش از نیمی از درآمد شما صرف هزینه‌ها می‌شود.',
        Icons.schedule,
        _primaryColor,
      ));
    }

    if (advice.isEmpty) {
      advice.add(_buildAdviceItem(
        'اوضاع مالی مطلوب',
        'به مدیریت مالی خود ادامه دهید. وضعیت مالی شما خوب است.',
        Icons.thumb_up,
        _successColor,
      ));
    }

    return advice;
  }

  Widget _buildAdviceItem(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: _subtextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== Main Build ==========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('📊 گزارش‌های مالی'),
        centerTitle: true,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'تازه‌سازی',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: _cardColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: _primaryColor,
              labelColor: _primaryColor,
              unselectedLabelColor: _subtextColor,
              tabs: const [
                Tab(icon: Icon(Icons.summarize), text: 'خلاصه'),
                Tab(icon: Icon(Icons.analytics), text: 'تحلیل'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildAnalysisTab(),
        ],
      ),
    );
  }
}

// مدل داده نمودار
class ChartData {
  final String name;
  final double value;
  final Color color;
  
  ChartData({
    required this.name,
    required this.value,
    required this.color,
  });
}