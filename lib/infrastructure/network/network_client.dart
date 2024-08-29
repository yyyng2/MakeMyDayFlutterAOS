import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkClient {
  final http.Client client;
  DateTime? _lastRequestTime;

  NetworkClient({required this.client});

  Future<T> getRequest<T>(Uri url, T Function(dynamic) fromJson) async {
    print(url); // For debugging purposes, printing the URL being requested

    // Rate limiting logic
    if (_lastRequestTime != null &&
        DateTime.now().difference(_lastRequestTime!) < const Duration(seconds: 1)) {
      await Future.delayed(const Duration(seconds: 1) - DateTime.now().difference(_lastRequestTime!));
    }

    try {
      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      _lastRequestTime = DateTime.now();

      if (response.statusCode == 200) {
        return fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<T> postRequest<T>(Uri url, dynamic jsonBody, T Function(dynamic) fromJson) async {
    print(url); // For debugging purposes, printing the URL being requested

    if (_lastRequestTime != null &&
        DateTime.now().difference(_lastRequestTime!) < const Duration(seconds: 1)) {
      await Future.delayed(const Duration(seconds: 1) - DateTime.now().difference(_lastRequestTime!));
    }

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonBody),
      );

      _lastRequestTime = DateTime.now();

      if (response.statusCode == 200) {
        return fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
