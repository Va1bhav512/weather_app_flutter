import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app_flutter/firebase_options.dart';
import 'package:weather_app_flutter/pages/home.dart';
import 'package:weather_app_flutter/pages/loading.dart';
import 'package:weather_app_flutter/pages/selector.dart';
import 'package:weather_app_flutter/pages/loading_weather_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_app_flutter/auth.dart';
import 'package:weather_app_flutter/services/firebase_login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    throw Exception('Failed to load .env file');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      // consthome: Home(),
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user != null) {
              return const LoadingWeatherData(); // User is signed in
            } else {
              return FirebaseLogin(); // User is not signed in
            }
          } else {
            return const SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50,
            ); // Waiting for connection state
          }
        },
      ),

      debugShowCheckedModeBanner: false,
      routes: {
        '/loadingweatherdata': (context) => const LoadingWeatherData(),
        '/home': (context) => Home(),
        '/loading': (context) => const Loading(),
        '/placeholder': (context) => const Placeholder(),
        '/selector': (context) => Selector(),
        '/login': (context) => FirebaseLogin(),
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