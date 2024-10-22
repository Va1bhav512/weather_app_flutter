import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_flutter/services/firebase_login.dart';
import 'package:weather_app_flutter/services/open_weather_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_app_flutter/auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DateTime now = DateTime.now();
  final TextEditingController textEditingController = TextEditingController();
  final OpenWeatherApi openWeatherApi = OpenWeatherApi();
  late final MapController mapController;
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapFromData();
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  void _updateMap(double lat, double lon) {
    print('Attempting to update map with lat: $lat, lon: $lon');

    if (!lat.isFinite || !lon.isFinite) {
      print('Error: Invalid coordinates - lat: $lat, lon: $lon');
      _moveToDefaultLocation();
      return;
    }

    if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
      print('Error: Coordinates out of range - lat: $lat, lon: $lon');
      _moveToDefaultLocation();
      return;
    }

    try {
      setState(() {
        mapController.move(LatLng(lat, lon), 5.0);
      });
      print('Successfully moved map to lat: $lat, lon: $lon');
    } catch (e) {
      print('Error moving map: $e');
      _moveToDefaultLocation();
    }
  }

  void _moveToDefaultLocation() {
    setState(() {
      mapController.move(const LatLng(28.644800, 77.216721), 5.0);
      print('Moved to default location');
    });
  }

  void _updateMapFromData() {
    final data =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final lat = data?['data']?['coord']?['lat']?.toDouble();
    final lon = data?['data']?['coord']?['lon']?.toDouble();
    if (lat != null && lon != null) {
      _updateMap(lat, lon);
    } else {
      _moveToDefaultLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> d =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    // Safely extracting necessary data from the map
    final String cityName = d['data']?['name'] ?? 'Unknown City';
    final double temperature =
        ((d['data']?['main']?['temp'] ?? 273.15) - 273.15);
    final String weatherMain = d['data']?['weather']?[0]?['main'] ?? 'No Data';
    final String weatherDescription =
        d['data']?['weather']?[0]?['description'] ?? 'No Data';
    final double windSpeed = d['data']?['wind']?['speed']?.toDouble() ?? 0.0;
    final int humidity = d['data']?['main']?['humidity'] ?? 0;
    final String country = d['data']?['sys']?['country'] ?? 'Unknown Country';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('EEE, dd MMM, yyyy').format(now),
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Search location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(22.0)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/loading',
                  arguments: {'query': textEditingController.text},
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location and Basic Weather Info
              Text(
                '$cityName, $country',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Temperature and Weather
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${temperature.toStringAsFixed(1)} °C',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          weatherMain,
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          weatherDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weather Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            'Humidity',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '$humidity%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.air, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            'Wind Speed',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${windSpeed.toStringAsFixed(1)} m/s',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.compress, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text(
                            'Pressure',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${d['data']?['main']?['pressure'] ?? 'N/A'} hPa',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Map Section
              Card(
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter: const LatLng(28.644800, 77.216721),
                          initialZoom: 5,
                          minZoom: 2,
                          maxZoom: 18,
                          keepAlive: true,
                          cameraConstraint: CameraConstraint.contain(
                            bounds: LatLngBounds(
                              const LatLng(-90, -180),
                              const LatLng(90, 180),
                            ),
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                            tileProvider: NetworkTileProvider(),
                            maxZoom: 18,
                            minZoom: 2,
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  d['data']?['coord']?['lat']?.toDouble() ??
                                      28.644800,
                                  d['data']?['coord']?['lon']?.toDouble() ??
                                      77.216721,
                                ),
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: FloatingActionButton.small(
                          onPressed: _updateMapFromData,
                          child: const Icon(Icons.my_location),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Additional Weather Info
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Visibility: ${(d['data']?['visibility'] ?? 0) / 1000} km'),
                      if (d['data']?['rain']?['1h'] != null)
                        Text('Rain (1h): ${d['data']?['rain']?['1h']} mm'),
                      if (d['data']?['snow']?['1h'] != null)
                        Text('Snow (1h): ${d['data']?['snow']?['1h']} mm'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _auth.signOut();
          // Navigator.pushReplacementNamed(context, '/login');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => FirebaseLogin()),
            (Route<dynamic> route) => false,
          );
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
}
