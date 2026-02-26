// import 'package:bbs_sales_app/features/tagihan/presentation/pages/detail_tagihan_page.dart';
// import 'package:flutter/material.dart';

// void showConfirmModal(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (_) {
//       return Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const SizedBox(height: 10),
//               const Icon(Icons.help_outline, size: 80, color: Colors.blue),
//               const SizedBox(height: 20),

//               const Text(
//                 "Apakah Anda yakin?",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),

//               const SizedBox(height: 30),

//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text("Tidak"),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const DetailTagihanPage(),
//                           ),
//                         );
//                       },
//                       child: const Text("Ya"),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
