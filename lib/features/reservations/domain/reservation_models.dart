enum TableStatus {
  available,
  reserved,
  occupied,
}

class RestaurantTable {
  final String id;
  final String name;
  final int seats;
  final double x; // Relative position 0.0 to 1.0
  final double y; // Relative position 0.0 to 1.0
  final TableStatus status;

  RestaurantTable({
    required this.id,
    required this.name,
    required this.seats,
    required this.x,
    required this.y,
    required this.status,
  });
}

class Reservation {
  final String id;
  final String customerName;
  final int partySize;
  final DateTime time;
  final String tableId; // Optional, might not be assigned yet

  Reservation({
    required this.id,
    required this.customerName,
    required this.partySize,
    required this.time,
    this.tableId = '',
  });
}
