import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_app_flutter/services/open_weather_api.dart';

class LoadingWeatherData extends StatefulWidget {
  const LoadingWeatherData({super.key});

  @override
  State<LoadingWeatherData> createState() => _LoadingWeatherDataState();
}

class _LoadingWeatherDataState extends State<LoadingWeatherData> {
  Map<String, dynamic>? d =  {'lat': 28.644800, 'lon': 77.216721};

  void fetchData() async {
    OpenWeatherApi openWeatherApi = OpenWeatherApi();
    var routeArgs = ModalRoute.of(context)?.settings.arguments;
    if (routeArgs != null && routeArgs is Map<String, dynamic>) {
      d = routeArgs;
    } else {
      d = {'lat': 28.644800, 'lon': 77.216721};
    }

    // Use d['lat'] if it exists, otherwise use def['lat'] default values refer to Delhi
    double lat = d?['lat'];
    double lon = d?['lon'];

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
