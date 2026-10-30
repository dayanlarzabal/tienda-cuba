import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Cambia esta URL por la de tu backend (o IP local para pruebas)
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator → localhost
  // static const String baseUrl = 'https://tu-dominio.com/api';

  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'accessToken', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'accessToken');
  }

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = false}) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return _handle(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = false}) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    final body = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    throw Exception(body?['message'] ?? 'Error ${res.statusCode}');
  }

  // Auth
  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post('/auth/login', {'email': email, 'password': password});
    if (data['accessToken'] != null) {
      await saveToken(data['accessToken']);
    }
    return data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> payload) async {
    final data = await post('/auth/register', payload);
    if (data['accessToken'] != null) {
      await saveToken(data['accessToken']);
    }
    return data;
  }

  // Products
  Future<List<dynamic>> getProducts({String? search, String? categoryId}) async {
    var path = '/products';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (categoryId != null) params.add('categoryId=$categoryId');
    if (params.isNotEmpty) path += '?${params.join('&')}';
    final data = await get(path);
    return data as List<dynamic>;
  }

  // Orders
  Future<Map<String, dynamic>> createOrder(List<Map<String, dynamic>> items, {Map? address}) async {
    return await post('/orders', {
      'items': items,
      if (address != null) 'shippingAddress': address,
    }, auth: true);
  }

  Future<List<dynamic>> myOrders() async {
    final data = await get('/orders/my', auth: true);
    return data as List<dynamic>;
  }
}
