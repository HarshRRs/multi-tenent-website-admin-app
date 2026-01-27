import 'package:rockster/features/reservations/domain/reservation_models.dart';

class TableModel {
  final String id;
  final String name;
  final int seats;
  final double x;
  final double y;
  final TableStatus status;

  TableModel({
    required this.id,
    required this.name,
    required this.seats,
    required this.x,
    required this.y,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      seats: json['seats'] ?? 0,
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      status: _parseStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'seats': seats,
      'x': x,
      'y': y,
      'status': status.name,
    };
  }

  TableModel copyWith({
    String? id,
    String? name,
    int? seats,
    double? x,
    double? y,
    TableStatus? status,
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      seats: seats ?? this.seats,
      x: x ?? this.x,
      y: y ?? this.y,
      status: status ?? this.status,
    );
  }

  static TableStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'reserved':
        return TableStatus.reserved;
      case 'occupied':
        return TableStatus.occupied;
      default:
        return TableStatus.available;
    }
  }
}
