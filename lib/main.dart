import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PLC Data App',
      home: PlcDataScreen(),
    );
  }
}

class PlcDataScreen extends StatefulWidget {
  @override
  _PlcDataScreenState createState() => _PlcDataScreenState();
}

class _PlcDataScreenState extends State<PlcDataScreen> {
  IO.Socket? socket;
  double plcValue = 0.0;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    try {
      socket = IO.io('http://192.168.31.236:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      socket!.on('connect', (_) {
        print('Подключено к серверу Socket.IO');
        setState(() {
          errorMessage = ''; // Очищаем сообщение об ошибке при успешном подключении
        });
      });

      socket!.on('plcData', (data) {
        setState(() {
          plcValue = data;
        });
      });

      socket!.on('connect_error', (data) {
        print('Ошибка подключения: $data');
        setState(() {
          errorMessage = 'Ошибка подключения к серверу: $data';
        });
      });

      socket!.on('disconnect', (_) {
        print('Отключено от сервера Socket.IO');
        setState(() {
          errorMessage = 'Отключено от сервера Socket.IO';
        });
      });

      socket!.connect();
    } catch (e) {
      print('Ошибка подключения: $e');
      setState(() {
        errorMessage = 'Ошибка подключения: $e';
      });
    }
  }

  @override
  void dispose() {
    socket!.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PLC Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            Text(
              'Значение ПЛК: $plcValue',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}