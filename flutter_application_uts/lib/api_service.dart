import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Ganti sesuai environment
  // Android emulator: 10.0.2.2
  // Real device: gunakan IP mesin host, mis. http://192.168.x.x/flutter_api/
  static const String baseUrl = "http://10.0.2.2/flutter_api/";

  // Insert user (multipart if ada image)
  static Future<bool> addUser(Map<String, String> fields, File? image) async {
    try {
      final uri = Uri.parse('${baseUrl}insert.php');
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll(fields);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', image.path));
      }
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        // expecting {"success": true} or similar
        if (j is Map && j['success'] == true) return true;
      }
      return false;
    } catch (e) {
      // print(e);
      return false;
    }
  }

  // Get all users
  static Future<List<dynamic>> getUsers() async {
    final uri = Uri.parse('${baseUrl}get_users.php');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      if (data is List) return data;
      return [];
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Delete user by id
  static Future<bool> deleteUser(String id) async {
    try {
      final uri = Uri.parse('${baseUrl}delete_user.php?id=$id');
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        if (j is Map && j['success'] == true) return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Update user (multipart optional image)
  static Future<bool> updateUser(Map<String, String> fields, File? image) async {
    try {
      final uri = Uri.parse('${baseUrl}update_user.php');
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll(fields);
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('foto', image.path));
      }
      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        if (j is Map && j['success'] == true) return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
