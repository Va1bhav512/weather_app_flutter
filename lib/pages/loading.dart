import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:weather_app_flutter/services/open_weather_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});
  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  Map<String, dynamic> d = {};
  User? user = FirebaseAuth.instance.currentUser;
  late String userId;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addUserData() async {
    String newData = d['query'];
    DocumentReference userDoc = firestore.collection('users').doc(userId);
    await userDoc.set({
      'userdata': FieldValue.arrayUnion([newData])
    }, SetOptions(merge: true));
  }
  void fetchSuggestions() async {
    OpenWeatherApi openWeatherApi = OpenWeatherApi();
    d = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    String query = d['query'];
    dynamic data = await openWeatherApi.getSuggestions(query);
    print(data);
    // for (var i in data) {
    //   print("${i['name']}, ${i['lat']}, ${i['lon']}, ${i['country']}");
    // }
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/selector',
          arguments: {'data': data});
    }
  }

  @override
  void initState() {
    super.initState();
    userId = user?.uid ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      fetchSuggestions();
      addUserData();
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
