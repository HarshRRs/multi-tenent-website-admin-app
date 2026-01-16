import 'package:rockster/features/reservations/domain/reservation_models.dart';

// Tables
List<RestaurantTable> tablesFromJson(List<dynamic> json) {
  return json.map((e) => tableFromJson(e)).toList();
}

RestaurantTable tableFromJson(Map<String, dynamic> json) {
  return RestaurantTable(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    seats: json['seats'] ?? 2,
    x: (json['x'] as num?)?.toDouble() ?? 0.0,
    y: (json['y'] as num?)?.toDouble() ?? 0.0,
    status: _parseTableStatus(json['status']),
  );
}

TableStatus _parseTableStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'reserved':
      return TableStatus.reserved;
    case 'occupied':
      return TableStatus.occupied;
    case 'available':
    default:
      return TableStatus.available;
  }
}

Map<String, dynamic> tableToJson(RestaurantTable table) {
  return {
    'id': table.id,
    'name': table.name,
    'seats': table.seats,
    'x': table.x,
    'y': table.y,
    'status': table.status.name,
  };
}

// Reservations
List<Reservation> reservationsFromJson(List<dynamic> json) {
  return json.map((e) => reservationFromJson(e)).toList();
}

Reservation reservationFromJson(Map<String, dynamic> json) {
  return Reservation(
    id: json['id'] ?? '',
    customerName: json['customerName'] ?? '',
    customerPhone: json['customerPhone'],
    partySize: json['partySize'] ?? 2,
    time: json['time'] != null ? DateTime.parse(json['time']) : DateTime.now(),
    tableId: json['tableId'] ?? '',
  );
}

Map<String, dynamic> reservationToJson(Reservation reservation) {
  return {
    'id': reservation.id,
    'customerName': reservation.customerName,
    'customerPhone': reservation.customerPhone,
    'partySize': reservation.partySize,
    'time': reservation.time.toIso8601String(),
    'tableId': reservation.tableId,
  };
}
