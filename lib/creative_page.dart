// lib/creative_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class CreativePage extends StatefulWidget {
  const CreativePage({super.key});

  @override
  State<CreativePage> createState() => _CreativePageState();
}

class _CreativePageState extends State<CreativePage> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  int _selectedTimeFilter = 0;
  double _progressValue = 0.75;
  bool _isExpanded = false;

  final List<Map<String, dynamic>> _creativeStats = [
    {'title': 'خلاقیت', 'value': 87, 'color': Colors.purple, 'icon': Icons.lightbulb},
    {'title': 'پیشرفت', 'value': 64, 'color': Colors.blue, 'icon': Icons.trending_up},
    {'title': 'تیم', 'value': 92, 'color': Colors.green, 'icon': Icons.people},
    {'title': 'کیفیت', 'value': 78, 'color': Colors.orange, 'icon': Icons.workspace_premium},
  ];

  final List<Map<String, dynamic>> _timeFilters = [
    {'label': 'امروز', 'icon': Icons.today},
    {'label': 'هفته', 'icon': Icons.calendar_view_week},
    {'label': 'ماه', 'icon': Icons.calendar_today},
    {'label': 'سال', 'icon': Icons.auto_awesome},
  ];

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // هدر با افکت شیشه‌ای
              _buildGlassHeader(),
              const SizedBox(height: 20),
              
              // کارت‌های آماری با انیمیشن
              _buildAnimatedStatsGrid(),
              const SizedBox(height: 25),
              
              // نمودار سه بعدی خلاق
              _build3DChartSection(),
              const SizedBox(height: 25),
              
              // پیشرفت پروژه
              _buildProgressSection(),
              const SizedBox(height: 25),
              
              // گالری خلاقیت
              _buildCreativeGallery(),
              const SizedBox(height: 25),
              
              // فیلترهای زمان
              _buildTimeFilters(),
              const SizedBox(height: 25),
              
              // کارت‌های تعاملی
              _buildInteractiveCards(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      
      // دکمه شناور با انیمیشن
      floatingActionButton: _buildAnimatedFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildGlassHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // آواتار با انیمیشن چرخشی
          RotationTransition(
            turns: _rotationController,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const SweepGradient(
                  colors: [Colors.purple, Colors.blue, Colors.green, Colors.orange, Colors.purple],
                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: Color(0xFF0F0F23),
                child: Icon(Icons.rocket_launch, color: Colors.white, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: const Text(
                        "خلاقیت نامحدود!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  "امروز روز خلق شاهکارهاست",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatsGrid() {
    return AnimationLimiter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: _creativeStats.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 800),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _creativeStats[index]['color'].withOpacity(0.3),
                        _creativeStats[index]['color'].withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _creativeStats[index]['color'].withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _creativeStats[index]['icon'],
                        color: _creativeStats[index]['color'],
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _creativeStats[index]['title'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_creativeStats[index]['value']}%',
                        style: TextStyle(
                          color: _creativeStats[index]['color'],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _build3DChartSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "نمودار خلاقیت 3D",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.auto_awesome, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.transparent),
                ),
                minX: 0,
                maxX: 11,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(2.6, 2),
                      FlSpot(4.9, 5),
                      FlSpot(6.8, 3.1),
                      FlSpot(8, 4),
                      FlSpot(9.5, 3),
                      FlSpot(11, 4),
                    ],
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Colors.purple.withOpacity(0.3), Colors.purple.withOpacity(0.1)],
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(2.6, 3.5),
                      FlSpot(4.9, 2.5),
                      FlSpot(6.8, 4.5),
                      FlSpot(8, 2),
                      FlSpot(9.5, 5),
                      FlSpot(11, 3),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue.withOpacity(0.3), Colors.blue.withOpacity(0.1)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "پیشرفت پروژه خلاق",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                height: 12,
                width: MediaQuery.of(context).size.width * 0.7 * _progressValue,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(_progressValue * 100).toInt()}% تکمیل شده",
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                "${((1 - _progressValue) * 100).toInt()}% باقی مانده",
                style: TextStyle(color: Colors.white.withOpacity(0.5)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildProgressChip("طراحی", 0.9, Colors.green),
              _buildProgressChip("توسعه", 0.7, Colors.blue),
              _buildProgressChip("تست", 0.4, Colors.orange),
              _buildProgressChip("مستندات", 0.6, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChip(String label, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Text(
            "${(progress * 100).toInt()}%",
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCreativeGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "گالری خلاقیت",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 100,
                margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      [Colors.purple, Colors.blue, Colors.green, Colors.orange, Colors.pink][index]
                          .withOpacity(0.6),
                      [Colors.purple, Colors.blue, Colors.green, Colors.orange, Colors.pink][index]
                          .withOpacity(0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: [Colors.purple, Colors.blue, Colors.green, Colors.orange, Colors.pink][index]
                          .withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      [Icons.palette, Icons.code, Icons.brush, Icons.architecture, Icons.rocket_launch][index],
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ["طراحی", "کد", "هنر", "معماری", "پرتاب"][index],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "فیلتر زمانی",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _timeFilters.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTimeFilter = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(left: index == 0 ? 0 : 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: _selectedTimeFilter == index
                        ? const LinearGradient(
                            colors: [Colors.purple, Colors.blue],
                          )
                        : LinearGradient(
                            colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                          ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedTimeFilter == index
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _timeFilters[index]['icon'],
                        color: _selectedTimeFilter == index ? Colors.white : Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeFilters[index]['label'],
                        style: TextStyle(
                          color: _selectedTimeFilter == index ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.2), Colors.purple.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "کارت‌های تعاملی",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.touch_app, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: _isExpanded ? 120 : 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "کارت تعاملی خلاق",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "این یک کارت کاملاً تعاملی با انیمیشن‌های پیشرفته است! می‌تونی کلیک کنی و ببینی چه اتفاقی می‌افته...",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFAB() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: _isExpanded ? 200 : 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.purple, Colors.blue],
        ),
        borderRadius: BorderRadius.circular(_isExpanded ? 30 : 50),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: _isExpanded
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "خلاقیت فعال شد!",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            )
          : const Icon(Icons.add, color: Colors.white),
    );
  }
}