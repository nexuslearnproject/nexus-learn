import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiService {
  // For Android emulator, use 10.0.2.2 instead of localhost
  // For iOS simulator, use localhost
  // For physical device, use your computer's IP address
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String baseUrl = 'http://localhost:8000'; // iOS simulator
  // static const String baseUrl = 'http://YOUR_IP:8000'; // Physical device

  Future<List<Item>> getItems() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/items/'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('results')) {
          // Handle paginated response
          final List<dynamic> itemsJson = data['results'];
          return itemsJson.map((json) => Item.fromJson(json)).toList();
        } else if (data is List) {
          // Handle list response
          return (data).map((json) => Item.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }

  Future<Item> createItem(String name, String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/items/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'description': description,
        }),
      );

      if (response.statusCode == 201) {
        return Item.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating item: $e');
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/items/$id/'),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete item: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting item: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health/'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

