import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../blocs/cart/cart_state.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../services/firebase_messaging_helper.dart';
import '../constants/api_constants.dart'; // ✅ الاستيراد الجديد

final logger = Logger();

class ApiServiceDio {
  static const String baseUrl = apiBaseUrl;
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  static String normalizePhone(String phone) {
    phone = phone.trim();
    if (phone.startsWith('+964')) return phone;
    if (phone.startsWith('0')) return '+964${phone.substring(1)}';
    if (phone.startsWith('964')) return '+$phone';
    return '+964$phone';
  }

  // ---------- تحديث FCM Token في السيرفر ----------
  static Future<void> updateFcmToken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      await dio.post(
        '/users/update-fcm-token',
        data: {'fcmToken': fcmToken},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      logger.i('✅ تم إرسال FCM Token إلى السيرفر');
    } on DioException catch (e) {
      logger.e('فشل تحديث FCM Token: ${e.response?.data}');
    }
  }
  // -------------------------------------------------

  static Future<bool> checkPhoneExists(String phone) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post(
        '/users/check-phone',
        data: {'phone': phone},
      );
      return response.data['exists'] == true;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'فشل التحقق من وجود الحساب',
      );
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

      // إرسال FCM Token للسيرفر بعد تسجيل الدخول
      final fcmToken = await FirebaseMessagingHelper.getFcmToken();
      if (fcmToken != null) {
        await updateFcmToken(fcmToken);
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل في تسجيل الدخول');
    }
  }

  static Future<Map<String, dynamic>> registerUser(
    String name,
    String phone,
    String gender,
  ) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post(
        '/users/register',
        data: {'name': name, 'phone': phone, 'gender': gender},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل في إنشاء الحساب');
    }
  }

  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    phone = normalizePhone(phone);
    try {
      final response = await dio.post(
        '/users/send-otp',
        data: {'phone': phone},
      );
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
      final response = await dio.post(
        '/users/verify-otp',
        data: {'phone': phone, 'code': code},
      );
      final data = response.data;
      final token = data['token'];
      final user = data['user'];
      if (token == null || token is! String) {
        throw Exception('فشل في استلام التوكن من السيرفر');
      }
      if (user == null || user is! Map<String, dynamic>) {
        throw Exception(
          user is String ? user : 'الحساب غير موجود، يرجى التسجيل أولاً',
        );
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', user['_id']);
      await prefs.setString('userName', user['name']);
      await prefs.setString('userPhone', user['phone']);

      // إرسال FCM Token بعد تحقق OTP
      final fcmToken = await FirebaseMessagingHelper.getFcmToken();
      if (fcmToken != null) {
        await updateFcmToken(fcmToken);
      }

      return data;
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
      final response = await dio.post(
        '/users/verify-otp-register',
        data: {'phone': phone, 'code': code, 'name': name, 'gender': gender},
      );
      final prefs = await SharedPreferences.getInstance();
      final user = response.data['user'];
      if (user != null && user['_id'] != null) {
        await prefs.setString('userId', user['_id']);
        await prefs.setString('userName', user['name']);
        await prefs.setString('userPhone', user['phone']);
      }
      await prefs.setString('token', response.data['token']);

      // إرسال FCM Token بعد تحقق OTP للتسجيل
      final fcmToken = await FirebaseMessagingHelper.getFcmToken();
      if (fcmToken != null) {
        await updateFcmToken(fcmToken);
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل التحقق من الرمز');
    }
  }

  static Future<void> verifyOtpChangePhone({
    required String phone,
    required String code,
  }) async {
    phone = normalizePhone(phone);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final response = await dio.post(
        '/users/verify-otp-change-phone',
        data: {'phone': phone, 'code': code},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data is Map && response.data['phone'] != null) {
        await prefs.setString('userPhone', response.data['phone']);
        logger.i('📱 تم تأكيد وتحديث رقم الهاتف: ${response.data['phone']}');
      } else {
        await prefs.setString('userPhone', phone);
        logger.i('📱 تم تأكيد وتحديث رقم الهاتف (من المتغير): $phone');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'فشل في تأكيد وتغيير رقم الهاتف',
      );
    }
  }

  static Future<void> updatePhone(String newPhone) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final response = await dio.put(
        '/users/update-phone',
        data: {'newPhone': normalizePhone(newPhone)},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      await prefs.setString('userPhone', response.data['phone']);
      logger.i('📱 تم تحديث رقم الهاتف: ${response.data['phone']}');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل تحديث رقم الهاتف');
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
    final products = items
        .map(
          (item) => {
            'productId': item.product.id,
            'quantity': item.quantity,
            'size': item.selectedSize,
            'color': item.selectedColor,
          },
        )
        .toList();
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

  static Future<void> addAddress({
    required double lat,
    required double lng,
    required String label,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      await dio.post(
        '/addresses/add',
        data: {'latitude': lat, 'longitude': lng, 'label': label},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل حفظ العنوان');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchUserAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final response = await dio.get(
        '/addresses/my-addresses',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('فشل تحميل العناوين');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في تحميل العناوين');
    }
  }

  static Future<void> deleteAddress(String addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      await dio.delete(
        '/addresses/$addressId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل حذف العنوان');
    }
  }

  static Future<void> updateAddress({
    required String addressId,
    required String newLabel,
    required double lat,
    required double lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      await dio.put(
        '/addresses/$addressId',
        data: {'label': newLabel, 'latitude': lat, 'longitude': lng},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل تعديل العنوان');
    }
  }

  static Future<bool> sendFeedback({
    required String message,
    required String userId,
    required String phone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await dio.post(
        '/feedback',
        data: {'message': message, 'userId': userId, 'phone': phone},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 201;
    } catch (e) {
      logger.e('❌ إرسال الشكوى فشل: $e');
      return false;
    }
  }

  static Future<void> sendSurveys({
    required String userId,
    required String phone,
    required Map<int, String> answers,
    required String notes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final response = await dio.post(
        '/surveys/submit',
        data: {
          'q1': answers[0],
          'q2': answers[1],
          'q3': answers[2],
          'q4': answers[3],
          'notes': notes,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode != 201) {
        throw Exception('فشل إرسال الاستبيان');
      }
      logger.i('✅ تم إرسال الاستبيان بنجاح');
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'خطأ في إرسال الاستبيان');
    }
  }

  static Future<void> addToFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      await dio.post(
        '/favorites/add',
        data: {'productId': productId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      logger.i('💖 تم إضافة المنتج إلى المفضلة: $productId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'فشل في إضافة المنتج إلى المفضلة',
      );
    }
  }

  static Future<void> removeFromFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      await dio.delete(
        '/favorites/remove/$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      logger.i('❌ تم حذف المنتج من المفضلة: $productId');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'فشل في حذف المنتج من المفضلة',
      );
    }
  }

  static Future<List<ProductModel>> getFavoriteProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final response = await dio.get(
        '/favorites/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List data = response.data['favorites'];
      return data
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'خطأ في تحميل المفضلة');
    }
  }

  static Future<ProductModel> getProductById(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final response = await dio.get(
        '/products/$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'فشل في جلب تفاصيل المنتج',
      );
    }
  }

  /// جلب إعدادات الإشعارات من السيرفر
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      final response = await dio.get(
        '/users/notification-settings',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      // ممكن يكون undefined أول مرة – عالجها
      return response.data['notificationSettings'] ??
          {"orderStatus": true, "deals": true, "general": true};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'فشل تحميل إعدادات الإشعارات',
      );
    }
  }

  /// تحديث إعدادات الإشعارات في السيرفر
  static Future<void> updateNotificationSettings({
    required bool orderStatus,
    required bool deals,
    required bool general,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      await dio.put(
        '/users/notification-settings',
        data: {
          "notificationSettings": {
            "orderStatus": orderStatus,
            "deals": deals,
            "general": general,
          },
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'فشل تحديث إعدادات الإشعارات',
      );
    }
  }

  // جلب المنتجات مع فلاتر (gender/category)
  static Future<List<ProductModel>> fetchProducts({
    String? gender,
    String? type,
    String? categoryType,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (gender != null) queryParameters['gender'] = gender;
      if (type != null) queryParameters['type'] = type;
      if (categoryType != null) queryParameters['categoryType'] = categoryType;

      final response = await dio.get(
        '/products/',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final List data = response.data;
      return data
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل تحميل المنتجات');
    }
  }

  // البحث عن المنتجات (دعم categoryTypes)
  static Future<List<ProductModel>> searchProducts({
    String? query,
    List<String>? types,
    List<String>? genders,
    List<String>? sizes,
    List<String>? categoryTypes, // <-- أضف هنا
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final Map<String, dynamic> params = {};

      if (query != null && query.trim().isNotEmpty) {
        params['q'] = query.trim();
      }
      if (types != null && types.isNotEmpty) {
        params['types'] = types;
      }
      if (genders != null && genders.isNotEmpty) {
        params['genders'] = genders;
      }
      if (sizes != null && sizes.isNotEmpty) {
        params['sizes'] = sizes;
      }
      if (categoryTypes != null && categoryTypes.isNotEmpty) {
        params['categoryTypes'] = categoryTypes; // <-- دعم مناسبة اللبس
      }
      if (minPrice != null) {
        params['min'] = minPrice;
      }
      if (maxPrice != null) {
        params['max'] = maxPrice;
      }

      final response = await dio.get(
        '/products/search',
        queryParameters: params,
      );

      final data = response.data;
      if (data is! List) {
        throw Exception('الناتج من السيرفر غير متوقع');
      }

      return data
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل البحث عن المنتجات');
    }
  }

  static Future<List<OrderModel>> fetchUserOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getString('userId') ?? '';
    if (userId.isEmpty) throw Exception('لا يوجد مستخدم مسجل');
    try {
      final response = await dio.get(
        '/orders/user/$userId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List data = response.data['orders'];
      return data.map((json) => OrderModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'فشل تحميل الطلبات');
    }
  }
}
