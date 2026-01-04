import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../models/reservation_model.dart';
import '../../../models/vehicle_model.dart';

class ReservationDetailsDialog extends StatelessWidget {
  final ReservationModel reservation;
  final VehicleModel? vehicle;
  final Function(ReservationStatus) onStatusChanged;

  const ReservationDetailsDialog({
    Key? key,
    required this.reservation,
    this.vehicle,
    required this.onStatusChanged,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'th').format(date);
  }

  String _formatCurrency(double amount) {
    return '฿${NumberFormat('#,##0.00', 'th').format(amount)}';
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
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

  void _showStatusChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เปลี่ยนสถานะการจอง'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReservationStatus.values.map((status) {
            return ListTile(
              leading: Icon(
                Icons.circle,
                color: _getStatusColor(status),
              ),
              title: Text(status.displayName),
              onTap: () {
                Navigator.pop(context);
                onStatusChanged(status);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(26),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'รายละเอียดการจอง',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status
                    _buildSectionTitle('สถานะ'),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: _getStatusColor(reservation.status)
                                .withAlpha(26),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: _getStatusColor(reservation.status)),
                          ),
                          child: Text(
                            reservation.status.displayName,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(reservation.status),
                            ),
                          ),
                        ),
                        Spacer(),
                        TextButton.icon(
                          icon: Icon(Icons.edit),
                          label: Text('เปลี่ยนสถานะ'),
                          onPressed: () => _showStatusChangeDialog(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    // Customer Information
                    _buildSectionTitle('ข้อมูลลูกค้า'),
                    _buildInfoRow(
                        Icons.person, 'ชื่อ', reservation.customerName),
                    _buildInfoRow(
                        Icons.email, 'อีเมล', reservation.customerEmail),
                    _buildInfoRow(
                        Icons.phone, 'เบอร์โทร', reservation.customerPhone),
                    if (reservation.customerIdCard != null)
                      _buildInfoRow(Icons.credit_card, 'เลขบัตรประชาชน',
                          reservation.customerIdCard!),
                    SizedBox(height: 2.h),

                    // Vehicle Information
                    if (vehicle != null) ...[
                      _buildSectionTitle('ข้อมูลรถยนต์'),
                      _buildInfoRow(Icons.directions_car, 'รุ่นรถ',
                          '${vehicle!.brand} ${vehicle!.model}'),
                      _buildInfoRow(
                          Icons.calendar_today, 'ปี', '${vehicle!.year}'),
                      _buildInfoRow(Icons.airline_seat_recline_normal,
                          'ที่นั่ง', '${vehicle!.seats} ที่นั่ง'),
                      _buildInfoRow(Icons.local_gas_station, 'เชื้อเพลิง',
                          vehicle!.fuelType),
                      _buildInfoRow(
                          Icons.settings, 'เกียร์', vehicle!.transmission),
                      SizedBox(height: 2.h),
                    ],

                    // Rental Period
                    _buildSectionTitle('ระยะเวลาเช่า'),
                    _buildInfoRow(Icons.event, 'วันรับรถ',
                        _formatDate(reservation.startDate)),
                    _buildInfoRow(Icons.event, 'วันคืนรถ',
                        _formatDate(reservation.endDate)),
                    _buildInfoRow(Icons.access_time, 'จำนวนวัน',
                        '${reservation.totalDays} วัน'),
                    SizedBox(height: 2.h),

                    // Location
                    _buildSectionTitle('สถานที่'),
                    _buildInfoRow(Icons.location_on, 'จุดรับรถ',
                        reservation.pickupLocation),
                    if (reservation.dropoffLocation != null)
                      _buildInfoRow(Icons.location_on, 'จุดคืนรถ',
                          reservation.dropoffLocation!),
                    SizedBox(height: 2.h),

                    // Pricing
                    _buildSectionTitle('ข้อมูลราคา'),
                    _buildInfoRow(Icons.attach_money, 'ราคาต่อวัน',
                        _formatCurrency(reservation.dailyRate)),
                    _buildInfoRow(Icons.payment, 'มัดจำ',
                        _formatCurrency(reservation.depositAmount)),
                    Container(
                      margin: EdgeInsets.only(top: 1.h),
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(26),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ราคารวมทั้งหมด',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatCurrency(reservation.totalAmount),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Special Requests
                    if (reservation.specialRequests != null &&
                        reservation.specialRequests!.isNotEmpty) ...[
                      _buildSectionTitle('คำขอพิเศษ'),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          reservation.specialRequests!,
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          SizedBox(width: 2.w),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
