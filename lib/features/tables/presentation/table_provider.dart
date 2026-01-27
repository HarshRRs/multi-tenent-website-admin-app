import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rockster/core/providers/providers.dart';
import 'package:rockster/features/tables/data/table_service.dart';
import 'package:rockster/features/tables/domain/table_models.dart';

enum TableDataStatus { initial, loading, loaded, error }

class TableState {
  final List<TableModel> tables;
  final TableDataStatus status;
  final String? errorMessage;

  TableState({
    this.tables = const [],
    this.status = TableDataStatus.initial,
    this.errorMessage,
  });

  TableState copyWith({
    List<TableModel>? tables,
    TableDataStatus? status,
    String? errorMessage,
  }) {
    return TableState(
      tables: tables ?? this.tables,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class TableNotifier extends StateNotifier<TableState> {
  final TableService _service;

  TableNotifier(this._service) : super(TableState()) {
    loadTables();
  }

  Future<void> loadTables() async {
    state = state.copyWith(status: TableDataStatus.loading);
    try {
      final tables = await _service.getTables();
      state = state.copyWith(tables: tables, status: TableDataStatus.loaded);
    } catch (e) {
      state = state.copyWith(status: TableDataStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> addTable(String name, int seats, double x, double y) async {
    try {
      final newTable = await _service.createTable({
        'name': name,
        'seats': seats,
        'x': x,
        'y': y,
        'status': 'available',
      });
      state = state.copyWith(tables: [...state.tables, newTable]);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateTable(TableModel table) async {
    try {
      final updated = await _service.updateTable(table.id, table.toJson());
      state = state.copyWith(
        tables: state.tables.map((t) => t.id == updated.id ? updated : t).toList(),
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteTable(String id) async {
    try {
      await _service.deleteTable(id);
      state = state.copyWith(
        tables: state.tables.where((t) => t.id != id).toList(),
      );
    } catch (e) {
      // Handle error
    }
  }

  void updateTablePosition(String id, double x, double y) {
    state = state.copyWith(
      tables: state.tables.map((t) {
        if (t.id == id) {
          return t.copyWith(x: x, y: y);
        }
        return t;
      }).toList(),
    );
  }

  Future<void> savePositions() async {
    // In a real app, you might want a bulk update endpoint
    // For now, we'll update each table that changed
    for (final table in state.tables) {
       await _service.updateTable(table.id, {'x': table.x, 'y': table.y});
    }
  }
}

final tableProvider = StateNotifierProvider<TableNotifier, TableState>((ref) {
  final service = ref.watch(tableServiceProvider);
  return TableNotifier(service);
});
