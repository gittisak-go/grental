import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PaymentStatusNotificationWidget extends StatelessWidget {
  final String status;
  final String? verificationNotes;
  final DateTime? verifiedAt;

  const PaymentStatusNotificationWidget({
    super.key,
    required this.status,
    this.verificationNotes,
    this.verifiedAt,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: statusInfo['backgroundColor'],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: statusInfo['borderColor'],
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusInfo['icon'],
                  color: statusInfo['iconColor'],
                  size: 24.0,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo['title'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: statusInfo['textColor'],
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      statusInfo['message'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: statusInfo['textColor'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (verificationNotes != null && verificationNotes!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'หมายเหตุจากเจ้าหน้าที่:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    verificationNotes!,
                    style: TextStyle(fontSize: 12.sp),
                  ),
                  if (verifiedAt != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      'เมื่อ: ${_formatDateTime(verifiedAt!)}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo() {
    switch (status.toLowerCase()) {
      case 'pending':
        return {
          'icon': Icons.schedule,
          'iconColor': Colors.orange,
          'backgroundColor': Colors.orange.shade50,
          'borderColor': Colors.orange.shade200,
          'textColor': Colors.orange.shade900,
          'title': 'รอการชำระเงิน',
          'message': 'กรุณาโอนเงินและส่งสลิปเพื่อยืนยันการจอง',
        };
      case 'processing':
        return {
          'icon': Icons.pending_actions,
          'iconColor': Colors.blue,
          'backgroundColor': Colors.blue.shade50,
          'borderColor': Colors.blue.shade200,
          'textColor': Colors.blue.shade900,
          'title': 'กำลังตรวจสอบ',
          'message': 'เจ้าหน้าที่กำลังตรวจสอบสลิปของคุณ กรุณารอสักครู่',
        };
      case 'completed':
        return {
          'icon': Icons.check_circle,
          'iconColor': Colors.green,
          'backgroundColor': Colors.green.shade50,
          'borderColor': Colors.green.shade200,
          'textColor': Colors.green.shade900,
          'title': 'ชำระเงินสำเร็จ',
          'message': 'การชำระเงินของคุณได้รับการยืนยันแล้ว',
        };
      case 'failed':
        return {
          'icon': Icons.error,
          'iconColor': Colors.red,
          'backgroundColor': Colors.red.shade50,
          'borderColor': Colors.red.shade200,
          'textColor': Colors.red.shade900,
          'title': 'การชำระเงินไม่สำเร็จ',
          'message': 'เกิดปัญหาในการตรวจสอบสลิป กรุณาติดต่อเจ้าหน้าที่',
        };
      case 'refunded':
        return {
          'icon': Icons.refresh,
          'iconColor': Colors.purple,
          'backgroundColor': Colors.purple.shade50,
          'borderColor': Colors.purple.shade200,
          'textColor': Colors.purple.shade900,
          'title': 'คืนเงินแล้ว',
          'message': 'ยอดเงินได้รับการคืนเรียบร้อยแล้ว',
        };
      default:
        return {
          'icon': Icons.info,
          'iconColor': Colors.grey,
          'backgroundColor': Colors.grey.shade50,
          'borderColor': Colors.grey.shade200,
          'textColor': Colors.grey.shade900,
          'title': 'ไม่ทราบสถานะ',
          'message': 'กรุณาติดต่อเจ้าหน้าที่เพื่อตรวจสอบ',
        };
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} น.';
  }
}
