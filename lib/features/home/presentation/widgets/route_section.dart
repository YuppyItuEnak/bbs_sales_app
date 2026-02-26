import 'package:bbs_sales_app/data/services/visit/visit_repository.dart';
import 'package:bbs_sales_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:bbs_sales_app/features/visit/presentation/pages/list_visit_page.dart';
import 'package:bbs_sales_app/features/visit/presentation/pages/route_map_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'home_card_decoration.dart';

class RouteSection extends StatefulWidget {
  const RouteSection({super.key});

  @override
  State<RouteSection> createState() => _RouteSectionState();
}

class _RouteSectionState extends State<RouteSection> {
  final VisitRepository _repository = VisitRepository();
  List<Marker> _markers = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();

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

      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final visits = await _repository.fetchVisitRoute(
        auth.salesId!,
        date,
        auth.token!,
      );

      if (!mounted) return;

      List<Marker> markers = [];

      for (var i = 0; i < visits.length; i++) {
        final visit = visits[i];
        final lat = double.tryParse(visit['lat_end']?.toString() ?? '');
        final lng = double.tryParse(visit['long_end']?.toString() ?? '');

        if (lat != null && lng != null) {
          markers.add(
            Marker(
              point: LatLng(lat, lng),
              width: 28,
              height: 28,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }
      }

      setState(() {
        _markers = markers;
        _isLoading = false;
      });

      _fitBounds();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      if (kDebugMode) {
        print('Error loading route preview: $e');
      }
    }
  }

  void _fitBounds() {
    if (_markers.isEmpty) return;

    // Calculate bounds
    double? minLat, maxLat, minLng, maxLng;
    for (final marker in _markers) {
      final p = marker.point;
      if (minLat == null || p.latitude < minLat) minLat = p.latitude;
      if (maxLat == null || p.latitude > maxLat) maxLat = p.latitude;
      if (minLng == null || p.longitude < minLng) minLng = p.longitude;
      if (maxLng == null || p.longitude > maxLng) maxLng = p.longitude;
    }

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
                padding: const EdgeInsets.all(20),
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Lihat Rute Hari Ini",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListVisitPage(),
                  ),
                );
              },
              child: const Text(
                "Lihat Riwayat",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RouteMapPage()),
            );
          },
          child: Container(
            height: 140,
            decoration: homeCardDecoration(),
            clipBehavior: Clip.antiAlias,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      AbsorbPointer(
                        child: FlutterMap(
                          mapController: _mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(-6.200000, 106.816666),
                            initialZoom: 10,
                            interactionOptions: InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.bbs.sales.app',
                            ),
                            MarkerLayer(markers: _markers),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
