import 'dart:io';

import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/complaint/complaint_add_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_name_model.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/models/sales_invoice/sales_invoice_model.dart'; // New import
import 'package:bbs_sales_app/data/models/sales_invoice/surat_jalan_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/complaint/presentation/providers/complaint_form_provider.dart';
import 'package:bbs_sales_app/features/complaint/presentation/pages/return_item_selected_page.dart';
import 'package:bbs_sales_app/features/complaint/presentation/providers/return_item_provider.dart';
import 'package:bbs_sales_app/features/sales_invoice/presentation/providers/sales_invoice_provider.dart'; // New import
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddComplaintPage extends StatelessWidget {
  const AddComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ComplaintFormProvider()),
        ChangeNotifierProvider(
          create: (_) => SalesInvoiceProvider(),
        ), // New Provider
      ],
      child: const _AddComplaintContent(),
    );
  }
}

class _AddComplaintContent extends StatefulWidget {
  const _AddComplaintContent();

  @override
  State<_AddComplaintContent> createState() => _AddComplaintContentState();
}

class _AddComplaintContentState extends State<_AddComplaintContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null &&
          auth.salesId != null &&
          auth.unitBusinessId != null) {
        context.read<ComplaintFormProvider>().loadData(
          token: auth.token!,
          unitBusinessId: auth.unitBusinessId!,
          salesId: auth.salesId!,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ComplaintFormProvider>();
    final dateStr = DateFormat('dd MMM yyyy').format(DateTime.now());

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Tambah Komplain',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoColumn("Tanggal", dateStr),
                        _buildInfoColumn(
                          "No. Draft",
                          "AUTO",
                          crossAxis: CrossAxisAlignment.end,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Customer"),
                    DropdownSearch<CustomerSimpleModel>(
                      items: provider.customers
                          .where((c) => c.id != null)
                          .toList(),
                      itemAsString: (item) => item.name ?? '-',
                      selectedItem: provider.selectedCustomer,
                      onChanged: (val) => provider.setCustomer(context, val),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Cari Customer...",
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                          ),
                        ),
                        menuProps: const MenuProps(
                          backgroundColor: Colors.white,
                          elevation: 8,
                        ),
                      ),

                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Pilih Customer",
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          fillColor:
                              Colors.white, // Set background color to white
                          filled: true, // Ensure the field is filled
                          border: InputBorder.none, // Already removed border
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Tipe Ref"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Pilih Tipe"),
                        value: provider.selectedRefType,
                        items: ['SI', 'SJ']
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e == 'SI' ? 'Sales Invoice' : 'Surat Jalan',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) => provider.setRefType(context, val!),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLabel(
                      provider.selectedRefType == 'SI'
                          ? "No. Sales Invoice"
                          : "No. Surat Jalan",
                    ),
                    if (provider.isLoadingSalesInvoices)
                      const Center(child: CircularProgressIndicator())
                    else if (provider.salesInvoiceError != null)
                      Text(
                        "Error: ${provider.salesInvoiceError}",
                        style: const TextStyle(color: Colors.red),
                      )
                    else if (provider.selectedRefType == 'SI')
                      DropdownSearch<SalesInvoiceModel>(
                        items: provider.salesInvoices,
                        itemAsString: (item) => item.code ?? '-',
                        selectedItem: provider.selectedSalesInvoice,
                        compareFn: (a, b) => a.id == b.id,
                        onChanged: provider.setSalesInvoice,
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: "Cari Sales Invoice...",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                          menuProps: const MenuProps(
                            backgroundColor: Colors.white,
                            elevation: 8,
                          ),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "Pilih Sales Invoice",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    else
                      DropdownSearch<SuratJalanModel>(
                        items: provider.suratJalan,
                        itemAsString: (item) => item.code ?? '-',
                        selectedItem: provider.selectedSuratJalan,
                        onChanged: provider.setSuratJalan,
                        popupProps: const PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: "Cari Surat Jalan...",
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                          menuProps: const MenuProps(
                            backgroundColor: Colors.white,
                            elevation: 8,
                          ),
                        ),
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: "Pilih Surat Jalan",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildLabel("Contact Person"),
                    _buildTextField(
                      "Masukkan Contact Person",
                      provider.contactPersonCtrl,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Tipe Complain"),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<MGenModel>(
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: const Text("Pilih Tipe"),
                        value: provider.selectedComplaintType,
                        items: provider.complaintTypes
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.value1 ?? '-'),
                              ),
                            )
                            .toList(),
                        onChanged: provider.setComplaintType,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Detail Item",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (provider.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Belum ada item dipilih",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...provider.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildItemCard(
                            context,
                            index,
                            item,
                            () => provider.removeItem(index),
                          ),
                        );
                      }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            (provider.selectedRefType == 'SI' &&
                                    provider.selectedSalesInvoice != null) ||
                                (provider.selectedRefType == 'SJ' &&
                                    provider.selectedSuratJalan != null)
                            ? () async {
                                final newItems =
                                    await Navigator.push<
                                      List<ComplainCreateItemModel>
                                    >(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChangeNotifierProvider(
                                          create: (_) => ReturnItemProvider(),
                                          child: ReturnItemSelectedPage(
                                            refType: provider.selectedRefType,
                                            refId:
                                                provider.selectedRefType == 'SI'
                                                ? provider
                                                      .selectedSalesInvoice!
                                                      .id!
                                                : provider
                                                      .selectedSuratJalan!
                                                      .id!,
                                            addedItemIds: provider.items
                                                .map((e) => e.itemId!)
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                    );
                                if (newItems != null && newItems.isNotEmpty) {
                                  provider.addItems(newItems);
                                }
                              }
                            : null,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6366F1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "+ Tambah Barang",
                          style: TextStyle(color: Color(0xFF6366F1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showConfirmDialog(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Dialog Konfirmasi (Sesuai gambar pojok kanan atas)
  void _showConfirmDialog(
    BuildContext context,
    ComplaintFormProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Center(
          child: Text(
            "Apakah Anda yakin?",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        content: const Text(
          "Pastikan data yang input benar",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Color(0xFF6366F1)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final auth = context.read<AuthProvider>();
              if (auth.token != null &&
                  auth.salesId != null &&
                  auth.unitBusinessId != null) {
                final success = await provider.submit(
                  token: auth.token!,
                  salesId: auth.salesId!,
                  unitBusinessId: auth.unitBusinessId!,
                );
                if (success && context.mounted) {
                  Navigator.pop(context); // Close page
                } else if (context.mounted && provider.error != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(provider.error!)));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Iya", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Bagian Build Item Card yang disesuaikan
  Widget _buildItemCard(
    BuildContext context,
    int index,
    ComplainCreateItemModel item,
    VoidCallback onRemove,
  ) {
    final provider = context.read<ComplaintFormProvider>();
    const primaryPurple = Color(0xFF5D5FEF);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: primaryPurple.withOpacity(0.5),
          width: 1.5,
        ), // Border biru/ungu sesuai SS
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.sjId ?? "SJ-05N-2401-0204",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              GestureDetector(
                onTap: onRemove,
                child: const Text(
                  "Hapus",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.itemName ?? "Item B",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            "${item.qtyRef ?? 0} ${item.uomUnit ?? 'PCS'}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Baris Qty Retur & Qty Diganti
          Row(
            children: [
              Expanded(
                child: _buildCounterField("Qty Retur", item.qtyReturn ?? 0, (
                  newValue,
                ) {
                  provider.updateItemQuantities(index, newQtyReturn: newValue);
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCounterField(
                  "Total Qty Diganti",
                  item.qtyReplaced ?? 0,
                  (newValue) {
                    provider.updateItemQuantities(
                      index,
                      newQtyReplaced: newValue,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildLabel("Alasan"),
          _buildDropdownAlasan(), // Dropdown khusus dalam card

          const SizedBox(height: 16),
          _buildLabel("Attachment"),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...item.imageFiles.asMap().entries.map((entry) {
                final imageIndex = entry.key;
                final imageFile = entry.value;
                return _buildImageSquare(
                  imageFile: imageFile,
                  onRemove: () =>
                      provider.removeImageFromItem(index, imageIndex),
                );
              }),
              _buildAddImageSquare(
                onTap: () => provider.pickImageForItem(index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Pembantu untuk Counter (Plus-Minus)
  Widget _buildCounterField(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    const primaryPurple = Color(0xFF5D5FEF);
    final ctrl = TextEditingController(text: value.toString());
    // Ensure cursor is at the end of the text
    ctrl.selection = TextSelection.fromPosition(
      TextPosition(offset: ctrl.text.length),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCounterBtn(Icons.remove, primaryPurple, () {
                final currentValue = int.tryParse(ctrl.text) ?? 0;
                if (currentValue > 0) {
                  final newValue = currentValue - 1;
                  ctrl.text = newValue.toString();
                  onChanged(newValue);
                }
              }),
              Expanded(
                child: TextFormField(
                  controller: ctrl,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (text) {
                    final newValue = int.tryParse(text) ?? 0;
                    onChanged(newValue);
                  },
                ),
              ),
              _buildCounterBtn(Icons.add, primaryPurple, () {
                final currentValue = int.tryParse(ctrl.text) ?? 0;
                final newValue = currentValue + 1;
                ctrl.text = newValue.toString();
                onChanged(newValue);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // Widget Placeholder Foto
  Widget _buildAttachmentSquare({required bool isPlaceholder}) {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isPlaceholder
          ? Icon(Icons.camera_alt_outlined, color: Colors.grey.shade300)
          : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                "https://via.placeholder.com/60",
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  // Widget untuk menampilkan gambar yang sudah dipilih
  Widget _buildImageSquare({
    required File imageFile,
    required VoidCallback onRemove,
  }) {
    return Stack(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(imageFile, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 12),
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk tombol tambah gambar
  Widget _buildAddImageSquare({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildDropdownAlasan() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: "Rusak",
          items: ["Rusak", "Cacat", "Salah Kirim"]
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (v) {},
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );
  Widget _buildInfoColumn(
    String t,
    String v, {
    CrossAxisAlignment crossAxis = CrossAxisAlignment.start,
  }) => Column(
    crossAxisAlignment: crossAxis,
    children: [
      Text(t, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
  Widget _buildTextField(String hint, TextEditingController ctrl) => TextField(
    controller: ctrl,
    decoration: InputDecoration(
      hintText: hint,
      border: InputBorder.none, // Removed border
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    ),
  );
}
