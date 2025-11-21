import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(useMaterial3: true),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF),
      body: Center(
        child: Lottie.asset('assets/lottie/home_loan.json', width: 340, height: 340),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text("سلام سمان جان!", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF4C1D95))),
              const Text("امروز عالی باش!", style: TextStyle(fontSize: 18, color: Color(0xFF6D28D9))),
              const SizedBox(height: 40),

              // سه کارت اصلی
              Row(
                children: [
                  Expanded(child: _infoCard("موجودی حساب", "۱۲,۷۵۰,۰۰۰ تومان", Icons.account_balance_wallet, const Color(0xFF8C9EFF), const Color(0xFF3D5AFE))),
                  const SizedBox(width: 16),
                  Expanded(child: _infoCard("قسط عقب‌افتاده", "۸,۴۰۰,۰۰۰ تومان", Icons.warning_amber_rounded, const Color(0xFFFF8A80), const Color(0xFFE53935))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _infoCard("قبض پرداخت‌نشده", "۶۸۰,۰۰۰ تومان", Icons.receipt_long, const Color(0xFFFFF59D), const Color(0xFFFF8F00))),
                  const SizedBox(width: 16),
                  Expanded(child: _infoCard("پس‌انداز ماه", "۱۴,۸۰۰,۰۰۰ تومان", Icons.savings, const Color(0xFFA5D6A7), const Color(0xFF4CAF50))),
                ],
              ),

              const SizedBox(height: 40),

              // موعد پرداخت‌های نزدیک
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("موعد پرداخت‌های نزدیک", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4C1D95))),
                    const SizedBox(height: 20),
                    _dueItem("قسط بانک ملت", "۳ روز دیگر", "۲,۱۰۰,۰۰۰ تومان", Icons.account_balance, const Color(0xFFE91E63)),
                    const SizedBox(height: 16),
                    _dueItem("قبض برق", "۵ روز دیگر", "۳۸۰,۰۰۰ تومان", Icons.electric_bolt, const Color(0xFFFF9800)),
                    const SizedBox(height: 16),
                    _dueItem("قسط دیجی‌پی", "۷ روز دیگر", "۱,۸۰۰,۰۰۰ تومان", Icons.phone_android, const Color(0xFF4CAF50)),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // منوی پایین ساده
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4C1D95),
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "خانه"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "کارت‌ها"),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: "تراکنش"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: "گزارش"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "تنظیمات"),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String amount, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: bgColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: iconColor),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 6),
          Text(amount, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _dueItem(String title, String days, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(days, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}