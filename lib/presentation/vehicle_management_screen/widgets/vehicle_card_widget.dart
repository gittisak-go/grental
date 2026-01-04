import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../models/vehicle_model.dart';

class VehicleCardWidget extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleCardWidget({
    Key? key,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String _formatCurrency(double amount) {
    return '฿${NumberFormat('#,##0', 'th').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
            child: CachedNetworkImage(
              imageUrl: vehicle.imageUrl,
              height: 20.h,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 20.h,
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 20.h,
                color: Colors.grey[300],
                child: Icon(Icons.directions_car, size: 50, color: Colors.grey),
              ),
            ),
          ),
          // Vehicle Details
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${vehicle.brand} ${vehicle.model}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: vehicle.isAvailable ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        vehicle.isAvailable ? 'Available' : 'Unavailable',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Year: ${vehicle.year}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 1.w),
                    Text(
                      '${vehicle.seats} Seats',
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.settings, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 1.w),
                    Text(
                      vehicle.transmission,
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.local_gas_station,
                        size: 16, color: Colors.grey[600]),
                    SizedBox(width: 1.w),
                    Text(
                      vehicle.fuelType,
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Price per day with Thai Baht
                          Text(
                            '${_formatCurrency(vehicle.pricePerDay)}/วัน',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: onEdit,
                          tooltip: 'Edit',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
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