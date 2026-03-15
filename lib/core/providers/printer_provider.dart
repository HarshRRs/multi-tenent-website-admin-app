import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/services/printer_service.dart';

final printerServiceProvider = ChangeNotifierProvider<PrinterService>((ref) {
  return PrinterService();
});
