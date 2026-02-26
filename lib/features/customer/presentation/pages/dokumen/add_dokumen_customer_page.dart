import 'package:flutter/material.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';

class AddDocumentPage extends StatefulWidget {
  const AddDocumentPage({super.key});

  @override
  State<AddDocumentPage> createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  MGenModel? selectedDocType;
  final noteCtrl = TextEditingController();

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
            'Tambah Dokumen',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Tipe Dokumen"),
                    _buildSearchableDropdown<MGenModel>(
                      hint: "Pilih Tipe Dokumen",
                      itemAsString: (item) => item.value1 ?? '',
                      onChanged: (val) {
                        setState(() {
                          selectedDocType = val;
                        });
                      },
                      asyncItems: (text) => context
                          .read<CustomerFormProvider>()
                          .fetchMGenData('m_doc_type'),
                      selectedItem: selectedDocType,
                    ),
                    const SizedBox(height: 24),
                    _buildLabel("Upload Dokumen"),
                    _buildUploadArea(),
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
                    context.read<CustomerFormProvider>().addDocument(
                      type: selectedDocType?.value1 ?? "",
                      note: noteCtrl.text,
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

  Widget _buildUploadArea() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ), // Bisa gunakan CustomPainter untuk garis putus-putus
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.upload_outlined, color: Color(0xFF6366F1), size: 32),
          SizedBox(height: 8),
          Text(
            "Upload",
            style: TextStyle(
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
