import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleInfoCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CustomImageWidget(
              imageUrl: vehicle['image_url'] ?? '',
              height: 80.0,
              width: 100.0,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle['brand']} ${vehicle['model']}',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 2.w),
                    Text('${vehicle['year']}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    SizedBox(width: 4.w),
                    Icon(Icons.settings, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 2.w),
                    Text(vehicle['transmission'] ?? '',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(Icons.airline_seat_recline_normal,
                        size: 14.sp, color: Colors.grey),
                    SizedBox(width: 2.w),
                    Text('${vehicle['seats']} ที่นั่ง',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    SizedBox(width: 4.w),
                    Icon(Icons.local_gas_station,
                        size: 14.sp, color: Colors.grey),
                    SizedBox(width: 2.w),
                    Text(vehicle['fuel_type'] ?? '',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}