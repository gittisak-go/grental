import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class RentalDetailsSection extends StatelessWidget {
  final Map<String, dynamic> rentalData;
  final double vehiclePrice;

  const RentalDetailsSection({
    super.key,
    required this.rentalData,
    required this.vehiclePrice,
  });

  @override
  Widget build(BuildContext context) {
    final totalDays = rentalData['totalDays'] ?? 1;
    final totalAmount = vehiclePrice * totalDays;
    final depositAmount = totalAmount * 0.3;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('รายละเอียดการเช่า',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            Divider(height: 2.h),
            _buildDetailRow('วันรับรถ', rentalData['startDate'] ?? ''),
            _buildDetailRow('วันคืนรถ', rentalData['endDate'] ?? ''),
            _buildDetailRow('จำนวนวัน', '$totalDays วัน'),
            _buildDetailRow('สถานที่รับรถ', rentalData['pickupLocation'] ?? ''),
            if (rentalData['dropoffLocation'] != null &&
                rentalData['dropoffLocation'] != '')
              _buildDetailRow('สถานที่คืนรถ', rentalData['dropoffLocation']),
            Divider(height: 2.h),
            _buildDetailRow('ค่าเช่า', '฿${totalAmount.toStringAsFixed(0)}'),
            _buildDetailRow(
                'เงินมัดจำ (30%)', '฿${depositAmount.toStringAsFixed(0)}',
                isHighlight: true),
            Divider(height: 2.h),
            _buildDetailRow(
                'ยอดรวมทั้งหมด', '฿${totalAmount.toStringAsFixed(0)}',
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 12.sp,
              color: isTotal ? Colors.black : Colors.grey[700],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight:
                  isTotal || isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
