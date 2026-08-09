import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';

class ApiService {
  final http.Client _client;
  
  ApiService({http.Client? client}) : _client = client ?? http.Client();
  
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await _client
          .get(
            Uri.parse('${ApiConfig.baseUrl}$endpoint'),
            headers: headers,
          )
          .timeout(ApiConfig.timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body as Map<String, dynamic>;
    }
    
    throw ApiException(
      message: body['message'] ?? 'An error occurred',
      statusCode: response.statusCode,
      errors: body['errors'] as List<dynamic>?,
    );
  }
  
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    
    if (error is http.ClientException) {
      return NetworkException('Network error: ${error.message}');
    }
    
    return ServerException('Unexpected error: ${error.toString()}');
  }
  
  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final List<dynamic>? errors;
  
  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });
  
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  
  ServerException(this.message);
  
  @override
  String toString() => message;
}
