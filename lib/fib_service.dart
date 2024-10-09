import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class FIBService {
  final Dio _dio = Dio();
  String clientId = '';
  String clientSecret = '';
  final String _authUrl =
      'https://fib.dev.fib.iq/auth/realms/fib-online-shop/protocol/openid-connect/token';
  final String _paymentUrl = 'https://fib.dev.fib.iq/protected/v1/payments';

  Future<String> _getAccessToken() async {
    final response = await _dio.post(
      _authUrl,
      data: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return response.data['access_token'];
  }

  Future<Map<String, dynamic>> createPayment(
      int amount, String description, String statusCallbackUrl) async {
    final token = await _getAccessToken();
    final response = await _dio.post(
      _paymentUrl,
      data: {
        'monetaryValue': {
          'amount': amount.toString(),
          'currency': 'IQD',
        },
        'statusCallbackUrl': statusCallbackUrl,
        'description': description,
        'expiresIn': 'PT12H',
        'refundableFor': '',
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    final token = await _getAccessToken();
    final url = '$_paymentUrl/$paymentId/status';

    final response = await _dio.get(
      url,
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return response.data;
  }

  Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  Future<Map<String, dynamic>> refundPayment(String paymentId) async {
    final token = await _getAccessToken();
    final url = '$_paymentUrl/$paymentId/refund';

    final response = await _dio.post(
      url,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    return response.data;
  }
}
