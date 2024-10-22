import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_app_flutter/services/open_weather_api.dart';
import 'package:weather_app_flutter/auth.dart';

Future<List<String>> getUserData() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  String userId = user?.uid ?? '';
  DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();
  List<String> userData = List.from(userDoc['userdata'] ?? []);
  return userData;
}

Icon getWeatherIcon(String weatherMain, double temperature) {
  if (weatherMain.toLowerCase().contains('rain')) {
    return const Icon(
      Icons.beach_access,
      size: 48,
      color: Colors.blue,
    );
  } else if (weatherMain.toLowerCase().contains('cloud')) {
    return const Icon(
      Icons.cloud,
      size: 48,
      color: Colors.grey,
    );
  } else if (temperature > 30) {
    return const Icon(
      Icons.wb_sunny,
      size: 48,
      color: Colors.orange,
    );
  } else if (temperature < 10) {
    return const Icon(
      Icons.ac_unit,
      size: 48,
      color: Colors.lightBlue,
    );
  } else {
    return const Icon(
      Icons.wb_sunny,
      size: 48,
      color: Colors.yellow,
    );
  }
}

// Search Bar Widget with History
class SearchBarWithHistory extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchBarWithHistory({
    Key? key,
    required this.controller,
    required this.onSearch,
  }) : super(key: key);

  @override
  State<SearchBarWithHistory> createState() => _SearchBarWithHistoryState();
}

class _SearchBarWithHistoryState extends State<SearchBarWithHistory> {
  List<String> searchHistory = [];
  bool isSearching = false;
  final GlobalKey searchFieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    if (widget.controller.text.isEmpty) {
      _removeOverlay();
      setState(() => isSearching = false);
    } else {
      setState(() => isSearching = true);
      _showOverlay();
    }
  }

  Future<void> _loadSearchHistory() async {
    searchHistory = await getUserData();
    setState(() {});
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _removeOverlay();

    // Get the RenderBox of the search field
    final RenderBox? renderBox = 
        searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Get the position of the search field
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: offset.dy + size.height + 5,
        left: offset.dx,
        width: size.width,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: 200,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: searchHistory.length,
              itemBuilder: (context, index) {
                final historyItem = searchHistory[index];
                if (historyItem.toLowerCase().contains(
                      widget.controller.text.toLowerCase(),
                    )) {
                  return ListTile(
                    title: Text(historyItem),
                    onTap: () {
                      widget.controller.text = historyItem;
                      widget.onSearch(historyItem);
                      _removeOverlay();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: searchFieldKey,
      child: TextField(
        controller: widget.controller,
        onTap: () {
          if (widget.controller.text.isNotEmpty) {
            _showOverlay();
          }
        },
        decoration: InputDecoration(
          hintText: 'Search location',
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(22.0)),
          ),
          filled: true,
          fillColor: Colors.white70,
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              widget.onSearch(widget.controller.text);
              _removeOverlay();
            },
          ),
        ),
        onSubmitted: (value) {
          widget.onSearch(value);
          _removeOverlay();
        },
      ),
    );
  }
}

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
    if (lat.isFinite &&
        lon.isFinite &&
        lat >= -90 &&
        lat <= 90 &&
        lon >= -180 &&
        lon <= 180) {
      setState(() {
        mapController.move(LatLng(lat, lon), 5.0);
      });
    } else {
      _moveToDefaultLocation();
    }
  }

  void _moveToDefaultLocation() {
    setState(() {
      mapController.move(const LatLng(28.644800, 77.216721), 5.0);
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
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

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
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue[700],
        elevation: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              width: 250,
              child: SearchBarWithHistory(
                controller: textEditingController,
                onSearch: (query) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/loading',
                    arguments: {'query': query},
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: Colors.lightBlue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$cityName, $country',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
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
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  weatherMain,
                                  style: const TextStyle(
                                      fontSize: 24, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          getWeatherIcon(weatherMain, temperature),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weatherDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Humidity: ${humidity}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'Wind: ${windSpeed} m/s',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: Colors.lightGreen[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.water_drop, color: Colors.blue),
                          const SizedBox(height: 8),
                          Text('Humidity',
                              style: Theme.of(context).textTheme.bodySmall),
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
                          Text('Wind Speed',
                              style: Theme.of(context).textTheme.bodySmall),
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
                          Text('Pressure',
                              style: Theme.of(context).textTheme.bodySmall),
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

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: mapController,
                        options: const MapOptions(
                          initialCenter: LatLng(28.644800, 77.216721),
                          initialZoom: 5,
                          minZoom: 2,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  d['data']?['coord']?['lat']?.toDouble() ?? 28.644800,
                                  d['data']?['coord']?['lon']?.toDouble() ?? 77.216721,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.pink[50],
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
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Visibility: ${(d['data']?['visibility'] ?? 0) / 1000} km',
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      if (d['data']?['rain']?['1h'] != null)
                        Text(
                          'Rain (1h): ${d['data']?['rain']?['1h']} mm',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      if (d['data']?['snow']?['1h'] != null)
                        Text(
                          'Snow (1h): ${d['data']?['snow']?['1h']} mm',
                          style: const TextStyle(color: Colors.black54),
                        ),
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
          Navigator.pushReplacementNamed(context, '/login');
        },
        backgroundColor: Colors.lightBlue[700],
        child: const Icon(Icons.logout),
      ),
    );
  }
}