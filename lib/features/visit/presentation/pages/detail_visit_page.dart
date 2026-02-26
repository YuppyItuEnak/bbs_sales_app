import 'dart:convert';
import 'dart:io';

import 'package:bbs_sales_app/core/constants/api_constants.dart';
import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/core/utils/permission_util.dart';
import 'package:bbs_sales_app/data/models/visit/visit_realization_detail_model.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/providers/visit_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailVisitPage extends StatelessWidget {
  final String visitPlanId;
  final String customerId;
  final String? realizationId;

  const DetailVisitPage({
    super.key,
    required this.visitPlanId,
    required this.customerId,
    this.realizationId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisitDetailProvider(),
      child: DetailVisitView(
        visitPlanId: visitPlanId,
        customerId: customerId,
        realizationId: realizationId,
      ),
    );
  }
}

class DetailVisitView extends StatefulWidget {
  final String visitPlanId;
  final String customerId;
  final String? realizationId;

  const DetailVisitView({
    super.key,
    required this.visitPlanId,
    required this.customerId,
    this.realizationId,
  });

  @override
  State<DetailVisitView> createState() => _DetailVisitViewState();
}

class _DetailVisitViewState extends State<DetailVisitView> {
  final TextEditingController _notesController = TextEditingController();

  File? _imageFile;
  Position? _currentPosition;
  String? _currentAddress;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePage();
    });
  }

  Future<void> _initializePage() async {
    if (widget.realizationId == null) {
      // This is a new check-in, get location and check radius right away.
      await _getLocation();
    } else {
      // This is an existing visit, fetch its details first.
      await _fetchDetails();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isSubmitting = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token!;
    final provider = Provider.of<VisitDetailProvider>(context, listen: false);
    await provider.fetchVisitDetail(widget.realizationId!, token);

    // After fetching, check if we need to get current location
    final visit = provider.visitDetail;
    if (visit != null && visit.endAt == null) {
      // If visit is not completed, get current location for potential check-out
      await _getLocation();
    }

    setState(() => _isSubmitting = false);
  }

  Future<bool> _isVpnActive() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.any,
      );
      for (var interface in interfaces) {
        if (interface.name.contains('tun') ||
            interface.name.contains('ppp') ||
            interface.name.contains('vpn')) {
          return true;
        }
      }
    } catch (e) {}
    return false;
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
      setState(() {}); // Update UI with position first

      // Once we have location, check radius
      final provider = Provider.of<VisitDetailProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      await provider.performRadiusCheck(
        customerId: widget.customerId,
        position: _currentPosition!,
        token: token,
      );

      // Reverse geocode
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
    final provider = Provider.of<VisitDetailProvider>(context, listen: false);
    final hasCheckedIn = provider.visitDetail?.startAt != null;

    // Foto wajib untuk checkin, dan juga untuk checkout
    if (_imageFile == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Foto Diperlukan'),
          content: Text(
            'Anda harus mengambil foto untuk ${hasCheckedIn ? 'check-out' : 'check-in'}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // ... (VPN, image, position checks remain the same)

    setState(() => _isSubmitting = true);

    try {
      bool success = false;
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      final sharedPreferences = await SharedPreferences.getInstance();

      if (hasCheckedIn) {
        // CHECK-OUT
        final realizationId = provider.visitDetail!.id;
        final data = {
          'customer_id': widget.customerId,
          'end_at': DateFormat('HH:mm:ss').format(DateTime.now()),
          'lat_end': _currentPosition!.latitude.toString(),
          'long_end': _currentPosition!.longitude.toString(),
          'notes': _notesController.text,
          'status': 'done-planned',
        };
        success = await provider.performCheckOut(
          realizationId: realizationId,
          data: data,
          photoPath: _imageFile!.path,
          token: token,
        );
      } else {
        // CHECK-IN
        final prefs = await SharedPreferences.getInstance();
        final unitBussinessId = prefs.getString('default_unit_business_id');
        final data = {
          'unit_business_id': unitBussinessId!,
          'customer_id': widget.customerId,
          'visit_id': widget.visitPlanId,
          'visit_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'start_at': DateFormat('HH:mm:ss').format(DateTime.now()),
          'lat_start': _currentPosition!.latitude.toString(),
          'long_start': _currentPosition!.longitude.toString(),
          'sales_id': Provider.of<AuthProvider>(
            context,
            listen: false,
          ).salesId!,
          'address': _currentAddress ?? '',
          'status': 'undone',
        };
        success = await provider.performCheckIn(
          data: data,
          photoPath: _imageFile!.path,
          token: token,
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Success!'),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VisitDetailProvider>(
      builder: (context, provider, child) {
        final visit = provider.visitDetail;
        final isLoading = provider.isLoading;

        final bool hasCheckedIn = visit?.startAt != null;
        final bool hasCheckedOut = visit?.endAt != null;

        final bool canSubmit =
            provider.isWithinRadius && !_isSubmitting && !hasCheckedOut;

        if (visit?.notes != null && _notesController.text.isEmpty) {
          _notesController.text = visit!.notes!;
        }

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundColor,
            elevation: 0,
            centerTitle: true,
            leading: const BackButton(color: Colors.black),
            title: Text(
              visit?.customer?.name ??
                  visit?.visitSalesDetail?.customerName ??
                  'Detail Visit',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: isLoading && visit == null && widget.realizationId != null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hasCheckedOut
                          ? _buildCompletedPhotos(visit)
                          : _buildActivePhotoPicker(visit, hasCheckedIn),
                      const SizedBox(height: 16),
                      _infoRow(
                        Icons.calendar_today,
                        DateFormat(
                          'EEEE, dd-MM-yyyy',
                          'id_ID',
                        ).format(visit?.visitDate ?? DateTime.now()),
                      ),
                      if (hasCheckedIn)
                        _infoRow(Icons.login, visit!.startAt ?? 'N/A'),
                      if (hasCheckedOut)
                        _infoRow(Icons.logout, visit!.endAt ?? 'N/A'),
                      const SizedBox(height: 12),
                      const Text(
                        "Lokasi Check-in",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        _currentAddress ??
                            visit?.address ??
                            'Mencari lokasi...',
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Latitude\n${_currentPosition?.latitude ?? visit?.latStart ?? 'N/A'}",
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Longitude\n${_currentPosition?.longitude ?? visit?.longStart ?? 'N/A'}",
                            ),
                          ),
                        ],
                      ),
                      if (hasCheckedOut) ...[
                        const SizedBox(height: 12),
                        const Text(
                          "Lokasi Check-out",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Latitude\n${visit?.latEnd ?? 'N/A'}",
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "Longitude\n${visit?.longEnd ?? 'N/A'}",
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (!hasCheckedOut)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            provider.radiusCheckMessage ??
                                'Getting location...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: provider.isWithinRadius
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        readOnly: hasCheckedOut,
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
          bottomSheet: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: hasCheckedOut
                ? ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Kembali",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ElevatedButton(
                    onPressed: canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasCheckedIn
                          ? Colors.deepOrange
                          : Colors.green,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            hasCheckedIn ? "Check Out" : "Check In",
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildActivePhotoPicker(
    VisitRealizationDetail? visit,
    bool hasCheckedIn,
  ) {
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
              : (visit?.photoStart != null && hasCheckedIn)
              ? DecorationImage(
                  image: NetworkImage(
                    '${ApiConstants.baseUrl2}/${visit?.photoStart}',
                  ),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    hasCheckedIn
                        ? "Ketuk untuk ambil foto checkout"
                        : "Ketuk untuk ambil foto checkin",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildCompletedPhotos(VisitRealizationDetail? visit) {
    return Row(
      children: [
        Expanded(
          child: _photoCard(
            "Check In",
            visit?.photoStart != null
                ? '${ApiConstants.baseUrl2}/${visit?.photoStart}'
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _photoCard(
            "Check Out",
            visit?.photoEnd != null
                ? '${ApiConstants.baseUrl2}/${visit?.photoEnd}'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _photoCard(String title, String? imageUrl) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xfff1f2f7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                )
              : const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                ),
        ),
      ],
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
