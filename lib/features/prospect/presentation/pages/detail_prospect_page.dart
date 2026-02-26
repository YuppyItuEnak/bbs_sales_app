import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/prospect/prospect_detail_model.dart';
import 'package:flutter/material.dart';

class DetailProspectPage extends StatelessWidget {
  final ProspectDetailModel prospect;

  const DetailProspectPage({super.key, required this.prospect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Detail Prospek',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Informasi Utama"),
              _buildInfoCard([
                _buildInfoRow("Nama Prospek", prospect.name),
                _buildInfoRow("Kode", prospect.code),
                _buildInfoRow("Customer Group", prospect.customerGroupName),
                _buildInfoRow(
                  "Taxable (PN)",
                  prospect.pn == true ? "YA" : "TIDAK",
                ),
              ]),
              const SizedBox(height: 20),

              _buildSectionHeader("Kontak"),
              _buildInfoCard([
                _buildInfoRow("Contact Person", prospect.contactPerson),
                _buildInfoRow("No. Telepon", prospect.phone),
                _buildInfoRow("Alamat", prospect.address),
              ]),
              const SizedBox(height: 20),

              _buildSectionHeader("Lokasi & Lainnya"),
              _buildInfoCard([
                _buildInfoRow("Latitude", prospect.latitude?.toString()),
                _buildInfoRow("Longitude", prospect.longitude?.toString()),
                _buildInfoRow("Catatan", prospect.notes),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5F6BF7),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '-',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
