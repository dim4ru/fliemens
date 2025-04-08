import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siemens PLC TCP/IP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PLCConnectionPage(),
    );
  }
}

class PLCConnectionPage extends StatefulWidget {
  @override
  _PLCConnectionPageState createState() => _PLCConnectionPageState();
}

class _PLCConnectionPageState extends State<PLCConnectionPage> {
  final String _plcIpAddress = '192.168.0.5'; // Replace with your PLC IP
  final int _plcPort = 102; // Default Siemens S7 port
  Socket? _socket;
  String _connectionStatus = 'Disconnected';
  String _receivedData = 'No data received yet';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    connectToPLC();
  }

  void connectToPLC() async {
    try {
      _socket = await Socket.connect(_plcIpAddress, _plcPort, timeout: Duration(seconds: 5));
      setState(() {
        _connectionStatus = 'Connected';
        _isConnected = true;
      });
      _socket?.listen(
        (List<int> data) {
          setState(() {
            _receivedData = utf8.decode(data); // Assuming data is UTF-8 encoded
          });
          print('Data received: ${utf8.decode(data)}');
        },
        onError: (error) {
          print('Error: $error');
          setState(() {
            _connectionStatus = 'Error: $error';
            _isConnected = false;
          });
        },
        onDone: () {
          print('Connection closed.');
          setState(() {
            _connectionStatus = 'Disconnected';
            _isConnected = false;
          });
          _socket?.destroy();
        },
      );
      print('Connected to: ${_socket?.remoteAddress.address}:${_socket?.remotePort}');
    } catch (e) {
      print('Failed to connect: $e');
      setState(() {
        _connectionStatus = 'Failed to connect: $e';
        _isConnected = false;
      });
    }
  }

  @override
  void dispose() {
    _socket?.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Siemens PLC TCP/IP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Connection Status: $_connectionStatus'),
            SizedBox(height: 20),
            Text('Received Data: $_receivedData'),
          ],
        ),
      ),
    );
  }
}
