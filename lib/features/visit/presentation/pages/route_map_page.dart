import 'package:bbs_sales_app/core/constants/app_colors.dart';
import 'package:bbs_sales_app/data/services/visit/visit_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class RouteMapPage extends StatefulWidget {
  const RouteMapPage({super.key});

  @override
  State<RouteMapPage> createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  final VisitRepository _repository = VisitRepository();
  final MapController _mapController = MapController();

  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  List<Map<String, dynamic>> _visits = [];
  Map<String, dynamic>? _selectedVisit;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRoute();
    });
  }

  Future<void> _fetchRoute() async {
    try {
      final auth = context.read<AuthProvider>();
      if (auth.token == null || auth.salesId == null) return;

      // Using current date as default, or you can pass a date
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final visits = await _repository.fetchVisitRoute(
        auth.salesId!,
        date,
        auth.token!,
      );

      if (mounted) {
        setState(() {
          _visits = visits;
          _createMarkersAndPolyline();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat rute: $e')));
      }
    }
  }

  void _createMarkersAndPolyline() {
    List<Marker> markers = [];
    List<LatLng> polylineCoords = [];
    double? minLat, maxLat, minLng, maxLng;

    for (var i = 0; i < _visits.length; i++) {
      final visit = _visits[i];
      final lat = double.tryParse(visit['lat_end']?.toString() ?? '');
      final lng = double.tryParse(visit['long_end']?.toString() ?? '');

      if (lat != null && lng != null) {
        final position = LatLng(lat, lng);
        polylineCoords.add(position);

        markers.add(
          Marker(
            point: position,
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedVisit = visit;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );

        // Calculate bounds logic
        if (minLat == null || lat < minLat) minLat = lat;
        if (maxLat == null || lat > maxLat) maxLat = lat;
        if (minLng == null || lng < minLng) minLng = lng;
        if (maxLng == null || lng > maxLng) maxLng = lng;
      }
    }

    setState(() {
      _markers = markers;
      _polylines = polylineCoords.isNotEmpty
          ? [
              Polyline(
                color: Colors.blue,
                strokeWidth: 4,
                points: polylineCoords,
                pattern: StrokePattern.dashed(segments: [10, 10]),
              ),
            ]
          : [];
    });

    if (minLat != null && maxLat != null && minLng != null && maxLng != null) {
      final bounds = LatLngBounds(
        LatLng(minLat, minLng),
        LatLng(maxLat, maxLng),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          if (bounds.northEast == bounds.southWest) {
            _mapController.move(bounds.center, 15.0);
          } else {
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(50),
              ),
            );
          }
        }
      });
    }
  }

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
            'Rute Kunjungan',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: LatLng(-6.200000, 106.816666),
                      initialZoom: 10,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.bbs.sales.app',
                      ),
                      PolylineLayer(polylines: _polylines),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
                  if (_selectedVisit != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedVisit?['customer_name'] ??
                                  'Unknown Customer',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(_selectedVisit?['address'] ?? '-'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.login,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "In: ${_selectedVisit?['start_at'] ?? '-'}",
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.logout,
                                  size: 16,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Out: ${_selectedVisit?['end_at'] ?? '-'}",
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
