import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app_flutter/services/open_weather_api.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final DateTime now = DateTime.now();
  final TextEditingController textEditingController = TextEditingController();
  final OpenWeatherApi openWeatherApi = OpenWeatherApi();

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> d = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    print(d);

    // Safely extracting necessary data from the map
    String cityName = d['data']['name'] ?? 'Unknown City';
    double temperature = (d['data']['main']['temp'] ?? 0) - 273.15; // Convert Kelvin to Celsius
    String weatherMain = d['data']['weather'][0]['main'] ?? 'No Data';
    String weatherDescription = d['data']['weather'][0]['description'] ?? 'No Data';
    double windSpeed = d['data']['wind']['speed'] ?? 0;
    int humidity = d['data']['main']['humidity'] ?? 0;
    String country = d['data']['sys']['country'] ?? 'Unknown Country';

    return Scaffold(
      appBar: AppBar(
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
        title: Text(DateFormat('EEE, dd MMM, yyyy').format(now),
            style: const TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$cityName, $country',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${temperature.toStringAsFixed(1)} °C',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              weatherMain,
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              weatherDescription,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Humidity: $humidity%', style: const TextStyle(fontSize: 18)),
                Text('Wind Speed: ${windSpeed.toStringAsFixed(1)} m/s', style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
