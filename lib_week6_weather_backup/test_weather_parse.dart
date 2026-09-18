import 'dart:convert';
import 'models/weather.dart';

void main() {
  const rawJson = '''
{
    "coord": {
        "lon": 100.5167,
        "lat": 13.75
    },
    "weather": [
        {
            "id": 501,
            "main": "Rain",
            "description": "ฝนปานกลาง",
            "icon": "10d"
        }
    ],
    "base": "stations",
    "main": {
        "temp": 29.37,
        "feels_like": 36.37,
        "temp_min": 28.84,
        "temp_max": 31.08,
        "pressure": 1008,
        "humidity": 85,
        "sea_level": 1008,
        "grnd_level": 1007
    },
    "visibility": 10000,
    "wind": {
        "speed": 1.89,
        "deg": 227,
        "gust": 1.65
    },
    "rain": {
        "1h": 1.12
    },
    "clouds": {
        "all": 57
    },
    "dt": 1789710335,
    "sys": {
        "type": 2,
        "id": 2112373,
        "country": "TH",
        "sunrise": 1789686417,
        "sunset": 1789730264
    },
    "timezone": 25200,
    "id": 1609350,
    "name": "กรุงเทพมหานคร",
    "cod": 200
}
  ''';

  final json = jsonDecode(rawJson) as Map<String, dynamic>;
  final weather = Weather.fromJson(json);

  print('cityName: ${weather.cityName}');
  print('temperature: ${weather.temperature}');
  print('description: ${weather.description}');
  print('feelsLike: ${weather.feelsLike}');
}
