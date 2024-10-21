import 'package:flutter/material.dart';

class Selector extends StatelessWidget {
  Selector({super.key});
  Map<String, dynamic> d = {};

  @override
  Widget build(BuildContext context) {
    d = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a location'),
      ),
      body: ListView.builder(
        itemCount: d['data'].length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(d['data'][index]['name']),
            subtitle: Text('${d['data'][index]['lat']}, ${d['data'][index]['lon']}, ${d['data'][index]['country']}, ${d['data'][index]['state']}'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/', arguments: {'lat': d['data'][index]['lat'], 'lon': d['data'][index]['lon']});
              print('Tapped on ${d['data'][index]['name']}');
            },
          );
        },
      ),
    );
  }
}