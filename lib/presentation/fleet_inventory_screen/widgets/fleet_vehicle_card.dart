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
      int.parse(vehicle.statusColor.substring(1), radix: 16) + 0xFF000000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE0E5EC),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withAlpha(230),
              offset: Offset(-6, -6),
              blurRadius: 12.0,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(38),
              offset: Offset(6, 6),
              blurRadius: 12.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        offset: Offset(4, 4),
                        blurRadius: 8.0,
                      ),
                      BoxShadow(
                        color: Colors.white.withAlpha(204),
                        offset: Offset(-4, -4),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      vehicle.imageUrl,
                      height: 20.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Color(0xFFE0E5EC),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 50.sp,
                          color: Color(0xFF9BA8B8),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 3.w,
                  right: 3.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.5.w,
                      vertical: 0.8.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(64),
                          offset: Offset(2, 2),
                          blurRadius: 4.0,
                        ),
                      ],
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
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      vehicle.licenseplate.isNotEmpty
                          ? vehicle.licenseplate
                          : 'No Plate',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Color(0xFF6B7A99),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFE0E5EC),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(38),
                            offset: Offset(2, 2),
                            blurRadius: 4.0,
                          ),
                          BoxShadow(
                            color: Colors.white.withAlpha(230),
                            offset: Offset(-2, -2),
                            blurRadius: 4.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_gas_station,
                            size: 12.sp,
                            color: Color(0xFF6B7A99),
                          ),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Container(
                              height: 4.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(38),
                                    offset: Offset(1, 1),
                                    blurRadius: 2.0,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.0),
                                child: LinearProgressIndicator(
                                  value: vehicle.fuelPercentage / 100,
                                  backgroundColor: Color(0xFFCDD5E0),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    vehicle.fuelPercentage > 30
                                        ? Color(0xFF4CAF50)
                                        : Color(0xFFFF9800),
                                  ),
                                  minHeight: 4.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${vehicle.fuelPercentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Color(0xFF6B7A99),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12.sp,
                          color: Color(0xFF6B7A99),
                        ),
                        SizedBox(width: 1.w),
                        Expanded(
                          child: Text(
                            vehicle.gpsLocation,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Color(0xFF9BA8B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
