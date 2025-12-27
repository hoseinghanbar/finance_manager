import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/transaction_controller.dart';
import '../../data/models/transaction_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TransactionController _controller = Get.find<TransactionController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  String _searchQuery = '';
  List<Transaction> _searchResults = [];
  bool _isSearching = false;
  String _selectedFilter = 'همه'; // 'همه', 'درآمد', 'هزینه'
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ========== Search Methods ==========
  
  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query == _searchQuery) return;
    
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
    });
    
    _performSearch(query);
  }
  
  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    // جستجوی ابتدایی
    List<Transaction> results = _controller.transactions.where((transaction) {
      final matchesQuery = transaction.title.toLowerCase().contains(query.toLowerCase()) ||
                          transaction.category.toLowerCase().contains(query.toLowerCase()) ||
                          (transaction.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
                          transaction.amount.toString().contains(query);
      
      // اعمال فیلتر نوع
      if (_selectedFilter == 'درآمد' && !transaction.isIncome) return false;
      if (_selectedFilter == 'هزینه' && !transaction.isExpense) return false;
      
      // اعمال فیلتر تاریخ
      if (_dateRange != null) {
        final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
        final startDate = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
        final endDate = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);
        
        if (transactionDate.isBefore(startDate) || transactionDate.isAfter(endDate)) {
          return false;
        }
      }
      
      return matchesQuery;
    }).toList();
    
    // مرتب‌سازی بر اساس تاریخ (جدیدترین اول)
    results.sort((a, b) => b.date.compareTo(a.date));
    
    setState(() {
      _searchResults = results;
    });
  }
  
  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
    setState(() {
      _searchQuery = '';
      _searchResults = [];
      _isSearching = false;
    });
  }
  
  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _performSearch(_searchQuery);
  }
  
  Future<void> _selectDateRange() async {
    final initialDateRange = _dateRange ?? DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      locale: const Locale('fa', 'IR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _performSearch(_searchQuery);
    }
  }
  
  void _clearDateFilter() {
    setState(() {
      _dateRange = null;
    });
    _performSearch(_searchQuery);
  }

  // ========== Helper Methods ==========
  
  String _formatCurrency(double amount) {
    return NumberFormat.decimalPattern('fa').format(amount);
  }
  
  Color _getTransactionColor(Transaction transaction) {
    return transaction.isIncome ? Colors.green : Colors.red;
  }
  
  IconData _getTransactionIcon(Transaction transaction) {
    return transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward;
  }
  
  String _formatDateRange() {
    if (_dateRange == null) return 'تمام تاریخ‌ها';
    
    final start = DateFormat('yyyy/MM/dd').format(_dateRange!.start);
    final end = DateFormat('yyyy/MM/dd').format(_dateRange!.end);
    
    return '$start تا $end';
  }

  // ========== UI Widgets ==========
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('🔍 جستجوی تراکنش‌ها'),
      centerTitle: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
        tooltip: 'بازگشت',
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: _buildSearchBar(),
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          // فیلد جستجو
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'جستجو در تراکنش‌ها...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(_searchQuery),
          ),
          
          const SizedBox(height: 8),
          
          // فیلترها
          Row(
            children: [
              // فیلتر نوع
              PopupMenuButton<String>(
                icon: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _selectedFilter,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                onSelected: _applyFilter,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'همه',
                    child: Row(
                      children: [
                        Icon(Icons.all_inclusive, size: 18),
                        SizedBox(width: 8),
                        Text('همه'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'درآمد',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text('درآمد'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'هزینه',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('هزینه'),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              
              // فیلتر تاریخ
              OutlinedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.calendar_month, size: 18),
                label: Text(
                  _formatDateRange(),
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              ),
              
              if (_dateRange != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: _clearDateFilter,
                  tooltip: 'حذف فیلتر تاریخ',
                ),
              ],
              
              const Spacer(),
              
              // تعداد نتایج
              if (_isSearching)
                Text(
                  '${_searchResults.length} نتیجه',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'نتیجه‌ای یافت نشد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'هیچ تراکنشی مطابق با جستجوی شما یافت نشد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _clearSearch();
                _applyFilter('همه');
                _clearDateFilter();
              },
              child: const Text('حذف فیلترها'),
            ),
          ],
        ),
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'در تراکنش‌ها جستجو کنید',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'عنوان، دسته‌بندی، مبلغ یا توضیحات تراکنش را وارد کنید',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('خوراک'),
                onPressed: () {
                  _searchController.text = 'خوراک';
                  _performSearch('خوراک');
                },
                backgroundColor: Colors.grey.shade100,
              ),
              ActionChip(
                label: const Text('حقوق'),
                onPressed: () {
                  _searchController.text = 'حقوق';
                  _performSearch('حقوق');
                },
                backgroundColor: Colors.grey.shade100,
              ),
              ActionChip(
                label: const Text('خرید'),
                onPressed: () {
                  _searchController.text = 'خرید';
                  _performSearch('خرید');
                },
                backgroundColor: Colors.grey.shade100,
              ),
              ActionChip(
                label: const Text('این ماه'),
                onPressed: () {
                  _dateRange = DateTimeRange(
                    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
                    end: DateTime.now(),
                  );
                  _performSearch(_searchQuery);
                },
                backgroundColor: Colors.grey.shade100,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final transaction = _searchResults[index];
        return _buildTransactionItem(transaction);
      },
    );
  }
  
  Widget _buildTransactionItem(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getTransactionColor(transaction).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTransactionIcon(transaction),
            color: _getTransactionColor(transaction),
            size: 20,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  transaction.category,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTransactionColor(transaction).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.isIncome ? 'درآمد' : 'هزینه',
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTransactionColor(transaction),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (transaction.description != null) ...[
              const SizedBox(height: 4),
              Text(
                transaction.description!,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Text(
              transaction.formattedDateTime,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              transaction.amountWithSign,
              style: TextStyle(
                color: _getTransactionColor(transaction),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              transaction.timeAgo,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onTap: () => _showTransactionDetails(transaction),
        onLongPress: () => _showTransactionActions(transaction),
      ),
    );
  }
  
  void _showTransactionDetails(Transaction transaction) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // هدر
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTransactionColor(transaction).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getTransactionIcon(transaction),
                    color: _getTransactionColor(transaction),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction.category,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  transaction.amountWithSign,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTransactionColor(transaction),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // جزئیات
            _buildDetailRow('📅 تاریخ', transaction.formattedDateTime),
            _buildDetailRow('🕒 ثبت شده', transaction.timeAgo),
            _buildDetailRow('🏷️ نوع', transaction.isIncome ? 'درآمد' : 'هزینه'),
            
            if (transaction.description != null) ...[
              const SizedBox(height: 16),
              const Text(
                '📝 توضیحات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(transaction.description!),
            ],
            
            const SizedBox(height: 32),
            
            // دکمه‌ها
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text('بستن'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // ویرایش تراکنش
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('ویرایش'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
  
  void _showTransactionActions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: const Text('کپی اطلاعات'),
                onTap: () {
                  Get.back();
                  _copyTransactionInfo(transaction);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text('ویرایش تراکنش'),
                onTap: () {
                  Get.back();
                  // باز کردن صفحه ویرایش
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف تراکنش'),
                onTap: () {
                  Get.back();
                  _showDeleteConfirmation(transaction);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.purple),
                title: const Text('اشتراک‌گذاری'),
                onTap: () {
                  Get.back();
                  _shareTransaction(transaction);
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('لغو'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  void _copyTransactionInfo(Transaction transaction) {
    final info = '''
عنوان: ${transaction.title}
مبلغ: ${transaction.amountWithSign}
دسته‌بندی: ${transaction.category}
تاریخ: ${transaction.formattedDate}
نوع: ${transaction.isIncome ? 'درآمد' : 'هزینه'}
${transaction.description != null ? 'توضیحات: ${transaction.description!}' : ''}
''';
    
    // کپی به clipboard
    // Clipboard.setData(ClipboardData(text: info));
    
    Get.snackbar(
      '✅ کپی شد',
      'اطلاعات تراکنش کپی شد',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
  
  void _showDeleteConfirmation(Transaction transaction) {
    Get.dialog(
      AlertDialog(
        title: const Text('⚠️ حذف تراکنش'),
        content: Text(
          'آیا مطمئن هستید که می‌خواهید تراکنش "${transaction.title}" را حذف کنید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () {
              _controller.deleteTransaction(transaction.id);
              Get.back();
              Get.snackbar(
                '🗑️ حذف شد',
                'تراکنش با موفقیت حذف شد',
                backgroundColor: Colors.grey.shade700,
                colorText: Colors.white,
              );
              _performSearch(_searchQuery); // به‌روزرسانی نتایج
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _shareTransaction(Transaction transaction) {
    // اشتراک‌گذاری تراکنش
    Get.snackbar(
      '📤 اشتراک‌گذاری',
      'تراکنش برای اشتراک‌گذاری آماده شد',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }
  
  Widget _buildStatistics() {
    if (!_isSearching || _searchResults.isEmpty) return const SizedBox();
    
    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categoryTotals = {};
    
    for (final transaction in _searchResults) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
      
      categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0) + transaction.amount;
    }
    
    final totalBalance = totalIncome - totalExpense;
    final topCategory = categoryTotals.isNotEmpty 
        ? categoryTotals.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 آمار نتایج',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('تعداد', '${_searchResults.length}'),
              _buildStatItem('درآمد', _formatCurrency(totalIncome)),
              _buildStatItem('هزینه', _formatCurrency(totalExpense)),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (totalBalance != 0)
            Text(
              'سود/زیان: ${totalBalance > 0 ? '+' : ''}${_formatCurrency(totalBalance)}',
              style: TextStyle(
                color: totalBalance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          
          if (topCategory != null)
            Text(
              'پرخرج‌ترین دسته: ${topCategory.key} (${_formatCurrency(topCategory.value)})',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // ========== Main Build ==========
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // آمار
          _buildStatistics(),
          
          // نتایج
          Expanded(
            child: _isSearching && _searchResults.isNotEmpty
                ? _buildSearchResults()
                : _buildEmptyState(),
          ),
        ],
      ),
    );
  }
}