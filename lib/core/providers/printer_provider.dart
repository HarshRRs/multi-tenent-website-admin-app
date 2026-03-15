import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_bite/core/services/printer_service.dart';

final printerServiceProvider = ChangeNotifierProvider<PrinterService>((ref) {
  return PrinterService();
});
