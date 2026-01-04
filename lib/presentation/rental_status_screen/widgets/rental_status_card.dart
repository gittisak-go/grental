import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class RentalStatusCard extends StatelessWidget {
  final Map<String, dynamic> rental;

  const RentalStatusCard({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    final status = rental['status'] ?? 'pending';
    final bookingRef = rental['id'].toString().substring(0, 8);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withAlpha(26),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('หมายเลขการจอง',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              SizedBox(height: 0.5.h),
              Text(bookingRef,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace')),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              _getStatusLabel(status),
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'ยืนยันแล้ว';
      case 'active':
        return 'กำลังเช่า';
      case 'completed':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return 'รอดำเนินการ';
    }
  }
}
