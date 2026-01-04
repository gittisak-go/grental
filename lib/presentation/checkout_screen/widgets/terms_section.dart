import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class TermsSection extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool?> onChanged;

  const TermsSection({
    super.key,
    required this.isAccepted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ข้อกำหนดและเงื่อนไข',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTermItem(
                      'ผู้เช่าต้องมีใบขับขี่ที่ถูกต้องและมีอายุ 21 ปีขึ้นไป'),
                  _buildTermItem(
                      'เงินมัดจำจะถูกคืนหลังส่งมอบรถในสภาพเรียบร้อย'),
                  _buildTermItem(
                      'การยกเลิกต้องแจ้งล่วงหน้าอย่างน้อย 24 ชั่วโมง'),
                  _buildTermItem(
                      'ค่าเช่าไม่รวมค่าน้ำมัน ผู้เช่าต้องเติมน้ำมันเต็มถังก่อนคืนรถ'),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            CheckboxListTile(
              value: isAccepted,
              onChanged: onChanged,
              title: Text('ฉันได้อ่านและยอมรับข้อกำหนดและเงื่อนไข',
                  style: TextStyle(fontSize: 12.sp)),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16.sp, color: Colors.green),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }
}
