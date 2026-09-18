import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../services/demo_post_service.dart';
import '../services/ai_product_service.dart';
import '../services/weather_service_dio.dart';

enum _ViewStatus { idle, loading, success, error }

class WeatherSearchPage extends StatefulWidget {
  const WeatherSearchPage({super.key});

  @override
  State<WeatherSearchPage> createState() => _WeatherSearchPageState();
}

class _WeatherSearchPageState extends State<WeatherSearchPage> {
  final _weatherService = WeatherService();
  final _cityController = TextEditingController();

  _ViewStatus _status = _ViewStatus.idle;
  Weather? _weather;
  String? _errorMessage;

  Future<void> _search() async {
    setState(() => _status = _ViewStatus.loading);

    try {
      // ตัวอย่าง: เรียก service แล้วจัดการกรณีสำเร็จ 
      final weather = await _weatherService.fetchWeather(_cityController.text);
      setState(() {
        _weather = weather;
        _status = _ViewStatus.success;
      });
    } catch (e) {
      // (จุดที่ 1): เพิ่ม setState จัดการกรณีเมื่อค้นหาแล้วเกิด error
      setState(() {
        _status = _ViewStatus.error;
        // จัดการลบคำว่า "Exception: " ออกจากข้อความ เพื่อให้ UI ดูสวยงามขึ้น
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ค้นหาสภาพอากาศ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'ชื่อเมือง'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _status == _ViewStatus.loading ? null : _search,
              child: const Text('ค้นหา'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => createDemoPost(),
              child: const Text('ทดลอง POST (ขั้นตอนที่ 3.1)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => updateDemoPost(),
              child: const Text('ทดลอง PUT (ขั้นตอนที่ 3.2)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                try {
                  print('กำลังดึงข้อมูลสินค้าทั้งหมดจาก Fake Store API...');
                  final products = await fetchAiProducts();
                  print('ดึงข้อมูลสำเร็จ จำนวน ${products.length} รายการ');
                  for (var i = 0; i < 3 && i < products.length; i++) {
                    print('สินค้าที่ ${i+1}: ${products[i].title} - \$${products[i].price}');
                  }
                } catch (e) {
                  print('พบข้อผิดพลาด: $e');
                }
              },
              child: const Text('ทดสอบ Fake Store API (ขั้นตอนที่ 4.3)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final city = _cityController.text.isEmpty ? 'Bangkok' : _cityController.text;
                try {
                  print('กำลังดึงข้อมูลสภาพอากาศของ $city ด้วย Dio...');
                  final weather = await fetchWeatherWithDio(city);
                  print('--- ผลลัพธ์จาก Dio ---');
                  print('1. ชื่อเมือง: ${weather.cityName}');
                  print('2. อุณหภูมิ: ${weather.temperature}°C');
                  print('3. รู้สึกเหมือน: ${weather.feelsLike}°C');
                  print('4. สภาพอากาศ: ${weather.description}');
                } catch (e) {
                  print('พบข้อผิดพลาด (Dio): $e');
                }
              },
              child: const Text('ทดสอบ Dio (ขั้นตอนที่ 5.3)'),
            ),
            const SizedBox(height: 16),
            // ตัวอย่าง: สถานะกำลังโหลด 
            if (_status == _ViewStatus.loading)
              const Center(child: CircularProgressIndicator()),
            // ตัวอย่าง: สถานะสำเร็จ แสดงครบทั้งชื่อเมือง อุณหภูมิ และคำอธิบาย 
            if (_status == _ViewStatus.success && _weather != null) ...[
              Text(
                '${_weather!.cityName}: ${_weather!.temperature}°C',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(_weather!.description),
            ],
            // (จุดที่ 2): UI สำหรับสถานะ error แสดงตัวหนังสือสีแดง
            if (_status == _ViewStatus.error && _errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
