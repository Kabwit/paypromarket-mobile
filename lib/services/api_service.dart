import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String? _token;

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_data');
  }

  static String? get token => _token;
  static bool get isAuthenticated => _token != null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // GET
  static Future<Map<String, dynamic>> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'Pas de connexion internet'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // POST
  static Future<Map<String, dynamic>> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'Pas de connexion internet'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // PUT
  static Future<Map<String, dynamic>> put(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'Pas de connexion internet'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // DELETE
  static Future<Map<String, dynamic>> delete(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      );
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'Pas de connexion internet'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Multipart POST (pour upload de fichiers)
  static Future<Map<String, dynamic>> uploadFile(
    String url,
    String fieldName,
    File file, {
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      if (fields != null) {
        request.fields.addAll(fields);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'Pas de connexion internet'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Multipart POST avec plusieurs fichiers
  static Future<Map<String, dynamic>> uploadMultipleFiles(
    String url,
    String fieldName,
    List<File> files, {
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      for (var file in files) {
        request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'error': 'Pas de connexion internet'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        return {'success': true, ...body};
      }
      return {'success': true, 'data': body};
    } else {
      if (body is Map<String, dynamic>) {
        return {'success': false, ...body};
      }
      return {'success': false, 'error': 'Erreur serveur (${response.statusCode})'};
    }
  }
}
