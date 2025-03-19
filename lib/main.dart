import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List

import 'package:flutter/material.dart';
import 'package:dart_snap7/dart_snap7.dart'; // Correct import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siemens PLC Snap7',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PLCConnectionPage(),
    );
  }
}

class PLCConnectionPage extends StatefulWidget {
  @override
  _PLCConnectionPageState createState() => _PLCConnectionPageState();
}

class _PLCConnectionPageState extends State<PLCConnectionPage> {
  final String _plcIpAddress = '192.168.1.10'; // Replace with your PLC IP
  final int _rack = 0;
  final int _slot = 1;
  final int _dbNumber = 1; // Data Block number
  final int _startOffset = 0; // Start position
  final int _dataSize = 4; // Data size in bytes

  late final _client; // Declare _client as a variable of type S7Client

  String _connectionStatus = 'Disconnected';
  String _receivedData = 'No data received yet';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    connectToPLC();
  }

  Future<void> connectToPLC() async {
    try {
      _client.connect(_plcIpAddress, _rack, _slot); // Connect using S7Client
      setState(() {
        _connectionStatus = 'Connected';
        _isConnected = true;
      });
      readPLCData();
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection failed: $e';
        _isConnected = false;
      });
    }
  }

  Future<void> readPLCData() async {
    if (!_isConnected) return;
    try {
      final Uint8List data = _client.dbRead(
          _dbNumber, _startOffset, _dataSize); // Use dbRead from S7Client
      setState(() {
        _receivedData = data.toString();
      });
    } catch (e) {
      setState(() {
        _receivedData = 'Read failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Siemens PLC Snap7')),
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