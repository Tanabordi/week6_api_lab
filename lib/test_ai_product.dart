import 'services/ai_product_service.dart';

void main() async {
  try {
    print('กำลังดึงข้อมูลสินค้าทั้งหมดจาก Fake Store API...\n');
    final products = await fetchAiProducts();
    
    print('✅ ดึงข้อมูลสำเร็จ จำนวน ${products.length} รายการ\n');
    
    // พิมพ์ข้อมูลสินค้า 3 รายการแรกออกมาดูเป็นตัวอย่าง
    for (var i = 0; i < 3 && i < products.length; i++) {
      final p = products[i];
      print('สินค้าที่ ${i+1}: ${p.title}');
      print('ราคา: \$${p.price}');
      print('หมวดหมู่: ${p.category}');
      print('---');
    }
    
  } catch (e) {
    print('❌ พบข้อผิดพลาด: $e');
  }
}
