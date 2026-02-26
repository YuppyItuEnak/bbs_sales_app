import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/customer/delivery_area_model.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbs_sales_app/features/customer/presentation/providers/customer_provider.dart';

class AddAddressPage extends StatefulWidget {
  final dynamic edit;
  const AddAddressPage({super.key, this.edit});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final addressCtrl = TextEditingController();
  final zipCtrl = TextEditingController();
  final receiptCtrl = TextEditingController();
  bool isDefault = false;
  DeliveryAreaModel? selectedArea;
  String? selectedProv, selectedKota, selectedKec;
  MGenModel? selectedProvinsi, selectedCity, selectedDistrict;

  @override
  void initState() {
    if (widget.edit != null) {
      addressCtrl.text = widget.edit!.fullAddress;
      receiptCtrl.text = widget.edit!.label;
      isDefault = widget.edit!.isDefault;
    }
    super.initState();
  }

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
            'Tambah Alamat',
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
                    _buildLabel("Delivery Area"),
                    _buildSearchableDropdown<DeliveryAreaModel>(
                      hint: "Pilih Delivery Area",
                      itemAsString: (item) => item.description,
                      onChanged: (val) => setState(() => selectedArea = val),
                      asyncItems: (text) => form.searchDeliveryAreas(text),
                      selectedItem: selectedArea,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Alamat"),
                    _buildTextField(
                      addressCtrl,
                      "Masukkan alamat customer",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Nama Penerima"),
                    _buildTextField(receiptCtrl, "Masukkan Nama Penerima"),
                    const SizedBox(height: 16),
                    _buildLabel("Provinsi"),
                    _buildSearchableDropdown<MGenModel>(
                      hint: "Pilih Provinsi",
                      itemAsString: (item) => item.value1 ?? '',
                      onChanged: (val) {
                        setState(() {
                          selectedProvinsi = val;
                          selectedCity = null;
                          selectedDistrict = null;
                        });
                      },
                      asyncItems: (text) => form.fetchProvinces(),
                      selectedItem: selectedProvinsi,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Kota"),
                    _buildSearchableDropdown<MGenModel>(
                      hint: "Pilih Kota",
                      itemAsString: (item) => item.value1 ?? '',
                      onChanged: (val) {
                        setState(() {
                          selectedCity = val;
                          selectedDistrict = null;
                        });
                      },
                      asyncItems: (text) {
                        if (selectedProvinsi == null) {
                          return Future.value([]);
                        }
                        return form.fetchCities(selectedProvinsi!.id);
                      },
                      selectedItem: selectedCity,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Kecamatan"),
                    _buildSearchableDropdown<MGenModel>(
                      hint: "Pilih Kecamatan",
                      itemAsString: (item) => item.value1 ?? '',
                      onChanged: (val) {
                        setState(() {
                          selectedDistrict = val;
                        });
                      },
                      asyncItems: (text) {
                        if (selectedCity == null) {
                          return Future.value([]);
                        }
                        return form.fetchDistricts(selectedCity!.id);
                      },
                      selectedItem: selectedDistrict,
                    ),
                    const SizedBox(height: 16),
                    _buildLabel("Kodepos"),
                    _buildTextField(zipCtrl, "Masukkan Kodepos"),
                    const SizedBox(height: 20),
                    const Text(
                      "Atur Lokasi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildMapPreview(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: isDefault,
                          activeColor: const Color(0xFF6366F1),
                          onChanged: (v) => setState(() => isDefault = v!),
                        ),
                        const Text("Set Default"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
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

  Widget _buildDropdown(
    String? value,
    String hint,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          items: [
            "Pilihan 1",
            "Ship to",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
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
              border: OutlineInputBorder(),
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

  Widget _buildMapPreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                "https://maps.googleapis.com/maps/api/staticmap?center=-7.250445,112.768845&zoom=15&size=600x300&key=YOUR_KEY",
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.map, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Latitude",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text("-8.889898989", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Longitude",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      Text("78.782289", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            context.read<CustomerFormProvider>().saveAddress(
              id: widget.edit?.id,
              label: receiptCtrl.text,
              address: addressCtrl.text,
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
