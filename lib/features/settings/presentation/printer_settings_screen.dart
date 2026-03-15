import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockster/core/providers/printer_provider.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(printerServiceProvider).getBondedDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final printerService = ref.watch(printerServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      appBar: AppBar(
        title: Text(l10n.settingsPrinter, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.printConnect,
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                if (printerService.isScanning)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => printerService.getBondedDevices(),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: printerService.devices.isEmpty
                  ? Center(child: Text(l10n.printNoDevice))
                  : ListView.builder(
                      itemCount: printerService.devices.length,
                      itemBuilder: (context, index) {
                        final device = printerService.devices[index];
                        final isConnected = printerService.selectedDevice?.address == device.address && printerService.isConnected;

                        return Card(
                          elevation: 0,
                          color: isConnected ? AppColors.burntTerracotta.withValues(alpha: 0.1) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: isConnected ? AppColors.burntTerracotta : Colors.transparent),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.print,
                              color: isConnected ? AppColors.burntTerracotta : Colors.grey,
                            ),
                            title: Text(device.name ?? 'Unknown Device'),
                            subtitle: Text(device.address ?? ''),
                            trailing: isConnected
                                ? Text(l10n.printConnected,
                                    style: const TextStyle(color: AppColors.burntTerracotta, fontWeight: FontWeight.bold))
                                : ElevatedButton(
                                    onPressed: () => printerService.connect(device),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.deepInk,
                                        foregroundColor: Colors.white),
                                    child: Text('Connect'),
                                  ),
                            onTap: () => printerService.connect(device),
                          ),
                        );
                      },
                    ),
            ),
            if (printerService.isConnected) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => printerService.printTestTicket(),
                  icon: const Icon(Icons.print_outlined),
                  label: Text(l10n.printTest),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.burntTerracotta,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => printerService.disconnect(),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.error),
                      foregroundColor: AppColors.error),
                  child: Text(l10n.printDisconnect),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
