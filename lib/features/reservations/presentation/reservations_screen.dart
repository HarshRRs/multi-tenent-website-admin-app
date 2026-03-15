import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_bite/core/theme/app_colors.dart';
import 'package:event_bite/core/theme/app_text_styles.dart';
import 'package:event_bite/features/reservations/domain/reservation_models.dart';
import 'package:event_bite/features/reservations/presentation/reservations_provider.dart';
import 'package:intl/intl.dart';

class ReservationsScreen extends ConsumerStatefulWidget {
  const ReservationsScreen({super.key});

  @override
  ConsumerState<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends ConsumerState<ReservationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationsProvider.notifier).refresh();
    });
  }

  Future<void> _showAddReservationDialog() async {
    final nameController = TextEditingController();
    final sizeController = TextEditingController();
    final phoneController = TextEditingController(); // Added controller
    final formKey = GlobalKey<FormState>(); // Added form key for validation
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New Reservation', style: AppTextStyles.headlineMedium),
        content: Form( // Wrapped in Form
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField( // Changed to TextFormField
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController, // Phone field
                decoration: InputDecoration(
                  labelText: 'Customer Contact Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
               TextFormField(
                controller: sizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Party Size',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ref.read(reservationsProvider.notifier).addReservation(
                    nameController.text,
                    phoneController.text.isNotEmpty ? phoneController.text : null,
                    int.parse(sizeController.text),
                  );
                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reservation added for \${nameController.text}'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
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
            icon: const Icon(Icons.add_circle),
            tooltip: 'Add Reservation',
            onPressed: _showAddReservationDialog,
          ),
        ],
      ),
      body: _buildBody(isLoading, reservations, tables),
    );
  }

  Widget _buildBody(bool isLoading, List<Reservation> reservations, List<RestaurantTable> tables) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Content
        Expanded(
          child: _buildReservationList(reservations, tables),
        ),
      ],
    );
  }

  Widget _buildReservationList(List<Reservation> reservations, List<RestaurantTable> tables) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('No reservations yet', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _showAddReservationDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Reservation'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        final tableName = tables.firstWhere(
          (t) => t.id == reservation.tableId,
          orElse: () => RestaurantTable(id: '', name: '?', seats: 0, x: 0, y: 0, status: TableStatus.available),
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
                    if (reservation.customerPhone != null && reservation.customerPhone!.isNotEmpty)
                      Text(reservation.customerPhone!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight, fontSize: 12)),
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
    );
  }



