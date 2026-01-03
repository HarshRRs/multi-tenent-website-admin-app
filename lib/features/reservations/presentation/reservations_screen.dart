import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/reservations/domain/reservation_models.dart';
import 'package:rockster/features/reservations/presentation/reservations_provider.dart';
import 'package:rockster/features/reservations/presentation/widgets/floor_map_widget.dart';
import 'package:intl/intl.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationsProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reservationsProvider);
    final tables = state.tables;
    final reservations = state.reservations;
    final isLoading = state.status == DataStatus.loading && tables.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reservationsProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // View Toggle
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  _buildToggleOption('List View', Icons.list, !_showMap),
                  _buildToggleOption('Floor Map', Icons.map, _showMap),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _showMap
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloorMapWidget(
                      tables: tables,
                      onTableTap: (table) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Table \${table.name}: \${table.status.name}')),
                        );
                      },
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: reservations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reservation = reservations[index];
                      // Find assigned table name if any
                      final tableName = tables.firstWhere(
                        (t) => t.id == reservation.tableId, 
                        orElse: () => RestaurantTable(id: '', name: '?', seats: 0, x: 0, y: 0, status: TableStatus.available)
                      ).name;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                DateFormat('HH:mm').format(reservation.time),
                                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryLight),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(reservation.customerName, style: AppTextStyles.labelLarge),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.people, size: 14, color: AppColors.textSecondaryLight),
                                      const SizedBox(width: 4),
                                      Text(
                                        '\${reservation.partySize} Guests',
                                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                                      ),
                                      if (reservation.tableId.isNotEmpty) ...[
                                        const SizedBox(width: 8),
                                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Table \$tableName',
                                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showMap = label == 'Floor Map'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? AppColors.primaryLight : AppColors.textSecondaryLight),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.textDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

