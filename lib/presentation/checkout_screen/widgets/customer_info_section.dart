import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class CustomerInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController idCardController;

  const CustomerInfoSection({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.idCardController,
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
            Text('ข้อมูลผู้เช่า',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 2.h),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อ-นามสกุล',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกชื่อ-นามสกุล';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'เบอร์โทรศัพท์',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกเบอร์โทรศัพท์';
                }
                if (value.length < 9) {
                  return 'เบอร์โทรศัพท์ไม่ถูกต้อง';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: idCardController,
              decoration: InputDecoration(
                labelText: 'เลขบัตรประชาชน',
                prefixIcon: const Icon(Icons.credit_card),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกเลขบัตรประชาชน';
                }
                if (value.length != 13) {
                  return 'เลขบัตรประชาชนต้องมี 13 หลัก';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
