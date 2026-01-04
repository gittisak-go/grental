import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/fleet_vehicle_model.dart';

class FleetVehicleCard extends StatelessWidget {
  final FleetVehicleModel vehicle;
  final VoidCallback onTap;

  const FleetVehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
  });

  Color _getStatusColor() {
    return Color(
        int.parse(vehicle.statusColor.substring(1), radix: 16) + 0xFF000000);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12.0)),
                  child: Image.network(
                    vehicle.imageUrl,
                    height: 15.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 15.h,
                      color: Colors.grey[300],
                      child: Icon(Icons.directions_car,
                          size: 40.sp, color: Colors.grey[500]),
                    ),
                  ),
                ),
                Positioned(
                  top: 1.h,
                  right: 1.h,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Text(
                      vehicle.statusLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      vehicle.licenseplate.isNotEmpty
                          ? vehicle.licenseplate
                          : 'No Plate',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(Icons.local_gas_station,
                            size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: vehicle.fuelPercentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              vehicle.fuelPercentage > 30
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            minHeight: 4.0,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${vehicle.fuelPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 11.sp, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            vehicle.gpsLocation,
                            style: TextStyle(
                                fontSize: 10.sp, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Icon(Icons.build, size: 14.sp, color: Colors.grey[600]),
                        SizedBox(width: 1.w),
                        Text(
                          vehicle.nextMaintenanceDate != null
                              ? 'ใน ${vehicle.daysUntilMaintenance} วัน'
                              : 'ไม่มีกำหนด',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: vehicle.daysUntilMaintenance < 7 &&
                                    vehicle.daysUntilMaintenance > 0
                                ? Colors.orange
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
