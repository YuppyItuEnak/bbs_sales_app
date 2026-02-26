import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/models/general/m_gen_model.dart';
import 'package:bbs_sales_app/data/models/prospect/prospect_create_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_realization_detail_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/prospect/presentation/providers/prospect_provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class CreateProspectFromVisitPage extends StatelessWidget {
  final VisitRealizationDetail visitRealizationDetail;

  const CreateProspectFromVisitPage({
    super.key,
    required this.visitRealizationDetail,
  });

  @override
  Widget build(BuildContext context) {
    // Provider sudah tersedia secara global dari main.dart
    // Tidak perlu membuat ChangeNotifierProvider.value yang redundan
    return _CreateProspectFromVisitView(
      visitRealizationDetail: visitRealizationDetail,
    );
  }
}

class _CreateProspectFromVisitView extends StatefulWidget {
  final VisitRealizationDetail visitRealizationDetail;

  const _CreateProspectFromVisitView({required this.visitRealizationDetail});

  @override
  State<_CreateProspectFromVisitView> createState() =>
      _CreateProspectFromVisitViewState();
}

class _CreateProspectFromVisitViewState
    extends State<_CreateProspectFromVisitView> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cpNameController;
  late TextEditingController _cpPhoneController;
  late TextEditingController _notesController;
  late TextEditingController _addressController;

  Position? _currentPosition;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final form = context.read<ProspectProvider>();
    _nameController = TextEditingController(text: form.name);
    _phoneController = TextEditingController(text: form.phone);
    _cpNameController = TextEditingController(text: form.cpName);
    _cpPhoneController = TextEditingController(text: form.cpPhone);
    _notesController = TextEditingController(text: form.notes);
    _addressController = TextEditingController(text: form.address);

    // Initialize form data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });

    _getLocation();
  }

  Future<void> _initializeForm() async {
    final prospectProvider = context.read<ProspectProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.token != null) {
      await prospectProvider.fetchPrefixOptions(authProvider.token!);
      await prospectProvider.fetchTopOptions(authProvider.token!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cpNameController.dispose();
    _cpPhoneController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {});
    } catch (e) {
      print('Failed to get location: $e');
    }
  }

  Future<void> _createProspect() async {
    // Cek jika widget masih mounted dan tidak sedang submitting
    if (!mounted || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final form = context.read<ProspectProvider>();
    if (form.name?.isEmpty ?? true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama prospek tidak boleh kosong.')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }
    if (form.phone?.isEmpty ?? true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nomor telepon tidak boleh kosong.')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }
    if (form.taxable?.isEmpty ?? true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Taxable tidak boleh kosong.')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }
    if (form.top == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ToP tidak boleh kosong.')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }
    if (form.cpName?.isEmpty ?? true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact Person tidak boleh kosong.')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }
    if (form.cpPhone?.isEmpty ?? true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No. Telpon CP tidak boleh kosong.')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }
    if (form.address?.isEmpty ?? true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat tidak boleh kosong.')),
        );
        setState(() {
          _isSubmitting = false;
        });
      }
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final prospectProvider = context.read<ProspectProvider>();

    final prospect = ProspectCreateModel(
      name: form.name,
      phone: form.phone,
      address: form.address,
      unitBusinessId: authProvider.unitBusinessId,
      contactPerson: form.cpName,
      customerGroupName: widget.visitRealizationDetail.customerName ?? 'N/A',
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      salesId: authProvider.user?.userDetails.first.fUserDefault,
      nameTypeId: form.prefix?.id,
      topId: form.top?.id,
      pn: form.taxable == "YA",
      // notes: form.notes,
      isActive: true,
      currentApprovalLevel: 1,
      approvalCount: 0,
      approvedCount: 0,
      status: 1,
    );

    try {
      final success = await prospectProvider.createProspect(
        prospect: prospect,
        token: authProvider.token!,
      );

      // Cek lagi jika widget masih mounted sebelum melakukan navigasi
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prospek berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(prospectProvider.error ?? 'Gagal membuat prospek!'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop(false);
      }
    } catch (e) {
      // Tangani exception jika ada
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Reset submitting state jika widget masih mounted
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<ProspectProvider>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          centerTitle: true,
          leading: const BackButton(color: Colors.black),
          title: const Text(
            'Buat Prospek Baru',
            style: TextStyle(
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
                _buildTextField(
                  hint: "Customer Group",
                  controller: TextEditingController(
                    text: widget.visitRealizationDetail.customerName ?? '',
                  ),
                  onChanged: (_) {},
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
                        hint: "Nama Prospek",
                        controller: _nameController,
                        onChanged: form.setName,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _label("No. Telpon *"),
                _buildTextField(
                  hint: "Masukkan No. Telpon",
                  controller: _phoneController,
                  onChanged: form.setPhone,
                  keyboardType: TextInputType.phone,
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
                _label("ToP *"),
                form.isLoadingTops
                    ? const Center(child: CircularProgressIndicator())
                    : _searchableDropdown<MGenModel>(
                        hint: "Pilih Term of Payment",
                        value: form.top,
                        items: form.tops,
                        onChanged: form.setTop,
                        itemAsString: (MGenModel u) => u.value1!,
                        searchHint: "Cari ToP...",
                      ),
                const SizedBox(height: 5),
                _label("Contact Person *"),
                _buildTextField(
                  hint: "Masukkan Contact Person",
                  controller: _cpNameController,
                  onChanged: form.setCpName,
                ),
                const SizedBox(height: 5),
                _label("No. Telpon CP *"),
                _buildTextField(
                  hint: "Masukkan No. Telp",
                  controller: _cpPhoneController,
                  onChanged: form.setCpPhone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 5),
                _label("Alamat *"),
                _buildTextField(
                  hint: "Masukkan Alamat",
                  controller: _addressController,
                  maxLines: 3,
                  onChanged: form.setAddress,
                ),
                const SizedBox(height: 5),
                _label("Catatan"),
                _buildTextField(
                  hint: "Catatan",
                  controller: _notesController,
                  maxLines: 3,
                  onChanged: form.setNotes,
                ),
                const SizedBox(height: 16),
                Text(
                  "Lokasi Prospek:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Latitude: ${_currentPosition?.latitude ?? 'Mencari...'}'),
                Text(
                  'Longitude: ${_currentPosition?.longitude ?? 'Mencari...'}',
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
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            _createProspect();
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            "Checkout + Buat Prospek",
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
