import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// --- ส่วนที่ 1: Model class ---
class AiProduct {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  AiProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory AiProduct.fromJson(Map<String, dynamic> json) {
    return AiProduct(
      id: json['id'] as int,
      title: json['title'] as String,
      // ใช้ num เพื่อรับได้ทั้ง int/double แล้วแปลงเป็น double ป้องกันการ crash
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
    );
  }
}

// --- ส่วนที่ 2 & 3: ฟังก์ชันการดึงข้อมูลและการจัดการ Error ---

/// ฟังก์ชันสำหรับดึงรายการสินค้าทั้งหมด
Future<List<AiProduct>> fetchAiProducts() async {
  final url = Uri.parse('https://fakestoreapi.com/products');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => AiProduct.fromJson(item)).toList();
    } else {
      throw Exception('ไม่สามารถโหลดข้อมูลได้ (${response.statusCode})');
    }
  } on TimeoutException {
    // [เหตุผล] ดักจับเมื่อเซิร์ฟเวอร์ตอบสนองช้ากว่า 10 วินาที เพื่อไม่ให้แอปค้างรอนานเกินไป
    throw 'การเชื่อมต่อใช้เวลานานเกินไป กรุณาตรวจสอบอินเทอร์เน็ตของคุณ';
  } on SocketException {
    // [เหตุผล] ดักจับในระดับ OS เมื่อไม่มีการเชื่อมต่อโครงข่าย (เช่น ปิด Wifi/Cellular หรืออยู่ในโหมดเครื่องบิน)
    throw 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อของคุณ';
  } on http.ClientException {
    // [เหตุผล] ดักจับความผิดพลาดจากฝั่ง Client เช่น การสื่อสารผ่านโปรโตคอล HTTP ผิดพลาด หรือปิดการเชื่อมต่อกลางคัน
    throw 'เกิดปัญหาในการเชื่อมต่อกับเซิร์ฟเวอร์';
  } on FormatException {
    // [เหตุผล] ดักจับเมื่อ jsonDecode ทำงานไม่ได้ เช่น เซิร์ฟเวอร์ส่งหน้า HTML Error มาแทนที่จะเป็น JSON
    throw 'รูปแบบข้อมูลที่ได้รับไม่ถูกต้อง';
  } catch (e) {
    // [เหตุผล] ดักจับ Error อื่นๆ ที่อาจเกิดขึ้นได้ (Generic Error)
    throw 'เกิดข้อผิดพลาดที่ไม่คาดคิด: $e';
  }
}

/// ฟังก์ชันสำหรับดึงสินค้าเดี่ยวๆ ตาม ID
Future<AiProduct> fetchAiProductById(int id) async {
  final url = Uri.parse('https://fakestoreapi.com/products/$id');
  try {
    // ตั้งค่า timeout 10 วินาทีตามข้อกำหนด
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      // ตรวจสอบก่อนว่า body ไม่ว่างเปล่า (กรณี ID ไม่มีในระบบ API อาจส่งค่าว่างมา)
      if (response.body == 'null' || response.body.isEmpty) {
        throw Exception('ไม่พบข้อมูลสินค้านี้');
      }
      return AiProduct.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('ไม่สามารถโหลดข้อมูลสินค้าได้ (Error: ${response.statusCode})');
    }
  } on TimeoutException {
    // [เหตุผล] เพื่อป้องกัน User Experience ที่ไม่ดีจากการที่แอปหมุนค้างไว้นานเกินไปในที่ที่สัญญาณต่ำ
    throw 'การเชื่อมต่อใช้เวลานานเกินไป';
  } on SocketException {
    // [เหตุผล] เป็น Exception หลักที่ใช้เช็กว่าอุปกรณ์ "ไม่ได้เชื่อมต่อเน็ต" หรือ DNS ทำงานไม่ได้
    throw 'ไม่สามารถเข้าถึงอินเทอร์เน็ตได้';
  } on http.ClientException {
    // [เหตุผล] ดักจับกรณีมีการขัดข้องระหว่างรับส่งข้อมูล หรือโครงสร้าง request/response ผิดพลาดในระดับ HTTP
    throw 'การเชื่อมต่อถูกขัดข้อง กรุณาลองใหม่อีกครั้ง';
  } on FormatException {
    // [เหตุผล] ดักจับกรณี API มีปัญหาแล้วส่งค่ากลับมาไม่ใช่ JSON (เช่น ส่ง Error 500 เป็นหน้าเว็บเปล่าๆ)
    throw 'ข้อมูลที่ได้รับจากเซิร์ฟเวอร์ผิดพลาด';
  } catch (e) {
    // [เหตุผล] ดักจับ Error ที่หลุดรอดจากเงื่อนไขข้างต้น
    throw 'เกิดข้อผิดพลาด: $e';
  }
}

// --- ตัวอย่างการเรียกใช้งาน ---
void exampleUsage() async {
  try {
    print('กำลังโหลดสินค้า ID: 1...');
    AiProduct product = await fetchAiProductById(1);
    print('ชื่อสินค้า: ${product.title}');
    print('ราคา: ${product.price}');
  } catch (e) {
    // ข้อความภาษาไทยที่ถูก throw ออกมาจะมาแสดงผลตรงนี้
    print('พบข้อผิดพลาด: $e');
  }
}
