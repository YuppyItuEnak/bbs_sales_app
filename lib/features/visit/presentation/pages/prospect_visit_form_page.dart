import 'dart:io';

import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/core/utils/permission_util.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/providers/prospect_visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProspectVisitFormPage extends StatelessWidget {
  const ProspectVisitFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProspectVisitProvider(),
      child: const _ProspectVisitFormView(),
    );
  }
}

class _ProspectVisitFormView extends StatefulWidget {
  const _ProspectVisitFormView();

  @override
  State<_ProspectVisitFormView> createState() => _ProspectVisitFormViewState();
}

class _ProspectVisitFormViewState extends State<_ProspectVisitFormView> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  File? _imageFile;
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocation();
    });
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final hasPermission = await PermissionUtil.handlePermissions(context);
    if (!hasPermission) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1080,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _getLocation() async {
    final hasPermission = await PermissionUtil.handlePermissions(context);
    if (!hasPermission) return;

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      Placemark place = placemarks[0];
      _currentAddress =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  Future<void> _submit() async {
    if (_customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama customer tidak boleh kosong.')),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto check-in tidak boleh kosong.')),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lokasi tidak ditemukan.')));
      return;
    }

    final provider = Provider.of<ProspectVisitProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token!;

    final data = {
      'unit_bussiness_id': Provider.of<AuthProvider>(
        context,
        listen: false,
      ).unitBusinessId!,
      'customer_name': _customerNameController.text,
      'visit_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'start_at': DateFormat('HH:mm:ss').format(DateTime.now()),
      'lat_start': _currentPosition!.latitude.toString(),
      'long_start': _currentPosition!.longitude.toString(),
      'sales_id': Provider.of<AuthProvider>(context, listen: false).salesId!,
      'address': _currentAddress ?? '',
      'status': 'undone',
      'notes': _notesController.text,
    };

    debugPrint("Submitting data: $data");
    debugPrint(" with photo path: ${_imageFile!.path}");

    final success = await provider.performProspectCheckIn(
      data: data,
      photoPath: _imageFile!.path,
      token: token,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in prospek berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Submission failed!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Kunjungan Prospek Baru',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActivePhotoPicker(),
            const SizedBox(height: 16),
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: "Nama Customer",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(
              Icons.calendar_today,
              DateFormat('EEEE, dd-MM-yyyy', 'id_ID').format(DateTime.now()),
            ),
            const SizedBox(height: 12),
            const Text(
              "Lokasi Check-in",
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(_currentAddress ?? 'Mencari lokasi...'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Latitude\n${_currentPosition?.latitude ?? 'N/A'}",
                  ),
                ),
                Expanded(
                  child: Text(
                    "Longitude\n${_currentPosition?.longitude ?? 'N/A'}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: null,
              decoration: InputDecoration(
                labelText: "Catatan",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Consumer<ProspectVisitProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: provider.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Check In", style: TextStyle(fontSize: 16)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivePhotoPicker() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xfff1f2f7),
          borderRadius: BorderRadius.circular(16),
          image: _imageFile != null
              ? DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _imageFile == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    "Ketuk untuk ambil foto checkin",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
