// // در صورت نیاز، این صفحه را برای تست ایجاد کنید
// // lib/presentation/screens/test_controllers_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/transaction_controller.dart';
// import '../../controllers/payment_reminder_controller.dart';
// import '../../bindings/app_binding.dart';

// class TestControllersScreen extends StatelessWidget {
//   const TestControllersScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تست کنترلرها'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildControllerStatus('TransactionController', 
//                 AppBinding.isControllerRegistered<TransactionController>()),
            
//             _buildControllerStatus('PaymentReminderController', 
//                 AppBinding.isControllerRegistered<PaymentReminderController>()),
            
//             const SizedBox(height: 20),
            
//             ElevatedButton(
//               onPressed: () {
//                 AppBinding.healthCheck().then((isHealthy) {
//                   Get.snackbar(
//                     'Health Check',
//                     isHealthy ? '✅ همه کنترلرها سالم هستند' : '❌ برخی کنترلرها مشکل دارند',
//                     snackPosition: SnackPosition.BOTTOM,
//                   );
//                 });
//               },
//               child: const Text('اجرای Health Check'),
//             ),
            
//             ElevatedButton(
//               onPressed: () {
//                 AppBinding.resetAllControllers();
//                 Get.snackbar(
//                   'Reset',
//                   'تمامی کنترلرها ریست شدند',
//                   snackPosition: SnackPosition.BOTTOM,
//                 );
//                 Get.offAllNamed('/');
//               },
//               child: const Text('ریست همه کنترلرها'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControllerStatus(String name, bool isRegistered) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: isRegistered ? Colors.green.shade50 : Colors.red.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isRegistered ? Colors.green.shade200 : Colors.red.shade200,
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             isRegistered ? Icons.check_circle : Icons.error,
//             color: isRegistered ? Colors.green : Colors.red,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   isRegistered ? 'ثبت شده ✅' : 'ثبت نشده ❌',
//                   style: TextStyle(
//                     color: isRegistered ? Colors.green.shade700 : Colors.red.shade700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }