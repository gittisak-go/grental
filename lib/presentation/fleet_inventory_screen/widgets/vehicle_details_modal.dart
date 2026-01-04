import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../models/fleet_vehicle_model.dart';
import '../../../services/fleet_service.dart';

class VehicleDetailsModal extends StatefulWidget {
  final FleetVehicleModel vehicle;
  final VoidCallback onStatusChanged;

  const VehicleDetailsModal({
    super.key,
    required this.vehicle,
    required this.onStatusChanged,
  });

  @override
  State<VehicleDetailsModal> createState() => _VehicleDetailsModalState();
}

class _VehicleDetailsModalState extends State<VehicleDetailsModal> {
  final FleetService _fleetService = FleetService();
  List<MaintenanceScheduleModel> _maintenanceSchedules = [];
  bool _isLoadingSchedules = true;

  @override
  void initState() {
    super.initState();
    _loadMaintenanceSchedules();
  }

  Future<void> _loadMaintenanceSchedules() async {
    try {
      final schedules =
          await _fleetService.getMaintenanceSchedules(widget.vehicle.id);
      setState(() {
        _maintenanceSchedules = schedules;
        _isLoadingSchedules = false;
      });
    } catch (e) {
      setState(() => _isLoadingSchedules = false);
    }
  }

  Color _getStatusColor() {
    return Color(int.parse(widget.vehicle.statusColor.substring(1), radix: 16) +
        0xFF000000);
  }

  void _showStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('เปลี่ยนสถานะรถ', style: TextStyle(fontSize: 16.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption('available', 'พร้อมใช้งาน'),
            _buildStatusOption('in_use', 'กำลังใช้งาน'),
            _buildStatusOption('maintenance', 'ซ่อมบำรุง'),
            _buildStatusOption('offline', 'ไม่พร้อมใช้'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ยกเลิก'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String status, String label) {
    return ListTile(
      leading: Icon(Icons.circle, color: _getStatusColorForOption(status)),
      title: Text(label),
      onTap: () async {
        try {
          await _fleetService.updateVehicleStatus(widget.vehicle.id, status);
          widget.onStatusChanged();
          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('อัปเดตสถานะเรียบร้อย')),
            );
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
            );
          }
        }
      },
    );
  }

  Color _getStatusColorForOption(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'in_use':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'offline':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 10.w,
                        height: 0.5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'รายละเอียดรถ',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(3.w),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        widget.vehicle.imageUrl,
                        height: 20.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 20.h,
                          color: Colors.grey[300],
                          child: Icon(Icons.directions_car, size: 60.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.vehicle.brand} ${widget.vehicle.model}',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.vehicle.licenseplate,
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _showStatusChangeDialog,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: _getStatusColor(),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.vehicle.statusLabel,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Icon(Icons.edit,
                                    color: Colors.white, size: 14.sp),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    _buildInfoSection('ข้อมูลพื้นฐาน', [
                      _buildInfoRow(
                          Icons.calendar_today, 'ปี', '${widget.vehicle.year}'),
                      _buildInfoRow(Icons.airline_seat_recline_normal,
                          'ที่นั่ง', '${widget.vehicle.seats} ที่นั่ง'),
                      _buildInfoRow(
                          Icons.build, 'เกียร์', widget.vehicle.transmission),
                      _buildInfoRow(Icons.local_gas_station, 'เชื้อเพลิง',
                          widget.vehicle.fuelType),
                    ]),
                    SizedBox(height: 2.h),
                    _buildInfoSection('สถานะการใช้งาน', [
                      _buildFuelGauge(),
                      _buildInfoRow(Icons.speed, 'เลขไมล์',
                          '${widget.vehicle.currentMileage.toStringAsFixed(0)} km'),
                      _buildInfoRow(Icons.trending_up, 'อัตราการใช้งาน',
                          '${widget.vehicle.utilizationRate.toStringAsFixed(1)}%'),
                    ]),
                    SizedBox(height: 2.h),
                    _buildInfoSection('ตำแหน่ง GPS', [
                      _buildInfoRow(Icons.location_on, 'พิกัด',
                          widget.vehicle.gpsLocation),
                      if (widget.vehicle.lastGpsUpdate != null)
                        _buildInfoRow(
                          Icons.access_time,
                          'อัปเดตล่าสุด',
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(widget.vehicle.lastGpsUpdate!),
                        ),
                    ]),
                    SizedBox(height: 2.h),
                    _buildInfoSection('การบำรุงรักษา', [
                      if (widget.vehicle.lastMaintenanceDate != null)
                        _buildInfoRow(
                          Icons.history,
                          'ครั้งล่าสุด',
                          DateFormat('dd/MM/yyyy')
                              .format(widget.vehicle.lastMaintenanceDate!),
                        ),
                      if (widget.vehicle.nextMaintenanceDate != null)
                        _buildInfoRow(
                          Icons.schedule,
                          'ครั้งถัดไป',
                          '${DateFormat('dd/MM/yyyy').format(widget.vehicle.nextMaintenanceDate!)} (ใน ${widget.vehicle.daysUntilMaintenance} วัน)',
                        ),
                    ]),
                    SizedBox(height: 2.h),
                    Text(
                      'ตารางบำรุงรักษา',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    _isLoadingSchedules
                        ? Center(child: CircularProgressIndicator())
                        : _maintenanceSchedules.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Text('ไม่มีตารางบำรุงรักษา',
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                ),
                              )
                            : Column(
                                children: _maintenanceSchedules.map((schedule) {
                                  return _buildMaintenanceCard(schedule);
                                }).toList(),
                              ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Schedule maintenance action
                            },
                            icon: Icon(Icons.add_circle_outline),
                            label: Text('นัดหมายบำรุงรักษา'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 1.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Colors.grey[600]),
          SizedBox(width: 2.w),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuelGauge() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.local_gas_station,
                      size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 2.w),
                  Text('เชื้อเพลิง',
                      style:
                          TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                ],
              ),
              Text(
                '${widget.vehicle.fuelLevel.toStringAsFixed(1)} / ${widget.vehicle.fuelCapacity.toStringAsFixed(1)} L',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          LinearProgressIndicator(
            value: widget.vehicle.fuelPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.vehicle.fuelPercentage > 30 ? Colors.green : Colors.orange,
            ),
            minHeight: 8.0,
          ),
          SizedBox(height: 0.5.h),
          Text(
            '${widget.vehicle.fuelPercentage.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(MaintenanceScheduleModel schedule) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  schedule.serviceType,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Color(int.parse(schedule.statusColor.substring(1),
                              radix: 16) +
                          0xFF000000)
                      .withAlpha(51),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  schedule.statusLabel,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Color(int.parse(schedule.statusColor.substring(1),
                            radix: 16) +
                        0xFF000000),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12.sp, color: Colors.grey[600]),
              SizedBox(width: 1.w),
              Text(
                'วันที่: ${DateFormat('dd/MM/yyyy').format(schedule.scheduledDate)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          if (schedule.notes != null && schedule.notes!.isNotEmpty) ...[
            SizedBox(height: 0.5.h),
            Text(
              schedule.notes!,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
            ),
          ],
          if (schedule.cost != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              'ค่าใช้จ่าย: ฿${schedule.cost!.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}
