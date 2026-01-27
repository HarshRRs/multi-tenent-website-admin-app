import 'package:dio/dio.dart';
import 'package:rockster/features/tables/domain/table_models.dart';

class TableService {
  final Dio _dio;

  TableService(this._dio);

  Future<List<TableModel>> getTables() async {
    final response = await _dio.get('/tables');
    final List data = response.data;
    return data.map((json) => TableModel.fromJson(json)).toList();
  }

  Future<TableModel> createTable(Map<String, dynamic> data) async {
    final response = await _dio.post('/tables', data: data);
    return TableModel.fromJson(response.data);
  }

  Future<TableModel> updateTable(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/tables/$id', data: data);
    return TableModel.fromJson(response.data);
  }

  Future<void> deleteTable(String id) async {
    await _dio.delete('/tables/$id');
  }
}
