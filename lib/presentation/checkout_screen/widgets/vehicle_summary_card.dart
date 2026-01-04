import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class VehicleSummaryCard extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleSummaryCard({super.key, required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CustomImageWidget(
                imageUrl: vehicleData['image_url'] ?? '',
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
                    '${vehicleData['brand']} ${vehicleData['model']}',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14.sp, color: Colors.grey),
                      SizedBox(width: 2.w),
                      Text('${vehicleData['year']}',
                          style:
                              TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Icon(Icons.settings, size: 14.sp, color: Colors.grey),
                      SizedBox(width: 2.w),
                      Text(vehicleData['transmission'] ?? '',
                          style:
                              TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '฿${vehicleData['price_per_day'].toStringAsFixed(0)}/วัน',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}