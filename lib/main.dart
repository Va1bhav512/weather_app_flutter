import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app_flutter/pages/home.dart';
import 'package:weather_app_flutter/pages/loading.dart';
import 'package:weather_app_flutter/pages/selector.dart';
import 'package:weather_app_flutter/pages/loading_weather_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
  await dotenv.load(fileName: '.env');
  } catch (e) {
    throw Exception('Failed to load .env file');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: Home(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const LoadingWeatherData(),
        '/home': (context) => Home(),
        '/loading': (context) => const Loading(),
        '/placeholder': (context) => const Placeholder(),
        '/selector': (context) => Selector(),
      },
    );
  }
}
// class Hcwome extends StatelessWidget {
//   final OpenWeatherApi openWeatherApi = OpenWeatherApi();
//   Hcwome({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Weather App'),),
//       body: Center(child: ElevatedButton(onPressed: () async {
//         // openWeatherApi.getWeatherData(28.644800, 77.216721);
//         openWeatherApi.getSuggestions('Paris');
//       }, child: const Text('Delhi')),)
//     );
//   }
// }