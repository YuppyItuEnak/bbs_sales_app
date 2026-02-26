import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNPWPPage extends StatefulWidget {
  const AddNPWPPage({super.key});

  @override
  State<AddNPWPPage> createState() => _AddNPWPPageState();
}

class _AddNPWPPageState extends State<AddNPWPPage> {
  final numberCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final addrCtrl = TextEditingController();

  String selectedStatus = "AKTIF";
  bool isDefault = true;

  @override
  Widget build(BuildContext context) {
    final form = context.read<CustomerFormProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Tambah NPWP',
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
                    _buildLabel("No. NPWP"),
                    _buildTextField(numberCtrl, "Masukkan Nomor NPWP"),
                    const SizedBox(height: 16),

                    _buildLabel("Nama NPWP"),
                    _buildTextField(nameCtrl, "Masukkan Nama NPWP"),
                    const SizedBox(height: 16),

                    _buildLabel("Upload NPWP"),
                    _buildUploadField("filename.jpg"),
                    const SizedBox(height: 16),

                    _buildLabel("Alamat NPWP"),
                    _buildTextField(
                      addrCtrl,
                      "Masukkan alamat NPWP",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      "Status",
                      style: TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(),
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
                    form.addNPWP(
                      CustomerNPWP(
                        number: numberCtrl.text,
                        name: nameCtrl.text,
                        address: addrCtrl.text,
                        isDefault: isDefault,
                      ),
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

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: const Color(0xFFFBFBFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildUploadField(String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(fileName, style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.upload, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
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
          items: ["AKTIF", "TIDAK AKTIF"].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (val) {
            setState(() => selectedStatus = val!);
          },
        ),
      ),
    );
  }
}
