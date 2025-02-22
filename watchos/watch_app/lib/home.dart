import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterWearOsConnectivity _flutterWearOsConnectivity =
      FlutterWearOsConnectivity();
  List<WearOsDevice> _connectedDevices = [];
  // Add this to store received messages
  List<String> receivedMessages = [];

  @override
  void initState() {
    super.initState();
    _initializeWearConnectivity();
  }

  Future<void> _initializeWearConnectivity() async {
    _flutterWearOsConnectivity.configureWearableAPI();

    try {
      List<WearOsDevice> devices =
          await _flutterWearOsConnectivity.getConnectedDevices();
      if (devices.isNotEmpty) {
        setState(() {
          _connectedDevices = devices;
        });
        print("Connected to: ${devices.map((d) => d.name).join(', ')}");
      } else {
        print("No WearOS devices connected.");
      }
    } catch (e) {
      print("Error getting connected devices: $e");
    }

    // Message Listener
    _flutterWearOsConnectivity
        .messageReceived()
        .listen((WearOSMessage message) {
      inspect(message);
      String messageContent = String.fromCharCodes(message.data);
      print("📱 Received message: $messageContent on path: ${message.path}");

      // Update UI with received message
      setState(() {
        receivedMessages.add('${message.path}: $messageContent');
      });
    });
  }

  Future<void> sendTestMessage() async {
    if (_connectedDevices.isEmpty) {
      print("❌ No connected WearOS device found!");
      return;
    }

    Uint8List messageBytes = Uint8List.fromList("Hello from watch!".codeUnits);
    try {
      await _flutterWearOsConnectivity.sendMessage(
        messageBytes,
        deviceId: _connectedDevices.first.id,
        path: "/sample-message",
        priority: MessagePriority.low,
      );
      print("✅ Message sent successfully.");
    } catch (e) {
      print("❌ Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'Connected Devices: \n${_connectedDevices.map((d) => d.name).join(", ")}',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: sendTestMessage,
                child: const Text("Send Test Message"),
              ),
              const SizedBox(height: 8),
              const Text('Received Messages:'),
              Expanded(
                child: ListView.builder(
                  itemCount: receivedMessages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        receivedMessages[index].split(":").last,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
