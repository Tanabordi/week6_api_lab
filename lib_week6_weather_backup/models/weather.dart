class Weather {
  final String cityName;
  final double temperature;
  final String description;
  final double feelsLike;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.feelsLike,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    // ตัวอย่าง: ดึงค่าจาก object ย่อย 'main' ออกมาก่อน (ต้อง cast เป็น Map<String, dynamic>)
    // และ cast ตัวเลขผ่าน num ก่อนเรียก .toDouble() เสมอ
    final main = json['main'] as Map<String, dynamic>;
    final temperature = (main['temp'] as num).toDouble();

    // ดึง feels_like จาก main ด้วยวิธีเดียวกับ temperature ด้านบน
    final feelsLike = (main['feels_like'] as num).toDouble();

    // cast json['weather'] เป็น List<dynamic> แล้วดึงสมาชิกตัวแรกออกมาเป็น
    // Map<String, dynamic> เพื่อดึงค่า description
    final weatherList = json['weather'] as List<dynamic>;
    final weatherItem = weatherList[0] as Map<String, dynamic>;
    final description = weatherItem['description'] as String;

    // ดึง cityName จาก key 'name' ที่ระดับบนสุดของ json
    final cityName = json['name'] as String;

    // return Weather(...) โดยใส่ค่าทั้ง 4 ฟิลด์ที่ดึงมาได้ให้ครบ
    return Weather(
      cityName: cityName,
      temperature: temperature,
      description: description,
      feelsLike: feelsLike,
    );
  }
}
