import 'dart:convert';
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
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
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
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
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
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
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
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
    }
  }

  // Upload fichier(s) avec bytes (compatible web + mobile)
  static Future<Map<String, dynamic>> uploadFileBytes(
    String url,
    String fieldName,
    List<int> bytes,
    String filename, {
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
      ));
      if (fields != null) {
        request.fields.addAll(fields);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
    }
  }

  // Upload multiple fichiers avec bytes
  static Future<Map<String, dynamic>> uploadMultipleFileBytes(
    String url,
    String fieldName,
    List<Map<String, dynamic>> filesData, {
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      for (var fileData in filesData) {
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          fileData['bytes'] as List<int>,
          filename: fileData['filename'] as String,
        ));
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
    }
  }

  // Upload fichiers avec champs distincts (ex: document + selfie)
  static Future<Map<String, dynamic>> uploadNamedFiles(
    String url,
    Map<String, List<int>> fileBytes,
    Map<String, String> fileNames, {
    Map<String, String>? fields,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      for (var entry in fileBytes.entries) {
        request.files.add(http.MultipartFile.fromBytes(
          entry.key,
          entry.value,
          filename: fileNames[entry.key] ?? 'file',
        ));
      }
      if (fields != null) {
        request.fields.addAll(fields);
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      return {'success': false, 'error': _formatError(e)};
    }
  }

  static String _formatError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('socketexception') || msg.contains('failed host lookup') || msg.contains('connection refused') || msg.contains('xmlhttprequest')) {
      return 'Pas de connexion au serveur';
    }
    return e.toString();
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
