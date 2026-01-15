import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDevice {
  final String name;
  final String address;
  
  BluetoothDevice({required this.name, required this.address});
}

class PrinterService extends ChangeNotifier {
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isScanning = false;

  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get selectedDevice => _selectedDevice;
  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;

  PrinterService() {
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    _isConnected = await PrintBluetoothThermal.connectionStatus;
    notifyListeners();
  }

  Future<void> getBondedDevices() async {
    _isScanning = true;
    notifyListeners();

    try {
      // Request Bluetooth permissions
      if (await Permission.bluetoothScan.request().isGranted ||
          await Permission.bluetoothConnect.request().isGranted ||
          await Permission.location.request().isGranted) {
        
        final List<BluetoothInfo> bondedDevices = await PrintBluetoothThermal.pairedBluetooths;
        
        _devices = bondedDevices.map((device) => BluetoothDevice(
          name: device.name,
          address: device.macAdress,
        )).toList();
      }
    } catch (e) {
      debugPrint("Error getting bonded devices: $e");
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    if (_isConnected) {
      await disconnect();
    }
    
    try {
      final result = await PrintBluetoothThermal.connect(macPrinterAddress: device.address);
      if (result) {
        _selectedDevice = device;
        _isConnected = true;
      }
    } catch (e) {
      debugPrint("Error connecting to printer: $e");
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      _selectedDevice = null;
      _isConnected = false;
    } catch (e) {
      debugPrint("Error disconnecting: $e");
    }
    notifyListeners();
  }

  Future<void> printTestTicket() async {
    if (!_isConnected) return;

    try {
      List<int> bytes = [];
      
      // ESC/POS commands for test print
      bytes += [0x1B, 0x40]; // Initialize printer
      bytes += [0x1B, 0x61, 0x01]; // Center align
      
      // Print text
      bytes += 'ROCKSTER TEST PRINT\n'.codeUnits;
      bytes += '========================\n'.codeUnits;
      bytes += '\n'.codeUnits;
      bytes += 'If you can read this,\n'.codeUnits;
      bytes += 'your printer is working!\n'.codeUnits;
      bytes += '\n'.codeUnits;
      bytes += '========================\n'.codeUnits;
      bytes += '\n\n\n'.codeUnits;
      
      // Cut paper (if supported)
      bytes += [0x1D, 0x56, 0x00];
      
      await PrintBluetoothThermal.writeBytes(bytes);
      
    } catch (e) {
      debugPrint("Error printing test ticket: $e");
    }
  }

  Future<void> printReceipt({
    required String orderNumber,
    required String customerName,
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    if (!_isConnected) return;

    try {
      List<int> bytes = [];
      
      // Initialize
      bytes += [0x1B, 0x40];
      bytes += [0x1B, 0x61, 0x01]; // Center
      
      // Header
      bytes += 'ROCKSTER ORDER\n'.codeUnits;
      bytes += '========================\n'.codeUnits;
      bytes += 'Order #$orderNumber\n'.codeUnits;
      bytes += '$customerName\n'.codeUnits;
      bytes += '========================\n'.codeUnits;
      bytes += '\n'.codeUnits;
      
      // Left align for items
      bytes += [0x1B, 0x61, 0x00];
      
      for (var item in items) {
        final name = item['name'] ?? 'Item';
        final qty = item['quantity'] ?? 1;
        final price = item['price'] ?? 0.0;
        bytes += '$qty x $name - €${price.toStringAsFixed(2)}\n'.codeUnits;
      }
      
      bytes += '\n'.codeUnits;
      bytes += '------------------------\n'.codeUnits;
      bytes += 'TOTAL: €${total.toStringAsFixed(2)}\n'.codeUnits;
      bytes += '========================\n'.codeUnits;
      bytes += '\n\n\n'.codeUnits;
      
      // Cut
      bytes += [0x1D, 0x56, 0x00];
      
      await PrintBluetoothThermal.writeBytes(bytes);
      
    } catch (e) {
      debugPrint("Error printing receipt: $e");
    }
  }
}
