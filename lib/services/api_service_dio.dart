import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../blocs/cart/cart_state.dart';

final logger = Logger();

class ApiServiceDio {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static String normalizePhone(String phone) {
    phone = phone.trim();
    if (phone.startsWith('+964')) return phone;
    if (phone.startsWith('0')) return '+964${phone.substring(1)}';
    if (phone.startsWith('964')) return '+$phone';
    return '+964$phone';
  }

  static Future<bool> checkPhoneExists(String phone) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post('/users/check-phone', data: {'phone': phone});
      return response.data['exists'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل التحقق من وجود الحساب');
    }
  }

  static Future<Map<String, dynamic>> login(String phone) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post('/users/login', data: {'phone': phone});
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('token', response.data['token']);
      await prefs.setString('userId', response.data['user']['_id']);
      await prefs.setString('userName', response.data['user']['name']);
      await prefs.setString('userPhone', response.data['user']['phone']);

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل في تسجيل الدخول');
    }
  }

  static Future<Map<String, dynamic>> registerUser(String name, String phone, String gender) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post('/users/register', data: {
        'name': name,
        'phone': phone,
        'gender': gender,
      });
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل في إنشاء الحساب');
    }
  }

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post('/users/send-otp', data: {'phone': phone});
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل إرسال رمز التحقق');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post('/users/verify-otp', data: {'phone': phone, 'code': code});
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['token']);
      await prefs.setString('userId', response.data['user']['_id']);
      await prefs.setString('userName', response.data['user']['name']);
      await prefs.setString('userPhone', response.data['user']['phone']);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل التحقق من الرمز');
    }
  }

  static Future<Map<String, dynamic>> verifyOtpForRegister({
    required String phone,
    required String code,
    required String name,
    required String gender,
  }) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post('/users/verify-otp-register', data: {
        'phone': phone,
        'code': code,
        'name': name,
        'gender': gender,
      });

      final prefs = await SharedPreferences.getInstance();
      final user = response.data['user'];
      if (user != null && user['_id'] != null) {
        await prefs.setString('userId', user['_id']);
        await prefs.setString('userName', user['name']);
        await prefs.setString('userPhone', user['phone']);
      }

      await prefs.setString('token', response.data['token']);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل التحقق من الرمز');
    }
  }

  static Future<void> sendOrder({
    required List<CartItem> items,
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      throw Exception('لم يتم العثور على userId في التخزين المحلي');
    }

    final products = items.map((item) => {
      'productId': item.product.id,
      'quantity': item.quantity,
      'size': item.selectedSize,
      'color': item.selectedColor,
    }).toList();

    final data = {'userId': userId, 'products': products, 'address': address};

    try {
      final response = await dio.post(
        '/orders/create',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      logger.i('✅ Order Sent: ${response.data}');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل إرسال الطلب');
    }
  }

  static Future<String?> getUserIdFromToken(String token) async {
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded['userId'];
    } catch (e) {
      logger.e('JWT Decode Error: $e');
      return null;
    }
  }

  static Future<bool> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      final response = await dio.delete(
        '/users/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      logger.e('Delete User Error: ${e.response?.data}');
      return false;
    }
  }
}
