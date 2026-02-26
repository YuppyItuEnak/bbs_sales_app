import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/customer/customer_group_model.dart';
import 'package:bbs_sales_app/data/models/customer/customer_model.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'npwp/list_npwp_customer_page.dart';

class CreateCustomerPage extends StatefulWidget {
  final CustomerModel? customer;
  const CreateCustomerPage({super.key, this.customer});

  @override
  State<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends State<CreateCustomerPage> {
  late TextEditingController _nameController;
  late TextEditingController _cpNameController;
  late TextEditingController _cpPhoneController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final form = context.read<CustomerFormProvider>();
    _nameController = TextEditingController(text: form.name);
    _cpNameController = TextEditingController(text: form.cpName);
    _cpPhoneController = TextEditingController(text: form.cpPhone);
    _notesController = TextEditingController(text: form.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpNameController.dispose();
    _cpPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<CustomerFormProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: Text(
            widget.customer == null ? 'Create Customer' : 'Edit Customer',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label("Customer Group"),
                form.isLoadingCustomerGroups
                    ? const Center(child: CircularProgressIndicator())
                    : _searchableDropdown<CustomerGroup>(
                        hint: "Pilih Parent Customer",
                        value: form.parentCustomer,
                        items: form.customerGroups,
                        onChanged: form.setParentCustomer,
                        itemAsString: (CustomerGroup u) => u.name,
                        searchHint: "Cari customer group...",
                      ),
                const SizedBox(height: 5),
                _label("Nama *"),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: form.isLoadingPrefixes
                          ? const Center(child: CircularProgressIndicator())
                          : _searchableDropdown<MGenModel>(
                              value: form.prefix,
                              items: form.prefixes,
                              onChanged: form.setPrefix,
                              itemAsString: (MGenModel s) => s.value1 ?? '',
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                        hint: "Nama Customer",
                        controller: _nameController,
                        onChanged: form.setName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _label("Taxable *"),
                _searchableDropdown<String>(
                  hint: "Pilih Jenis Pajak",
                  value: form.taxable,
                  items: const ["YA", "TIDAK"],
                  onChanged: form.setTaxable,
                  itemAsString: (String u) => u,
                ),
                const SizedBox(height: 5),
                _label("ToP"),
                form.isLoadingTops
                    ? const Center(child: CircularProgressIndicator())
                    : _searchableDropdown<MGenModel>(
                        hint: "Pilih Term of Payment",
                        value: form.top,
                        items: form.tops,
                        onChanged: form.setTop,
                        itemAsString: (MGenModel u) => u.value1!,
                        searchHint: "Cari customer group...",
                      ),
                const SizedBox(height: 5),
                _label("Contact Person"),
                _buildTextField(
                  hint: "Masukkan Contact Person",
                  controller: _cpNameController,
                  onChanged: form.setCpName,
                ),
                const SizedBox(height: 5),
                _label("No. Telpon CP"),
                _buildTextField(
                  hint: "Masukkan No. Telp",
                  controller: _cpPhoneController,
                  onChanged: form.setCpPhone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 5),
                _label("Catatan"),
                _buildTextField(
                  hint: "Catatan",
                  controller: _notesController,
                  maxLines: 3,
                  onChanged: form.setNotes,
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5264F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerNPWPPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Lanjut",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Function(String)? onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _dropdown({
    String? value,
    List<String>? items,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          onChanged: onChanged,
          dropdownColor: Colors.white,
          itemHeight: 48,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: Colors.black87,
          ),

          hint: Text(
            hint ?? "",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),

          items: items?.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _searchableDropdown<T>({
    T? value,
    List<T>? items,
    required Function(T?) onChanged,
    String? hint,
    required String Function(T) itemAsString,
    String? searchHint,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownSearch<T>(
        dropdownBuilder: (context, selectedItem) {
          if (selectedItem == null) {
            return Text(
              hint ?? "",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            );
          }
          return Text(
            itemAsString(selectedItem),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
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
          itemBuilder: (context, item, isSelected) {
            return ListTile(title: Text(itemAsString(item)));
          },
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintText: searchHint ?? "Cari...",
            ),
          ),
        ),
        items: items ?? [],
        itemAsString: itemAsString,
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 14),
            isDense: false,
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ),
        onChanged: onChanged,
        selectedItem: value,
      ),
    );
  }
}
