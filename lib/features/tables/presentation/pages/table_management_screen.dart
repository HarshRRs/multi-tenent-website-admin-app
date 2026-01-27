import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/theme/app_colors.dart';
import 'package:rockster/core/theme/app_text_styles.dart';
import 'package:rockster/features/tables/presentation/table_provider.dart';
import 'package:rockster/features/tables/domain/table_models.dart';
import 'package:rockster/features/reservations/domain/reservation_models.dart';
import 'package:google_fonts/google_fonts.dart';

class TableManagementScreen extends ConsumerStatefulWidget {
  const TableManagementScreen({super.key});

  @override
  ConsumerState<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends ConsumerState<TableManagementScreen> {
  bool _isEditing = false;
  TableModel? _selectedTable;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tableProvider);

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      appBar: AppBar(
        title: Text('Floor Plan Designer', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.success),
              onPressed: () {
                ref.read(tableProvider.notifier).savePositions();
                setState(() => _isEditing = false);
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_location_alt_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showAddTableDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Grid Background
          Positioned.fill(
            child: CustomPaint(
              painter: GridPainter(),
            ),
          ),
          
          // Tables Layer
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: state.tables.map((table) {
                  return _buildDraggableTable(table, constraints);
                }).toList(),
              );
            },
          ),

          // Side Info Panel (If a table is selected)
          if (_selectedTable != null)
             _buildSelectionOverlay(),
        ],
      ),
    );
  }

  Widget _buildDraggableTable(TableModel table, BoxConstraints constraints) {
    final size = 100.0;
    final left = table.x * (constraints.maxWidth - size);
    final top = table.y * (constraints.maxHeight - size);

    return AnimatedPositioned(
      duration: _isEditing ? Duration.zero : const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => setState(() => _selectedTable = table),
        onPanUpdate: _isEditing ? (details) {
           final newX = (left + details.delta.dx) / (constraints.maxWidth - size);
           final newY = (top + details.delta.dy) / (constraints.maxHeight - size);
           ref.read(tableProvider.notifier).updateTablePosition(
             table.id, 
             newX.clamp(0.0, 1.0), 
             newY.clamp(0.0, 1.0)
           );
        } : null,
        child: _TableWidget(
          table: table, 
          isSelected: _selectedTable?.id == table.id,
          isMoving: _isEditing,
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay() {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedTable!.name, style: AppTextStyles.headlineMedium),
                Text('${_selectedTable!.seats} Seats • ${_selectedTable!.status.name}', 
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondaryLight)),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.burntTerracotta),
              onPressed: () => _showEditTableDialog(_selectedTable!),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () {
                ref.read(tableProvider.notifier).deleteTable(_selectedTable!.id);
                setState(() => _selectedTable = null);
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selectedTable = null),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTableDialog() {
    final nameController = TextEditingController();
    final seatsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Table Name (e.g. T-1)')),
            TextField(controller: seatsController, decoration: const InputDecoration(labelText: 'Seats'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(tableProvider.notifier).addTable(
                nameController.text, 
                int.parse(seatsController.text), 
                0.5, 0.5
              );
              Navigator.pop(context);
            }, 
            child: const Text('Add')
          ),
        ],
      ),
    );
  }

  void _showEditTableDialog(TableModel table) {
    final nameController = TextEditingController(text: table.name);
    final seatsController = TextEditingController(text: table.seats.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Table'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Table Name')),
            TextField(controller: seatsController, decoration: const InputDecoration(labelText: 'Seats'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              ref.read(tableProvider.notifier).updateTable(
                table.copyWith(
                  name: nameController.text,
                  seats: int.parse(seatsController.text),
                )
              );
              Navigator.pop(context);
              setState(() => _selectedTable = null);
            }, 
            child: const Text('Save')
          ),
        ],
      ),
    );
  }
}

class _TableWidget extends StatelessWidget {
  final TableModel table;
  final bool isSelected;
  final bool isMoving;

  const _TableWidget({
    required this.table, 
    this.isSelected = false,
    this.isMoving = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isMoving ? 110 : 90,
      height: isMoving ? 110 : 90,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
          width: isSelected ? 4 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.4),
            blurRadius: isMoving ? 25 : 10,
            spreadRadius: isMoving ? 5 : 0,
            offset: Offset(0, isMoving ? 12 : 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isMoving)
            _RippleEffect(color: statusColor),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                table.name, 
                style: GoogleFonts.lexend(
                  color: Colors.white, 
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                )
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 10, color: Colors.white),
                    const SizedBox(width: 2),
                    Text(
                      '${table.seats}', 
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.available: return AppColors.success;
      case TableStatus.reserved: return AppColors.liquidAmber;
      case TableStatus.occupied: return AppColors.error;
    }
  }
}

class _RippleEffect extends StatefulWidget {
  final Color color;
  const _RippleEffect({required this.color});

  @override
  State<_RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<_RippleEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 120 * _controller.value,
          height: 120 * _controller.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withOpacity(1.0 - _controller.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
