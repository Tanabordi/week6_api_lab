import 'services/weather_service.dart';

void main() async {
  final service = WeatherService();

  print('--- กรณีที่ 1: ทดสอบดึงข้อมูลสำเร็จ (Status 200) ---');
  try {
    // ค้นหาเมืองที่มีอยู่จริง
    final weather = await service.fetchWeather('Bangkok');
    print('✅ สำเร็จ! พบข้อมูลเมือง: ${weather.cityName}');
    print('อุณหภูมิ: ${weather.temperature}');
    print('สภาพอากาศ: ${weather.description}');
  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n--- กรณีที่ 2: ทดสอบไม่พบเมือง (Status 404) ---');
  try {
    // ค้นหาเมืองที่ไม่มีในโลกแน่ๆ
    final weather = await service.fetchWeather('เมืองที่ไม่มีอยู่จริงบนโลก12345');
    print('✅ สำเร็จ! พบข้อมูลเมือง: ${weather.cityName}');
  } catch (e) {
    print('✅ ดักจับ Error ได้สำเร็จ: $e');
  }
}
