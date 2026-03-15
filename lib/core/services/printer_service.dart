import 'dart:typed_data';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterService extends ChangeNotifier {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isScanning = false;

  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get selectedDevice => _selectedDevice;
  bool get isConnected => _isConnected;
  bool get isScanning => _isScanning;

  PrinterService() {
    _init();
  }

  void _init() {
    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          _isConnected = true;
          break;
        case BlueThermalPrinter.DISCONNECTED:
          _isConnected = false;
          break;
        default:
          break;
      }
      notifyListeners();
    });
  }

  Future<void> getBondedDevices() async {
    _isScanning = true;
    notifyListeners();

    try {
      if (await Permission.bluetoothScan.request().isGranted || 
          await Permission.bluetoothConnect.request().isGranted ||
          await Permission.location.request().isGranted) {
          
        _devices = await bluetooth.getBondedDevices();
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
      await bluetooth.connect(device);
      _selectedDevice = device;
      // Connection state listener will handle isConnected update
    } catch (e) {
      debugPrint("Error connecting to printer: $e");
    }
  }

  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
      _selectedDevice = null;
    } catch (e) {
      debugPrint("Error disconnecting: $e");
    }
  }

  Future<void> printTestTicket() async {
    if (!_isConnected) return;

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.text(
        'COSMOS TEST PRINT',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
            bold: true),
      );
      bytes += generator.feed(1);
      bytes += generator.text('If you can read this,',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('your printer is working!',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(2);
      bytes += generator.cut();

      await bluetooth.writeBytes(Uint8List.fromList(bytes));
    } catch (e) {
      debugPrint("Error printing test ticket: $e");
    }
  }
}
