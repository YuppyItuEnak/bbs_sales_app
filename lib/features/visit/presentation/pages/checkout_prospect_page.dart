import 'dart:io';

import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/core/utils/permission_util.dart';
import 'package:bbs_sales_app/data/models/visit/visit_realization_detail_model.dart';
import 'package:bbs_sales_app/data/models/visit/visit_sales_detail_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/prospect/presentation/pages/create_prospect_from_visit_page.dart';
import 'package:bbs_sales_app/features/prospect/presentation/providers/prospect_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/providers/visit_detail_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/providers/visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CheckoutProspectPage extends StatelessWidget {
  final String visitId;

  const CheckoutProspectPage({super.key, required this.visitId});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProspectProvider()),
        ChangeNotifierProvider(create: (_) => VisitProvider()),
      ],
      child: _CheckoutProspectView(visitId: visitId),
    );
  }
}

class _CheckoutProspectView extends StatefulWidget {
  final String visitId;
  const _CheckoutProspectView({required this.visitId});

  @override
  State<_CheckoutProspectView> createState() => _CheckoutProspectViewState();
}

class _CheckoutProspectViewState extends State<_CheckoutProspectView> {
  final TextEditingController _notesController = TextEditingController();

  File? _imageFile;
  Position? _currentPosition;
  String? _currentAddress;
  bool _prospectCreated = false;
  VisitRealizationDetail? _visitDetail; // Added

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocation();
      _fetchVisitDetail(); // Added
    });
  }

  // Added method
  Future<void> _fetchVisitDetail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final visitProvider = Provider.of<VisitDetailProvider>(
      context,
      listen: false,
    );

    if (authProvider.token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi anda telah berakhir. Silakan login kembali.'),
        ),
      );
      return;
    }

    try {
      await visitProvider.fetchVisitDetail(
        widget.visitId,
        authProvider.token!,
      );
      setState(() {
        _visitDetail = visitProvider.visitDetail;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch visit detail: $e')),
      );
    }
  }

  @override
  void dispose() {
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

  Future<void> _submitAndNavigateToProspect() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto checkout tidak boleh kosong.')),
      );
      return;
    }

    if (_currentPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lokasi tidak ditemukan.')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi anda telah berakhir. Silakan login kembali.'),
        ),
      );
      return;
    }

    final realizationId = _visitDetail?.id; // Changed
    if (realizationId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID Realisasi Kunjungan tidak ditemukan.'),
        ),
      );
      return;
    }

    if (!_prospectCreated) {
      final bool? prospectCreatedResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateProspectFromVisitPage(
            visitRealizationDetail: _visitDetail!, // Changed
          ),
        ),
      );

      if (prospectCreatedResult != true) {
        // If prospect was not created or user cancelled, stop here.
        return;
      }
      // If prospect was created, _prospectCreated is now true.
      setState(() {
        _prospectCreated = true;
      });
    }

    // Now _prospectCreated is guaranteed to be true (either initially or after creation)
    // Proceed with checkout
    final provider = Provider.of<ProspectProvider>(context, listen: false);

    // Perform checkout
    final data = {
      'end_at': DateFormat('HH:mm:ss').format(DateTime.now()),
      'lat_end': _currentPosition!.latitude.toString(),
      'long_end': _currentPosition!.longitude.toString(),
      'notes': _notesController.text,
      'status': 'done-unplanned',
    };

    final success = await provider.performCheckout(
      realizationId: realizationId,
      data: data,
      photoPath: _imageFile!.path,
      token: token,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checkout berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Checkout failed!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_visitDetail == null) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          _visitDetail!.customerName ?? 'Checkout Prospek', // Changed
          style: const TextStyle(
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
            _infoRow(
              Icons.calendar_today,
              DateFormat('EEEE, dd-MM-yyyy', 'id_ID').format(DateTime.now()),
            ),
            const SizedBox(height: 12),
            const Text(
              "Lokasi Check-out",
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
      bottomSheet: Consumer<ProspectProvider>(
        builder: (context, provider, child) {
          return Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : _submitAndNavigateToProspect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: provider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Lanjut", style: TextStyle(fontSize: 16, color: Colors.white)),
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
                    "Ketuk untuk ambil foto checkout",
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
