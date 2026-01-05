import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentSlipInstructionsWidget extends StatelessWidget {
  final String messengerUrl;
  final String transactionId;
  final double amount;

  const PaymentSlipInstructionsWidget({
    super.key,
    required this.messengerUrl,
    required this.transactionId,
    required this.amount,
  });

  Future<void> _launchMessenger() async {
    final uri = Uri.parse(messengerUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue, size: 24.0),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'ส่งสลิปการโอนเงิน',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                      'จำนวนเงิน', '฿${amount.toStringAsFixed(2)}', true),
                  SizedBox(height: 1.h),
                  _buildInfoRow('รหัสอ้างอิง',
                      transactionId.substring(0, 8).toUpperCase(), false),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'วิธีการส่งสลิป:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            _buildStep('1', 'โอนเงินตามจำนวนที่ระบุข้างต้น'),
            SizedBox(height: 1.h),
            _buildStep('2', 'ถ่ายภาพหน้าจอสลิปการโอนเงิน'),
            SizedBox(height: 1.h),
            _buildStep(
                '3', 'กดปุ่มด้านล่างเพื่อส่งสลิปผ่าน Facebook Messenger'),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchMessenger,
                icon: const Icon(Icons.chat, color: Colors.white),
                label: Text(
                  'ส่งสลิปผ่าน Messenger',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0084FF),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.amber.shade700, size: 20.0),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'ทีมงานจะตรวจสอบสลิปของคุณและอัปเดตสถานะภายใน 5-10 นาที',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool highlight) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: highlight ? Colors.blue : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13.sp),
          ),
        ),
      ],
    );
  }
}
