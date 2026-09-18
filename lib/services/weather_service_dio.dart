import 'package:dio/dio.dart';
import '../models/weather.dart';

Future<Weather> fetchWeatherWithDio(String city) async {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // ดึงค่า API_KEY จากการตั้งค่าสภาพแวดล้อม (environment variables) เพื่อความปลอดภัย ไม่ให้คีย์หลุดไปกับโค้ด
  const apiKey = String.fromEnvironment('API_KEY', defaultValue: 'YOUR_API_KEY');

  try {
    // dio แปลง JSON response.data ให้เป็น Map ให้อัตโนมัติ ไม่ต้องเรียก jsonDecode เอง
    final response = await dio.get(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {'q': city, 'appid': apiKey, 'units': 'metric'},
    );
    return Weather.fromJson(response.data as Map<String, dynamic>);
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง');
    } else if (e.type == DioExceptionType.badResponse) {
      // ตัวอย่าง: เซิร์ฟเวอร์ตอบกลับมาแล้วแต่ status code ผิดพลาด (เช่น 404, 500)
      throw Exception('เซิร์ฟเวอร์ตอบกลับผิดพลาด (${e.response?.statusCode})');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      throw Exception('ใช้เวลารอรับข้อมูลนานเกินไป กรุณาลองใหม่อีกครั้ง');
    } else if (e.type == DioExceptionType.connectionError) {
      throw Exception('ไม่สามารถเชื่อมต่อเครือข่ายได้ กรุณาตรวจสอบอินเทอร์เน็ตของคุณ');
    }
    throw Exception('เกิดข้อผิดพลาด: ${e.message}');
  }
}
