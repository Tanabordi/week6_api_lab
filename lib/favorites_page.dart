import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/favorites_model.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // .watch เพราะหน้านี้ต้อง rebuild ทุกครั้งที่รายการโปรดเปลี่ยน (เช่น กดลบจากหน้านี้เอง)
    final favorites = context.watch<FavoritesModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการโปรดของฉัน'),
        actions: [
          // ซ่อนปุ่มถ้าไม่มีรายการโปรด
          if (favorites.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'ล้างรายการโปรดทั้งหมด',
              onPressed: () {
                // แสดง Dialog ยืนยัน
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('ยืนยันการล้างข้อมูล'),
                    content: const Text('คุณแน่ใจหรือไม่ว่าต้องการล้างรายการโปรดทั้งหมด?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // ปิด Dialog
                        child: const Text('ยกเลิก'),
                      ),
                      TextButton(
                        onPressed: () {
                          // .read เพื่อเรียกฟังก์ชัน clear() ครั้งเดียว
                          context.read<FavoritesModel>().clear();
                          Navigator.pop(context); // ปิด Dialog หลังจากเคลียร์
                        },
                        child: const Text('ยืนยัน'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: favorites.items.isEmpty
          ? const Center(child: Text('ยังไม่มีสินค้าที่บันทึกไว้'))
          : ListView.builder(
              itemCount: favorites.items.length,
              itemBuilder: (context, index) {
                final item = favorites.items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text('฿${item.price.toStringAsFixed(0)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    // .read เพราะเป็นการกดปุ่มครั้งเดียว ไม่ใช่การอ่านค่าต่อเนื่องแบบ .watch
                    onPressed: () => context.read<FavoritesModel>().remove(item),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Text('มูลค่ารวม: ฿${favorites.totalValue.toStringAsFixed(0)}'),
      ),
    );
  }
}
