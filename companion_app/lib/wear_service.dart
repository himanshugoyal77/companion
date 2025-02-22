import 'dart:typed_data';
import 'package:flutter_wear_os_connectivity/flutter_wear_os_connectivity.dart';

class WearService {
  final _wearOsConnectivity = FlutterWearOsConnectivity();
  WearOsDevice? _selectedDevice; // No 'late'

  Future<void> init() async {
    
    print("wearosconnectivity: ${await _wearOsConnectivity.messageReceived()}");
    var msg = _wearOsConnectivity.messageReceived();

    print("wearosconnectivity xxx: $msg");
    List<WearOsDevice> devices =
        await _wearOsConnectivity.getConnectedDevices();
    print("wearosconnectivity devices: $devices");
    try {
      List<WearOsDevice> devices =
          await _wearOsConnectivity.getConnectedDevices();
      print("wearosconnectivity devices: $devices");
      if (devices.isNotEmpty) {
        _selectedDevice = devices.first;
      }
    } catch (e) {
      print('Error getting connected devices: $e');
    }
  }

  void _handleWearMessage(WearOSMessage message) async {
    if (message.path == '/request_login') {
      await sendAuthToken('your-auth-token');
    }
  }

  Future<void> sendAuthToken(String token) async {
    if (_selectedDevice == null) {
      throw Exception('No WearOS device connected');
    }

    Uint8List bytes = Uint8List.fromList(token.codeUnits);
    await _wearOsConnectivity.sendMessage(
      bytes,
      deviceId: _selectedDevice!.id,
      path: "/auth_token",
      priority: MessagePriority.high,
    );
  }
}
