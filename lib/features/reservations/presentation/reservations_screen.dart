import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/reservations/domain/reservation_models.dart';
import 'package:rockster/features/reservations/presentation/reservations_provider.dart';
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
      backgroundColor: AppColors.cloudDancer,
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(reservationsProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Reservation',
            onPressed: _showAddReservationDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Floral Background (Faded)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/flower_background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          _buildBody(isLoading, reservations, tables),
        ],
      ),
    );
  }

  Widget _buildBody(bool isLoading, List<Reservation> reservations, List<RestaurantTable> tables) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.burntTerracotta));
    }

    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No reservations yet', 
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.deepInk,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _showAddReservationDialog,
              style: FilledButton.styleFrom(backgroundColor: AppColors.burntTerracotta),
              icon: const Icon(Icons.add),
              label: const Text('Add Reservation'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        final tableName = tables.firstWhere(
          (t) => t.id == reservation.tableId,
          orElse: () => RestaurantTable(id: '', name: 'Pending', seats: 0, x: 0, y: 0, status: TableStatus.available),
        ).name;

        return ModernCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.burntTerracotta.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  DateFormat('HH:mm').format(reservation.time),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.burntTerracotta,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.customerName, 
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.deepInk,
                      ),
                    ),
                    if (reservation.customerPhone != null && reservation.customerPhone!.isNotEmpty)
                      Text(
                        reservation.customerPhone!, 
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondaryLight, 
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(
                          '${reservation.partySize} Guests',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                        ),
                        if (reservation.tableId.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(width: 3, height: 3, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(
                            'Table $tableName',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondaryLight),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Reservation'),
                        content: const Text('Are you sure you want to delete this reservation?'),
                        actions: [
                          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => context.pop(true), 
                            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref.read(reservationsProvider.notifier).deleteReservation(reservation.id);
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
