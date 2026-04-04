import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../models/reservation_model.dart';
import '../../models/vehicle_model.dart';
import '../../routes/app_routes.dart';
import '../../services/reservation_service.dart';
import '../../services/vehicle_service.dart';
import '../../services/magic_link_auth_service.dart';
import '../../widgets/custom_icon_widget.dart';

/// Viewer Dashboard — Read-only overview for Admin role
/// Shows key stats without edit capabilities
class ViewerDashboardScreen extends StatefulWidget {
  const ViewerDashboardScreen({super.key});

  @override
  State<ViewerDashboardScreen> createState() => _ViewerDashboardScreenState();
}

class _ViewerDashboardScreenState extends State<ViewerDashboardScreen> {
  final ReservationService _reservationService = ReservationService();
  final VehicleService _vehicleService = VehicleService();
  final MagicLinkAuthService _authService = MagicLinkAuthService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ReservationModel> _reservations = [];
  List<VehicleModel> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _checkAccess();
    _loadData();
  }

  Future<void> _checkAccess() async {
    if (!_authService.isCurrentUserAdmin) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.rideRequest,
          (route) => false,
        );
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final reservations = await _reservationService.getAllReservations();
      final vehicles = await _vehicleService.getAllVehicles();
      setState(() {
        _reservations = reservations;
        _vehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        _isLoading = false;
      });
    }
  }

  int get _todayBookings {
    final today = DateTime.now();
    return _reservations.where((r) {
      return r.createdAt.year == today.year &&
          r.createdAt.month == today.month &&
          r.createdAt.day == today.day;
    }).length;
  }

  int get _activeBookings {
    return _reservations
        .where(
          (r) =>
              r.status == ReservationStatus.active ||
              r.status == ReservationStatus.confirmed,
        )
        .length;
  }

  int get _availableVehicles {
    return _vehicles.where((v) => v.isAvailable).length;
  }

  double get _totalRevenue {
    return _reservations
        .where(
          (r) =>
              r.status == ReservationStatus.completed ||
              r.status == ReservationStatus.confirmed ||
              r.status == ReservationStatus.active,
        )
        .fold(0.0, (sum, r) => sum + r.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userRole = _authService.currentUserRole;
    final userEmail = _authService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.pink),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.rideRequest,
            (route) => false,
          ),
        ),
        title: Text(
          'แดชบอร์ดผู้ดูแล',
          style: TextStyle(
            color: Colors.grey[900],
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.pink),
            onPressed: _loadData,
            tooltip: 'รีเฟรช',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.pink),
            tooltip: 'ออกจากระบบ',
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.authentication,
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 2.h),
                  Text(_errorMessage!, textAlign: TextAlign.center),
                  SizedBox(height: 2.h),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('ลองอีกครั้ง'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.pink,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.pink, Color(0xFFE91E8C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 6.w,
                            backgroundColor: Colors.white.withAlpha(51),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'สวัสดี, $userRole',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userEmail,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(204),
                                    fontSize: 10.sp,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(51),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              userRole,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    Text(
                      'ภาพรวมระบบ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 2.h,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard(
                          title: 'จองวันนี้',
                          value: '$_todayBookings',
                          icon: Icons.today,
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          title: 'กำลังใช้งาน',
                          value: '$_activeBookings',
                          icon: Icons.directions_car,
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          title: 'รถว่าง',
                          value: '$_availableVehicles/${_vehicles.length}',
                          icon: Icons.local_parking,
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          title: 'รายได้รวม',
                          value: '฿${_totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.attach_money,
                          color: Colors.purple,
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Recent reservations
                    Text(
                      'การจองล่าสุด',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),

                    SizedBox(height: 1.5.h),

                    if (_reservations.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Text(
                            'ยังไม่มีการจอง',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      )
                    else
                      ...(_reservations
                          .take(10)
                          .map((r) => _buildReservationItem(r, theme))),

                    SizedBox(height: 3.h),

                    // Vehicle status
                    Text(
                      'สถานะรถยนต์',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),

                    SizedBox(height: 1.5.h),

                    if (_vehicles.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Text(
                            'ยังไม่มีข้อมูลรถ',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      )
                    else
                      ...(_vehicles
                          .take(10)
                          .map((v) => _buildVehicleItem(v, theme))),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: color, size: 5.w),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: TextStyle(fontSize: 9.sp, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReservationItem(ReservationModel r, ThemeData theme) {
    Color statusColor;
    String statusText;
    switch (r.status) {
      case ReservationStatus.confirmed:
        statusColor = Colors.blue;
        statusText = 'ยืนยันแล้ว';
        break;
      case ReservationStatus.active:
        statusColor = Colors.green;
        statusText = 'กำลังใช้งาน';
        break;
      case ReservationStatus.completed:
        statusColor = Colors.grey;
        statusText = 'เสร็จสิ้น';
        break;
      case ReservationStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'ยกเลิก';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'รอดำเนินการ';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(Icons.directions_car, color: statusColor, size: 5.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.customerName.isNotEmpty ? r.customerName : r.customerEmail,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '฿${r.totalAmount.toStringAsFixed(0)} • ${r.totalDays} วัน',
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 8.sp,
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleItem(VehicleModel v, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: v.isAvailable
                  ? Colors.green.withAlpha(26)
                  : Colors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(
              Icons.directions_car,
              color: v.isAvailable ? Colors.green : Colors.red,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${v.brand} ${v.model}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '฿${v.pricePerDay.toStringAsFixed(0)}/วัน',
                  style: TextStyle(fontSize: 9.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: v.isAvailable
                  ? Colors.green.withAlpha(26)
                  : Colors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              v.isAvailable ? 'ว่าง' : 'ไม่ว่าง',
              style: TextStyle(
                fontSize: 8.sp,
                color: v.isAvailable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}