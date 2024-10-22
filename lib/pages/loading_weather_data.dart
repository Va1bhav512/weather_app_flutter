import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_app_flutter/services/open_weather_api.dart';

class LoadingWeatherData extends StatefulWidget {
  const LoadingWeatherData({super.key});

  @override
  State<LoadingWeatherData> createState() => _LoadingWeatherDataState();
}

class _LoadingWeatherDataState extends State<LoadingWeatherData> {
  Map<String, dynamic> d = {};

  void fetchData() async {
    OpenWeatherApi openWeatherApi = OpenWeatherApi();
    var routeArgs = ModalRoute.of(context)?.settings.arguments;

    if (routeArgs != null && routeArgs is Map<String, dynamic>) {
      d = routeArgs; // Assign routeArgs to d
    }

    // Check for lat and lon, and add default values if they are missing
    d.putIfAbsent('lat', () => 28.644800); // Default lat for Delhi
    d.putIfAbsent('lon', () => 77.216721); // Default lon for Delhi

    // Now use the values in d
    double lat = d['lat'];
    double lon = d['lon'];

    dynamic data = await openWeatherApi.getWeatherData(lat, lon);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home', arguments: {'data': data});
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SpinKitWanderingCubes(color: Colors.blue, size: 50.0),
      ),
    );
  }
}
