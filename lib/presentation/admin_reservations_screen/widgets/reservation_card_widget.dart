import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../models/reservation_model.dart';
import '../../../models/vehicle_model.dart';

class ReservationCardWidget extends StatelessWidget {
  final ReservationModel reservation;
  final VehicleModel? vehicle;
  final VoidCallback onTap;

  const ReservationCardWidget({
    Key? key,
    required this.reservation,
    this.vehicle,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.blue;
      case ReservationStatus.active:
        return Colors.green;
      case ReservationStatus.completed:
        return Colors.grey;
      case ReservationStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'th').format(date);
  }

  String _formatCurrency(double amount) {
    return '฿${NumberFormat('#,##0.00', 'th').format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      reservation.status.displayName,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    _formatDate(reservation.createdAt),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),

              // Customer Info
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey[700]),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      reservation.customerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 2.w),
                  Text(
                    reservation.customerPhone,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.5.h),
              Divider(),
              SizedBox(height: 1.h),

              // Vehicle Info
              if (vehicle != null) ...[
                Row(
                  children: [
                    Icon(Icons.directions_car,
                        size: 18, color: Colors.grey[700]),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        '${vehicle!.brand} ${vehicle!.model} (${vehicle!.year})',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
              ],

              // Date Range
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 2.w),
                  Text(
                    '${_formatDate(reservation.startDate)} - ${_formatDate(reservation.endDate)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '(${reservation.totalDays} วัน)',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      reservation.pickupLocation,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.h),
              Divider(),
              SizedBox(height: 1.h),

              // Price Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ราคารวม',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatCurrency(reservation.totalAmount),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  if (reservation.depositAmount > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'มัดจำ',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _formatCurrency(reservation.depositAmount),
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
