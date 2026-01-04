import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class RentalTimelineWidget extends StatelessWidget {
  final Map<String, dynamic> rental;

  const RentalTimelineWidget({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ช่วงเวลาเช่า',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildTimelineItem(
                  'วันรับรถ',
                  rental['start_date'] ?? '',
                  rental['pickup_location'] ?? '',
                  Icons.calendar_today,
                  Colors.green,
                ),
              ),
              Icon(Icons.arrow_forward, color: Colors.grey[400]),
              Expanded(
                child: _buildTimelineItem(
                  'วันคืนรถ',
                  rental['end_date'] ?? '',
                  rental['dropoff_location'] ?? rental['pickup_location'] ?? '',
                  Icons.event_available,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                    'จำนวนวัน', '${rental['total_days']} วัน', Icons.event),
                _buildInfoItem('ค่าเช่า/วัน',
                    '฿${rental['daily_rate'].toStringAsFixed(0)}', Icons.money),
                _buildInfoItem(
                    'ยอดรวม',
                    '฿${rental['total_amount'].toStringAsFixed(0)}',
                    Icons.payment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
      String label, String date, String location, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32.0),
        SizedBox(height: 1.h),
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700])),
        SizedBox(height: 0.5.h),
        Text(date,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 0.5.h),
        Text(location,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: Colors.blue),
        SizedBox(height: 0.5.h),
        Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey[700])),
        Text(value,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
