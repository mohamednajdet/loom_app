import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart'; // ✅ إضافة

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late MapboxMap _mapboxMap;
  final _logger = Logger();
  final TextEditingController _searchController = TextEditingController();

  Point _selectedPoint = Point(
    coordinates: Position(44.3661, 33.3152),
  ); // بغداد
  bool _gpsChecked = false;
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      geo.LocationPermission permission =
          await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
        if (permission == geo.LocationPermission.deniedForever) return;
      }

      final current = await geo.Geolocator.getCurrentPosition();
      final newPoint = Point(
        coordinates: Position(current.longitude, current.latitude),
      );

      if (mounted) {
        setState(() {
          _selectedPoint = newPoint;
          _gpsChecked = true;
        });

        _mapboxMap.flyTo(
          CameraOptions(center: newPoint, zoom: 15),
          MapAnimationOptions(duration: 1000),
        );
      }
    } catch (_) {}
  }

  Future<void> _searchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    try {
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?access_token=pk.eyJ1IjoibW9oYW1tZWRuYWpkZXQiLCJhIjoiY21ibjJ3a3dqMWlrOTJqcjFpbGtrNjNxZyJ9.b3W25F4loDoXLZC59uEoqA';

      final dio = Dio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() => _suggestions = data['features']);
      }
    } catch (e) {
      _logger.e('❌ خطأ أثناء جلب الاقتراحات', error: e);
    }
  }

  void _selectSuggestion(dynamic feature) {
    final coords = feature['center'];
    final lng = coords[0];
    final lat = coords[1];

    final point = Point(coordinates: Position(lng, lat));
    setState(() {
      _selectedPoint = point;
      _suggestions = [];
      _searchController.clear();
    });

    _mapboxMap.flyTo(
      CameraOptions(center: point, zoom: 15),
      MapAnimationOptions(duration: 1000),
    );
  }

  Future<String> getPlaceNameFromLatLng(double lat, double lng) async {
    try {
      final url =
          'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json?access_token=pk.eyJ1IjoibW9oYW1tZWRuYWpkZXQiLCJhIjoiY21ibjJ3a3dqMWlrOTJqcjFpbGtrNjNxZyJ9.b3W25F4loDoXLZC59uEoqA';

      final response = await Dio().get(url);
      final features = response.data['features'];

      if (features != null && features.isNotEmpty) {
        return features[0]['place_name'] ?? 'موقع بدون اسم';
      } else {
        return 'موقع بدون اسم';
      }
    } catch (e) {
      _logger.e('❌ فشل جلب اسم المكان', error: e);
      return 'موقع بدون اسم';
    }
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
            cameraOptions: CameraOptions(center: _selectedPoint, zoom: 14),
            onMapCreated: (controller) {
              _mapboxMap = controller;

              _mapboxMap.addListener(() async {
                final state = await _mapboxMap.getCameraState();
                setState(() {
                  _selectedPoint = state.center;
                });
              });

              if (!_gpsChecked) _getUserLocation();
            },
          ),

          const Center(
            child: Icon(Icons.location_pin, size: 40, color: Color(0xFF546E7A)),
          ),

          // 🔍 حقل البحث + الاقتراحات
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchSuggestions,
                    decoration: const InputDecoration(
                      hintText: 'اكتب العنوان هنا...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFF546E7A)),
                    ),
                  ),
                ),
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    height: 200,
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        final item = _suggestions[index];
                        return ListTile(
                          title: Text(item['place_name'] ?? ''),
                          onTap: () => _selectSuggestion(item),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ✅ زر تحديد الموقع (GPS)
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _getUserLocation,
              child: const Icon(Icons.my_location, color: Color(0xFF546E7A)),
            ),
          ),

          // ✅ أزرار تأكيد وإلغاء
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.pop(), // ✅ إلغاء
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29434E),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final cameraState = await _mapboxMap.getCameraState();
                      final double lat =
                          cameraState.center.coordinates.lat.toDouble();
                      final double lng =
                          cameraState.center.coordinates.lng.toDouble();
                      final label = await getPlaceNameFromLatLng(lat, lng);

                      if (!mounted) return;
                      // ignore: use_build_context_synchronously
                      context.pop({'lat': lat, 'lng': lng, 'label': label});
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF546E7A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'تأكيد الموقع على الخريطة',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Cairo',
                      ),
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
}
