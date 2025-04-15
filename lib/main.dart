import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLC Data',
      home: Scaffold(
        appBar: AppBar(
          title: Text('PLC Data'),
        ),
        body: Center(
          child: FutureBuilder(
            future: fetchPLCData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                var data = snapshot.data;
                return Text('Temperature: ${data?['temperature']}\n'
                    'Pump State: ${data?['pumpState']}\n'
                    'Counter: ${data?['counter']}');
              }
            },
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchPLCData() async {
    final response = await http.get(Uri.parse('http://109.71.242.101:3000/plc-data'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
