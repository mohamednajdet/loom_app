import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapboxMap _mapboxMap;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = const LatLng(33.3152, 44.3661); // بغداد
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(
            key: const ValueKey("mapWidget"),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            textureView: true,
            cameraOptions: CameraOptions(
              center: Point(coordinates: _selectedLocation).toJson(),
              zoom: 15,
            ),
            onMapCreated: (mapboxMap) {
              _mapboxMap = mapboxMap;

              _mapboxMap.addOnCameraChangedListener(() async {
                final state = await _mapboxMap.getCameraState();
                final center = state.center;

                if (center != null) {
                  setState(() {
                    _selectedLocation = LatLng(center.lat!, center.lng!);
                  });
                }
              });
            },
          ),

          const Center(
            child: Icon(Icons.location_pin, size: 40, color: Color(0xFF546E7A)),
          ),

          Positioned(
            top: 40,
            left: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location, color: Color(0xFF546E7A)),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29434E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selectedLocation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF546E7A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'تأكيد الموقع على الخريطة',
                      style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    // لازم تتنفذ من الواجهة، أو من صلاحية GPS داخل النظام
    // حالياً نرجع نفس الإحداثيات
    await _mapboxMap.flyTo(
      CameraOptions(
        center: Point(coordinates: _selectedLocation).toJson(),
        zoom: 15,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }
}
