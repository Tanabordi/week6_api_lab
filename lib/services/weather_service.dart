import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const _apiKey = String.fromEnvironment('API_KEY', defaultValue: 'YOUR_API_KEY');

  Future<Weather> fetchWeather(String city) async {
    final uri = Uri.parse(
      '$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=th',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // ตัวอย่าง: กรณีสำเร็จ แปลงข้อมูลด้วย Weather.fromJson
        return Weather.fromJson(jsonDecode(response.body));
      }

      // กรณีไม่พบเมือง (statusCode 404)
      if (response.statusCode == 404) {
        throw Exception('ไม่พบข้อมูลเมืองที่คุณค้นหา');
      }

      // กรณี Error อื่นๆ จาก Server
      throw Exception(
        'เกิดข้อผิดพลาดในการโหลดข้อมูล (รหัส: ${response.statusCode})',
      );
    } on TimeoutException {
      // ตัวอย่าง: แปลง error ที่ได้จากระบบ เป็นข้อความภาษาไทยที่อ่านเข้าใจง่าย
      throw Exception('การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง');
    } on http.ClientException {
      // ตัวอย่าง: ดักจับกรณีเชื่อมต่อเซิร์ฟเวอร์ไม่ได้เลย (เช่น ไม่มีอินเทอร์เน็ต)
      throw Exception(
        'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อ',
      );
    } on FormatException {
      // ดักจับกรณี JSON ผิดรูปแบบ
      throw Exception('ข้อมูลสภาพอากาศจากเซิร์ฟเวอร์อยู่ในรูปแบบที่ไม่ถูกต้อง');
    } catch (e) {
      rethrow;
    }
  }
}
