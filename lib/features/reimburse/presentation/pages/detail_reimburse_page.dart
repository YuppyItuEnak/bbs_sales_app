import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/reimburse/reimburse_add_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/reimburse/presentation/providers/reimburse_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailReimbursePage extends StatelessWidget {
  final String reimburseId;
  const DetailReimbursePage({super.key, required this.reimburseId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReimburseProvider(),
      child: _DetailReimburseContent(reimburseId: reimburseId),
    );
  }
}

class _DetailReimburseContent extends StatefulWidget {
  final String reimburseId;
  const _DetailReimburseContent({required this.reimburseId});

  @override
  State<_DetailReimburseContent> createState() =>
      _DetailReimburseContentState();
}

class _DetailReimburseContentState extends State<_DetailReimburseContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetail();
    });
  }

  void _fetchDetail() {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ReimburseProvider>();

    if (auth.token != null) {
      provider.getDetail(auth.token!, widget.reimburseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna ungu utama dari SS jika AppColors.backgroundColor bukan ungu
    const primaryPurple = Color(0xFF5D5FEF);

    return Scaffold(
      backgroundColor: primaryPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Detail Reimburse',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
        ),
      ),
      body: Consumer2<ReimburseProvider, AuthProvider>(
        builder: (context, provider, auth, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                "Error: ${provider.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (provider.selected == null) {
            return const Center(
              child: Text(
                "Reimburse details not found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final item = provider.selected!;
          final isBensin = item.type == "Bensin";
          final isSpv = auth.user?.username == 'SPV_marketing_BBS';
          final bool showApproveAction =
              isSpv && item.status != "LUNAS" && item.status != "APPROVED";
          final dateStr = item.date != null
              ? DateFormat('dd MMMM yyyy', 'id_ID').format(item.date!)
              : '-';

          // Warna Badge Status
          Color statusBgColor = Colors.white24;
          Color statusTextColor = Colors.white;
          if (item.status == "LUNAS") {
            statusBgColor = const Color(0xFF72C155);
          } else if (item.status == "POSTED") {
            statusBgColor = Colors.white;
            statusTextColor = primaryPurple;
          }

          return Column(
            children: [
              // HEADER INFO
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type ?? '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.status ?? 'UNKNOWN',
                        style: TextStyle(
                          color: statusTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // MAIN CONTENT CARD
              Expanded(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Detail Reimburse",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // KM INFO (HANYA BENSIN)
                        if (isBensin) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildDetailItem(
                                "KM Awal",
                                NumberFormat(
                                  '#,##0',
                                  'id_ID',
                                ).format(item.kmAwal ?? 0.0),
                              ),
                              _buildDetailItem(
                                "KM Akhir",
                                NumberFormat(
                                  '#,##0',
                                  'id_ID',
                                ).format(item.kmAkhir ?? 0.0),
                              ),
                              _buildDetailItem(
                                "Total KM",
                                NumberFormat(
                                  '#,##0',
                                  'id_ID',
                                ).format(item.totalKm ?? 0.0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // TOTAL AMOUNT BOX
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Total Reimburse",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rp ${NumberFormat('#,##0', 'id_ID').format(item.total ?? 0)}",
                                style: const TextStyle(
                                  color: primaryPurple,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "Catatan",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.note ?? '-',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text(
                          "Attachment",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),

                        // ATTACHMENT DISPLAY
                        if (isBensin)
                          Row(
                            children: [
                              Expanded(
                                child: _buildImageFrame(
                                  "Foto KM awal",
                                  item.fotoAwal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildImageFrame(
                                  "Foto KM akhir",
                                  item.fotoAkhir,
                                ),
                              ),
                            ],
                          )
                        else if (item.fotoAwal != null)
                          _buildImageFrame(null, item.fotoAwal)
                        else
                          const Text(
                            'No attachment available.',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              if (showApproveAction)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 16.0,
                  ),
                  child: Row(
                    children: [
                      // TOMBOL REJECT
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => _handleAction(context, 'REJECTED'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "REJECT",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // TOMBOL APPROVE
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isLoading
                              ? null
                              : () => _handleAction(context, 'APPROVED'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF72C155),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "APPROVE",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              // BOTTOM BUTTON
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryPurple,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Kembali",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildImageFrame(String? label, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  '${ApiConstants.baseUrl2}/$imageUrl',
                  height: label != null ? 120.0 : 180.0,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120.0,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
              : Container(
                  height: 120.0,
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, String newStatus) async {
    final provider = context.read<ReimburseProvider>();
    final auth = context.read<AuthProvider>();
    final item = provider.selected; // Mengambil data item yang sedang dibuka

    if (item == null || auth.token == null) return;

    // Map data dari Model Detail ke CreateModel (untuk update)
    final updateData = ReimburseCreateModel(
      salesId: item.salesId ?? "",
      type: item.type ?? "",
      date: item.date ?? DateTime.now(),
      unitBusinessId: item.unitBusinessId ?? "",
      total: item.total ?? 0,
      // rate_reimburse: item. ?? 0,
      kmAwal: item.kmAwal ?? 0,
      kmAkhir: item.kmAkhir ?? 0,
      note: item.note ?? "",
      fotoAwal: "", // Biarkan kosong agar tidak menimpa file lama di repo
      fotoAkhir: "",
      status: newStatus, // Status baru: 'APPROVED' atau 'REJECTED'
      approvalCount: item.approvalCount ?? 0,
      approvedCount: item.approvedCount ?? 0,
      approvalLevel: item.currentApprovalLevel ?? 1,
    );

    final success = await provider.update(
      auth.token!,
      item.id!,
      updateData,
      null, // Tidak kirim file baru
      null,
    );

    if (context.mounted) {
      if (success) {
        await provider.fetch(token: auth.token!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berhasil melakukan $newStatus"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali ke list setelah sukses
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal: ${provider.error}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
