import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

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
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      bytes += generator.reset();
      bytes += generator.text('ROCKSTER TEST',
          styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
      bytes += generator.feed(1);
      bytes += generator.text('Printer Connected!', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Ready to print orders.', styles: const PosStyles(align: PosAlign.center));
      bytes += generator.feed(2);
      bytes += generator.cut();

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
    String? table,
    String? notes,
  }) async {
    if (!_isConnected) return;

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];

      // Header
      bytes += generator.reset();
      bytes += generator.text('KITCHEN TICKET', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text('Order #$orderNumber', styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2, width: PosTextSize.size2, bold: true));
      bytes += generator.feed(1);
      
      // Info
      bytes += generator.text('Date: ${DateTime.now().toString().substring(0, 16)}');
      bytes += generator.text('Customer: $customerName');
      if (table != null) bytes += generator.text('Table: $table', styles: const PosStyles(bold: true));
      bytes += generator.hr();

      // Items
      bytes += generator.text('ITEMS', styles: const PosStyles(bold: true));
      for (var item in items) {
        final name = item['name'] ?? 'Item';
        final qty = item['quantity'] ?? 1;
        final price = item['price'] ?? 0.0;
        
        bytes += generator.row([
          PosColumn(text: '${qty}x', width: 2, styles: const PosStyles(bold: true)),
          PosColumn(text: name, width: 7),
          PosColumn(text: price.toStringAsFixed(2), width: 3, styles: const PosStyles(align: PosAlign.right)),
        ]);
        
        // Modifiers (if any)
        if (item['modifiers'] != null) {
          final modifiers = item['modifiers'] as List;
          for (var mod in modifiers) {
             bytes += generator.text('  + $mod', styles: const PosStyles(fontType: PosFontType.fontB));
          }
        }
      }
      bytes += generator.hr();

      // Totals
      bytes += generator.row([
        PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
        PosColumn(text: total.toStringAsFixed(2), width: 6, styles: const PosStyles(align: PosAlign.right, bold: true, height: PosTextSize.size2)),
      ]);

      // Notes
      if (notes != null && notes.isNotEmpty) {
        bytes += generator.feed(1);
        bytes += generator.text('NOTES:', styles: const PosStyles(bold: true));
        bytes += generator.text(notes, styles: const PosStyles(reverse: true));
      }

      bytes += generator.feed(2);
      bytes += generator.cut();

      await PrintBluetoothThermal.writeBytes(bytes);
    } catch (e) {
      debugPrint("Error printing receipt: $e");
    }
  }
}
