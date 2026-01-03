import 'package:dio/dio.dart';
import 'package:rockster/features/reservations/data/reservation_dto.dart';
import 'package:rockster/features/reservations/domain/reservation_models.dart';

class ReservationService {
  final Dio _dio;

  ReservationService(this._dio);

  // Tables
  Future<List<RestaurantTable>> getTables() async {
    final response = await _dio.get('/reservations/tables');
    return tablesFromJson(response.data);
  }

  Future<RestaurantTable> updateTableStatus(String id, TableStatus status) async {
    final response = await _dio.patch(
      '/reservations/tables/$id/status',
      data: {'status': status.name},
    );
    return tableFromJson(response.data);
  }

  // Reservations
  Future<List<Reservation>> getReservations() async {
    final response = await _dio.get('/reservations');
    return reservationsFromJson(response.data);
  }

  Future<Reservation> createReservation(Reservation reservation) async {
    final response = await _dio.post(
      '/reservations',
      data: reservationToJson(reservation),
    );
    return reservationFromJson(response.data);
  }
}
