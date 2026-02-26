import 'package:flutter/material.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';

class AddBankPage extends StatefulWidget {
  const AddBankPage({super.key});

  @override
  State<AddBankPage> createState() => _AddBankPageState();
}

class _AddBankPageState extends State<AddBankPage> {
  final bankCtrl = TextEditingController();
  final areaCtrl = TextEditingController();
  final accNoCtrl = TextEditingController();
  final accNameCtrl = TextEditingController();

  MGenModel? selectedBank;
  String selectedStatus = "AKTIF";
  bool isDefault = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Tambah Rekening",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama Bank"),
                  _buildSearchableDropdown<MGenModel>(
                    hint: "Pilih Bank",
                    itemAsString: (item) => item.value1 ?? '',
                    onChanged: (val) {
                      setState(() {
                        selectedBank = val;
                      });
                    },
                    asyncItems: (text) => context
                        .read<CustomerFormProvider>()
                        .fetchMGenData('m_bank'),
                    selectedItem: selectedBank,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel("Kode Area"),
                  _buildTextField(areaCtrl, "Masukkan Kode Area"),
                  const SizedBox(height: 16),

                  _buildLabel("No. Rekening"),
                  _buildTextField(accNoCtrl, "Masukkan No. Rekening"),
                  const SizedBox(height: 16),

                  _buildLabel("Nama. Rekening"),
                  _buildTextField(accNameCtrl, "Masukkan Nama Rekening"),
                  const SizedBox(height: 16),

                  const Text(
                    "Status",
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusDropdown(),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Checkbox(
                        value: isDefault,
                        activeColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (val) =>
                            setState(() => isDefault = val ?? false),
                      ),
                      const Text("Set Default"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Button Simpan ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CustomerFormProvider>().addBank(
                    bankName: selectedBank?.value1 ?? "",
                    accountNumber: accNoCtrl.text,
                    accountName: accNameCtrl.text,
                    isDefault: isDefault,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Simpan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: const [
            TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: const Color(0xFFFBFBFB),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSearchableDropdown<T>({
    String? hint,
    required String Function(T) itemAsString,
    required Function(T?) onChanged,
    required Future<List<T>> Function(String) asyncItems,
    T? selectedItem,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownSearch<T>(
        dropdownBuilder: (context, selectedItem) {
          if (selectedItem == null) {
            return Text(
              hint ?? "",
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            );
          }
          return Text(
            itemAsString(selectedItem),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          );
        },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          menuProps: const MenuProps(backgroundColor: Colors.white),
          containerBuilder: (ctx, popupWidget) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: popupWidget,
            );
          },
          searchFieldProps: const TextFieldProps(
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintText: "Cari...",
            ),
          ),
        ),
        asyncItems: asyncItems,
        itemAsString: itemAsString,
        onChanged: onChanged,
        selectedItem: selectedItem,
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStatus,
          isExpanded: true,
          items: [
            "AKTIF",
            "TIDAK AKTIF",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => selectedStatus = val!),
        ),
      ),
    );
  }
}
