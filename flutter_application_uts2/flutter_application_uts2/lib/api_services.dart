import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiService {
  // ganti sesuai alamat server Anda
  static const String baseUrl = "http://10.0.2.2/flutter_api/"; // emulator Android use 10.0.2.2

  static Future<List<dynamic>> fetchStudents({String q = ''}) async {
    final uri = Uri.parse(baseUrl + 'get.php${q.isNotEmpty ? '?q=${Uri.encodeComponent(q)}' : ''}');
    final resp = await http.get(uri);
    final json = jsonDecode(resp.body);
    if (json['success']) return json['data'];
    return [];
  }

  static Future<Map<String, dynamic>?> fetchStudent(int id) async {
    final uri = Uri.parse(baseUrl + 'get.php?id=$id');
    final resp = await http.get(uri);
    final json = jsonDecode(resp.body);
    if (json['success']) return json['data'];
    return null;
  }

  static Future<bool> insertStudent({
    required String name,
    required String email,
    required int age,
    required String gender,
    required String status,
    required String hobbies,
    File? photo,
    Uint8List? photoBytes, // for web
    String? filename,
  }) async {
    final uri = Uri.parse(baseUrl + 'insert.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['age'] = age.toString();
    request.fields['gender'] = gender;
    request.fields['status'] = status;
    request.fields['hobbies'] = hobbies;

    if (photo != null) {
      final mimeStr = lookupMimeType(photo.path) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path, contentType: MediaType.parse(mimeStr)));
    } else if (photoBytes != null && filename != null) {
      final mimeStr = lookupMimeType(filename) ?? 'image/jpeg';
      request.files.add(http.MultipartFile.fromBytes('photo', photoBytes, filename: filename, contentType: MediaType.parse(mimeStr)));
    }

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    final jsonResp = jsonDecode(resp.body);
    return jsonResp['success'] == true;
  }

  static Future<bool> updateStudent({
    required int id,
    required String name,
    required String email,
    required int age,
    required String gender,
    required String status,
    required String hobbies,
    File? photo,
    Uint8List? photoBytes,
    String? filename,
  }) async {
    final uri = Uri.parse(baseUrl + 'update.php');
    var request = http.MultipartRequest('POST', uri);
    request.fields['id'] = id.toString();
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['age'] = age.toString();
    request.fields['gender'] = gender;
    request.fields['status'] = status;
    request.fields['hobbies'] = hobbies;

    if (photo != null) {
      final mimeStr = lookupMimeType(photo.path) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path, contentType: MediaType.parse(mimeStr)));
    } else if (photoBytes != null && filename != null) {
      final mimeStr = lookupMimeType(filename) ?? 'image/jpeg';
      request.files.add(http.MultipartFile.fromBytes('photo', photoBytes, filename: filename, contentType: MediaType.parse(mimeStr)));
    }

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);
    final jsonResp = jsonDecode(resp.body);
    return jsonResp['success'] == true;
  }

  static Future<bool> deleteStudent(int id) async {
    final uri = Uri.parse(baseUrl + 'delete.php');
    final resp = await http.post(uri, body: {'id': id.toString()});
    final jsonResp = jsonDecode(resp.body);
    return jsonResp['success'] == true;
  }

  static Future getStudents({required String q}) async {}
}
