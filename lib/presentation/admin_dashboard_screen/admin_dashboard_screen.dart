import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

import '../../core/app_export.dart';
import '../../models/car_model.dart';
import '../../models/booking_payment_model.dart';
import '../../services/booking_service.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Color constants matching app_colors.dart ────────────────────────────────
const _kPrimary = Color(0xFFFF2D78);
const _kSecondary = Color(0xFF2979FF);
const _kBackground = Color(0xFF0A0A12);
const _kSurface = Color(0xFF16161E);
const _kAccent = Color(0xFFFFE500);
const _kSuccess = Color(0xFF00FFC2);
const _kError = Color(0xFFFF453A);
const _kTextPrimary = Color(0xFFFFFFFF);
const _kTextSecondary = Color(0xFF8E8E93);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();

  bool _isLoading = true;
  String? _errorMessage;

  List<BookingModel> _allBookings = [];
  List<CarModel> _allCars = [];

  // Realtime channels
  RealtimeChannel? _bookingsChannel;
  RealtimeChannel? _carsChannel;
  RealtimeChannel? _paymentsChannel;

  late TabController _tabController;

  // Quick action loading states
  final Map<String, bool> _actionLoading = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _setupRealtime();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookingsChannel?.unsubscribe();
    _carsChannel?.unsubscribe();
    _paymentsChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final bookings = await _bookingService.getAllBookings();
      final cars = await _bookingService.getAllCars();
      if (mounted) {
        setState(() {
          _allBookings = bookings;
          _allCars = cars;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'โหลดข้อมูลไม่สำเร็จ: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _setupRealtime() {
    final client = SupabaseService.instance.client;

    _bookingsChannel = client
        .channel('admin-bookings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (_) => _loadData(),
        )
        .subscribe();

    _carsChannel = client
        .channel('admin-cars')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'cars',
          callback: (_) => _loadData(),
        )
        .subscribe();

    _paymentsChannel = client
        .channel('admin-payments')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'payments',
          callback: (_) => _loadData(),
        )
        .subscribe();
  }

  // ─── Computed stats ────────────────────────────────────────────────────────

  int get _pendingBookingsCount =>
      _allBookings.where((b) => b.status == 'pending').length;

  int get _activeBookingsCount =>
      _allBookings.where((b) => b.status == 'active').length;

  int get _pendingPaymentsCount {
    int count = 0;
    for (final b in _allBookings) {
      if (b.payments != null) {
        for (final p in b.payments!) {
          if (p['status'] == 'pending' && p['slip_url'] != null) count++;
        }
      }
    }
    return count;
  }

  double get _totalRevenue {
    double total = 0;
    for (final b in _allBookings) {
      if (b.payments != null) {
        for (final p in b.payments!) {
          if (p['status'] == 'paid') {
            total += (p['amount'] as num?)?.toDouble() ?? 0;
          }
        }
      }
    }
    return total;
  }

  int get _availableCarsCount =>
      _allCars.where((c) => c.status == 'available').length;

  // ─── Actions ───────────────────────────────────────────────────────────────

  Future<void> _approveBooking(String bookingId) async {
    setState(() => _actionLoading[bookingId] = true);
    try {
      await SupabaseService.instance.client
          .from('bookings')
          .update({'status': 'confirmed'}).eq('id', bookingId);
      _showSnack('ยืนยันการจองสำเร็จ', _kSuccess);
      await _loadData();
    } catch (e) {
      _showSnack('ยืนยันไม่สำเร็จ: $e', _kError);
    } finally {
      if (mounted) setState(() => _actionLoading.remove(bookingId));
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmed = await _showConfirmDialog(
      'ยกเลิกการจอง',
      'คุณแน่ใจหรือไม่ว่าต้องการยกเลิกการจองนี้?',
    );
    if (!confirmed) return;

    setState(() => _actionLoading[bookingId] = true);
    try {
      await _bookingService.cancelBooking(bookingId);
      _showSnack('ยกเลิกการจองสำเร็จ', _kAccent);
      await _loadData();
    } catch (e) {
      _showSnack('ยกเลิกไม่สำเร็จ: $e', _kError);
    } finally {
      if (mounted) setState(() => _actionLoading.remove(bookingId));
    }
  }

  Future<void> _verifyPayment(String paymentId) async {
    setState(() => _actionLoading[paymentId] = true);
    try {
      await _bookingService.confirmPayment(paymentId);
      _showSnack('ยืนยันการชำระเงินสำเร็จ', _kSuccess);
      await _loadData();
    } catch (e) {
      _showSnack('ยืนยันการชำระเงินไม่สำเร็จ: $e', _kError);
    } finally {
      if (mounted) setState(() => _actionLoading.remove(paymentId));
    }
  }

  Future<void> _updateCarStatus(String carId, String newStatus) async {
    setState(() => _actionLoading[carId] = true);
    try {
      await SupabaseService.instance.client
          .from('cars')
          .update({'status': newStatus}).eq('id', carId);
      _showSnack('อัปเดตสถานะรถสำเร็จ', _kSuccess);
      await _loadData();
    } catch (e) {
      _showSnack('อัปเดตสถานะไม่สำเร็จ: $e', _kError);
    } finally {
      if (mounted) setState(() => _actionLoading.remove(carId));
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.dmSans(
              color: _kBackground, fontWeight: FontWeight.w600)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    ));
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: _kSurface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0)),
            title: Text(title,
                style: GoogleFonts.dmSans(
                    color: _kTextPrimary, fontWeight: FontWeight.bold)),
            content: Text(content,
                style: GoogleFonts.dmSans(color: _kTextSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('ยกเลิก',
                    style: GoogleFonts.dmSans(color: _kTextSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: _kError),
                child: Text('ยืนยัน',
                    style: GoogleFonts.dmSans(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ??
        false;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
              ? _buildError()
              : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _kSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: _kPrimary),
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.rideRequest, (r) => false),
      ),
      title: Row(
        children: [
          Text('Admin Dashboard',
              style: GoogleFonts.dmSans(
                  color: _kTextPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(width: 2.w),
          _liveChip(),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: _kPrimary),
          onPressed: _loadData,
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: _kPrimary,
        labelColor: _kPrimary,
        unselectedLabelColor: _kTextSecondary,
        labelStyle:
            GoogleFonts.dmSans(fontSize: 11.sp, fontWeight: FontWeight.w600),
        tabs: [
          Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.list_alt_rounded, size: 16),
              SizedBox(width: 1.w),
              const Text('การจอง'),
              if (_pendingBookingsCount > 0) ...[
                SizedBox(width: 1.w),
                _badge(_pendingBookingsCount, _kAccent),
              ],
            ]),
          ),
          Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.payment_rounded, size: 16),
              SizedBox(width: 1.w),
              const Text('ชำระเงิน'),
              if (_pendingPaymentsCount > 0) ...[
                SizedBox(width: 1.w),
                _badge(_pendingPaymentsCount, _kError),
              ],
            ]),
          ),
          Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.directions_car_rounded, size: 16),
              SizedBox(width: 1.w),
              const Text('รถยนต์'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _liveChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
      decoration: BoxDecoration(
        color: _kSuccess.withAlpha(30),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: _kSuccess.withAlpha(80)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6,
          height: 6,
          decoration:
              const BoxDecoration(color: _kSuccess, shape: BoxShape.circle),
        ),
        SizedBox(width: 1.w),
        Text('LIVE',
            style: GoogleFonts.dmSans(
                color: _kSuccess, fontSize: 9.sp, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _badge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(10.0)),
      child: Text('$count',
          style: GoogleFonts.dmSans(
              color: _kBackground,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: _kPrimary),
        SizedBox(height: 2.h),
        Text('กำลังโหลดข้อมูล...',
            style: GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 13.sp)),
      ]),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline_rounded, color: _kError, size: 56),
          SizedBox(height: 2.h),
          Text(_errorMessage!,
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 13.sp)),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('ลองอีกครั้ง'),
            style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
          ),
        ]),
      ),
    );
  }

  Widget _buildBody() {
    return Column(children: [
      _buildStatsRow(),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBookingsTab(),
            _buildPaymentsTab(),
            _buildVehiclesTab(),
          ],
        ),
      ),
    ]);
  }

  // ─── Stats Row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Container(
      color: _kSurface,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: Row(children: [
        _statChip(Icons.pending_actions_rounded, '$_pendingBookingsCount',
            'รอยืนยัน', _kAccent),
        SizedBox(width: 2.w),
        _statChip(Icons.directions_car_rounded, '$_activeBookingsCount',
            'กำลังใช้', _kSecondary),
        SizedBox(width: 2.w),
        _statChip(Icons.check_circle_rounded, '$_availableCarsCount', 'รถว่าง',
            _kSuccess),
        SizedBox(width: 2.w),
        _statChip(
            Icons.attach_money_rounded,
            '฿${NumberFormat('#,##0').format(_totalRevenue)}',
            'รายได้',
            _kPrimary),
      ]),
    );
  }

  Widget _statChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 1.5.w),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          SizedBox(height: 0.3.h),
          Text(value,
              style: GoogleFonts.dmSans(
                  color: color, fontSize: 11.sp, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 8.sp),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  // ─── Bookings Tab ──────────────────────────────────────────────────────────

  Widget _buildBookingsTab() {
    if (_allBookings.isEmpty) {
      return _buildEmptyState(Icons.event_busy_rounded, 'ยังไม่มีการจอง');
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      color: _kPrimary,
      backgroundColor: _kSurface,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        itemCount: _allBookings.length,
        itemBuilder: (ctx, i) => _buildBookingCard(_allBookings[i]),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final statusColor = _bookingStatusColor(booking.status);
    final isLoading = _actionLoading[booking.id ?? ''] == true;
    final carInfo = booking.car;
    final carName = carInfo != null
        ? '${carInfo['brand'] ?? ''} ${carInfo['model'] ?? ''}'
        : 'ไม่ทราบรถ';

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: statusColor.withAlpha(60)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14.0),
              topRight: Radius.circular(14.0),
            ),
          ),
          child: Row(children: [
            Icon(Icons.directions_car_rounded, color: statusColor, size: 18),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(carName,
                  style: GoogleFonts.dmSans(
                      color: _kTextPrimary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
            ),
            _statusBadge(booking.statusDisplay, statusColor),
          ]),
        ),
        // Body
        Padding(
          padding: EdgeInsets.all(4.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.calendar_today_rounded,
                  color: _kTextSecondary, size: 14),
              SizedBox(width: 1.w),
              Text(
                '${DateFormat('dd MMM yy').format(booking.startDate)} → ${DateFormat('dd MMM yy').format(booking.endDate)}',
                style:
                    GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 11.sp),
              ),
              const Spacer(),
              Text(
                '฿${NumberFormat('#,##0').format(booking.totalAmount)}',
                style: GoogleFonts.dmSans(
                    color: _kSuccess,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold),
              ),
            ]),
            SizedBox(height: 0.8.h),
            Row(children: [
              const Icon(Icons.tag_rounded, color: _kTextSecondary, size: 14),
              SizedBox(width: 1.w),
              Text(
                (booking.id ?? '').length > 8
                    ? '#${(booking.id ?? '').substring(0, 8).toUpperCase()}'
                    : '#${booking.id ?? ''}',
                style:
                    GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 10.sp),
              ),
              SizedBox(width: 3.w),
              const Icon(Icons.access_time_rounded,
                  color: _kTextSecondary, size: 14),
              SizedBox(width: 1.w),
              Text(
                booking.createdAt != null
                    ? DateFormat('dd/MM/yy HH:mm').format(booking.createdAt!)
                    : '-',
                style:
                    GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 10.sp),
              ),
            ]),
            // Quick action buttons
            if (booking.status == 'pending' ||
                booking.status == 'confirmed') ...[
              SizedBox(height: 1.5.h),
              Row(children: [
                if (booking.status == 'pending')
                  Expanded(
                    child: _actionBtn(
                      label: 'อนุมัติ',
                      icon: Icons.check_circle_outline_rounded,
                      color: _kSuccess,
                      isLoading: isLoading,
                      onTap: () => _approveBooking(booking.id!),
                    ),
                  ),
                if (booking.status == 'pending') SizedBox(width: 2.w),
                Expanded(
                  child: _actionBtn(
                    label: 'ยกเลิก',
                    icon: Icons.cancel_outlined,
                    color: _kError,
                    isLoading: isLoading,
                    onTap: () => _cancelBooking(booking.id!),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      ]),
    );
  }

  // ─── Payments Tab ──────────────────────────────────────────────────────────

  Widget _buildPaymentsTab() {
    // Flatten all payments from bookings
    final payments = <Map<String, dynamic>>[];
    for (final b in _allBookings) {
      if (b.payments != null) {
        for (final p in b.payments!) {
          payments.add({...p, '_booking': b});
        }
      }
    }

    if (payments.isEmpty) {
      return _buildEmptyState(
          Icons.receipt_long_rounded, 'ยังไม่มีข้อมูลการชำระเงิน');
    }

    // Sort: pending with slip first
    payments.sort((a, b) {
      final aHasSlip = a['slip_url'] != null && a['status'] == 'pending';
      final bHasSlip = b['slip_url'] != null && b['status'] == 'pending';
      if (aHasSlip && !bHasSlip) return -1;
      if (!aHasSlip && bHasSlip) return 1;
      return 0;
    });

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _kPrimary,
      backgroundColor: _kSurface,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        itemCount: payments.length,
        itemBuilder: (ctx, i) => _buildPaymentCard(payments[i]),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final status = payment['status'] as String? ?? 'pending';
    final statusColor = _paymentStatusColor(status);
    final hasSlip = payment['slip_url'] != null;
    final paymentId = payment['id'] as String? ?? '';
    final isLoading = _actionLoading[paymentId] == true;
    final booking = payment['_booking'] as BookingModel?;
    final method = payment['method'] as String? ?? 'cash';
    final amount = (payment['amount'] as num?)?.toDouble() ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: (hasSlip && status == 'pending')
              ? _kAccent.withAlpha(120)
              : statusColor.withAlpha(60),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14.0),
              topRight: Radius.circular(14.0),
            ),
          ),
          child: Row(children: [
            Icon(_paymentMethodIcon(method), color: statusColor, size: 18),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(_paymentMethodDisplay(method),
                  style: GoogleFonts.dmSans(
                      color: _kTextPrimary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold)),
            ),
            if (hasSlip && status == 'pending')
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: _kAccent.withAlpha(30),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: _kAccent.withAlpha(100)),
                ),
                child: Text('มีสลิป',
                    style: GoogleFonts.dmSans(
                        color: _kAccent,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold)),
              ),
            SizedBox(width: 2.w),
            _statusBadge(_paymentStatusDisplay(status), statusColor),
          ]),
        ),
        // Body
        Padding(
          padding: EdgeInsets.all(4.w),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('฿${NumberFormat('#,##0').format(amount)}',
                  style: GoogleFonts.dmSans(
                      color: _kTextPrimary,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              if (booking != null)
                Text(
                  'จอง: ${booking.id != null && booking.id!.length > 8 ? '#${booking.id!.substring(0, 8).toUpperCase()}' : '#${booking.id ?? ''}'}',
                  style: GoogleFonts.dmSans(
                      color: _kTextSecondary, fontSize: 10.sp),
                ),
            ]),
            if (payment['paid_at'] != null) ...[
              SizedBox(height: 0.5.h),
              Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: _kSuccess, size: 14),
                SizedBox(width: 1.w),
                Text(
                  'ชำระเมื่อ: ${DateFormat('dd/MM/yy HH:mm').format(DateTime.parse(payment['paid_at'] as String))}',
                  style: GoogleFonts.dmSans(color: _kSuccess, fontSize: 10.sp),
                ),
              ]),
            ],
            // Slip preview + verify button
            if (hasSlip) ...[
              SizedBox(height: 1.5.h),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _showSlipDialog(payment['slip_url'] as String),
                    icon: const Icon(Icons.image_rounded, size: 16),
                    label: const Text('ดูสลิป'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kSecondary,
                      side: BorderSide(color: _kSecondary.withAlpha(100)),
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                    ),
                  ),
                ),
                if (status == 'pending') ...[
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _actionBtn(
                      label: 'ยืนยันสลิป',
                      icon: Icons.verified_rounded,
                      color: _kSuccess,
                      isLoading: isLoading,
                      onTap: () => _verifyPayment(paymentId),
                    ),
                  ),
                ],
              ]),
            ],
          ]),
        ),
      ]),
    );
  }

  void _showSlipDialog(String slipUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: _kSurface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(children: [
              Text('สลิปการชำระเงิน',
                  style: GoogleFonts.dmSans(
                      color: _kTextPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: _kTextSecondary),
                onPressed: () => Navigator.pop(ctx),
              ),
            ]),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
            ),
            child: Image.network(
              slipUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(children: [
                  const Icon(Icons.broken_image_rounded,
                      color: _kTextSecondary, size: 48),
                  SizedBox(height: 1.h),
                  Text('ไม่สามารถโหลดรูปได้',
                      style: GoogleFonts.dmSans(color: _kTextSecondary)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ─── Vehicles Tab ──────────────────────────────────────────────────────────

  Widget _buildVehiclesTab() {
    if (_allCars.isEmpty) {
      return _buildEmptyState(Icons.no_transfer_rounded, 'ยังไม่มีข้อมูลรถ');
    }

    // Group by status
    final available = _allCars.where((c) => c.status == 'available').toList();
    final rented = _allCars.where((c) => c.status == 'rented').toList();
    final maintenance =
        _allCars.where((c) => c.status == 'maintenance').toList();
    final inactive = _allCars.where((c) => c.status == 'inactive').toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      color: _kPrimary,
      backgroundColor: _kSurface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Summary row
          _buildCarSummaryRow(available.length, rented.length,
              maintenance.length, inactive.length),
          SizedBox(height: 2.h),
          if (available.isNotEmpty) ...[
            _sectionHeader('ว่าง', available.length, _kSuccess),
            SizedBox(height: 1.h),
            _buildCarGrid(available),
            SizedBox(height: 2.h),
          ],
          if (rented.isNotEmpty) ...[
            _sectionHeader('กำลังเช่า', rented.length, _kSecondary),
            SizedBox(height: 1.h),
            _buildCarGrid(rented),
            SizedBox(height: 2.h),
          ],
          if (maintenance.isNotEmpty) ...[
            _sectionHeader('ซ่อมบำรุง', maintenance.length, _kAccent),
            SizedBox(height: 1.h),
            _buildCarGrid(maintenance),
            SizedBox(height: 2.h),
          ],
          if (inactive.isNotEmpty) ...[
            _sectionHeader('ไม่ใช้งาน', inactive.length, _kTextSecondary),
            SizedBox(height: 1.h),
            _buildCarGrid(inactive),
          ],
        ]),
      ),
    );
  }

  Widget _buildCarSummaryRow(int avail, int rented, int maint, int inactive) {
    return Row(children: [
      _carSummaryChip('ว่าง', avail, _kSuccess),
      SizedBox(width: 2.w),
      _carSummaryChip('เช่า', rented, _kSecondary),
      SizedBox(width: 2.w),
      _carSummaryChip('ซ่อม', maint, _kAccent),
      SizedBox(width: 2.w),
      _carSummaryChip('ปิด', inactive, _kTextSecondary),
    ]);
  }

  Widget _carSummaryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(children: [
          Text('$count',
              style: GoogleFonts.dmSans(
                  color: color, fontSize: 14.sp, fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 9.sp)),
        ]),
      ),
    );
  }

  Widget _sectionHeader(String title, int count, Color color) {
    return Row(children: [
      Container(
          width: 3,
          height: 18,
          color: color,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2.0))),
      SizedBox(width: 2.w),
      Text(title,
          style: GoogleFonts.dmSans(
              color: _kTextPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold)),
      SizedBox(width: 2.w),
      _badge(count, color),
    ]);
  }

  Widget _buildCarGrid(List<CarModel> cars) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 1.5.h,
        childAspectRatio: 1.4,
      ),
      itemCount: cars.length,
      itemBuilder: (ctx, i) => _buildCarCard(cars[i]),
    );
  }

  Widget _buildCarCard(CarModel car) {
    final statusColor = _carStatusColor(car.status);
    final isLoading = _actionLoading[car.id] == true;

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: statusColor.withAlpha(60)),
      ),
      child: Column(children: [
        // Car image or placeholder
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: car.imageUrls.isNotEmpty
                ? Image.network(car.imageUrls.first,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => _carPlaceholder(statusColor))
                : _carPlaceholder(statusColor),
          ),
        ),
        // Info + action
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${car.brand} ${car.model}',
                style: GoogleFonts.dmSans(
                    color: _kTextPrimary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Row(children: [
              Expanded(
                child: Text(car.plate,
                    style: GoogleFonts.dmSans(
                        color: _kTextSecondary, fontSize: 9.sp),
                    overflow: TextOverflow.ellipsis),
              ),
              _statusDot(statusColor),
            ]),
            SizedBox(height: 0.5.h),
            // Status change button
            isLoading
                ? const Center(
                    child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _kPrimary)))
                : _carStatusButton(car),
          ]),
        ),
      ]),
    );
  }

  Widget _carPlaceholder(Color color) {
    return Container(
      color: color.withAlpha(20),
      child: Center(
          child: Icon(Icons.directions_car_rounded, color: color, size: 32)),
    );
  }

  Widget _statusDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _carStatusButton(CarModel car) {
    final nextStatus = _nextCarStatus(car.status);
    if (nextStatus == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _showCarStatusMenu(car),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 0.4.h),
        decoration: BoxDecoration(
          color: _kPrimary.withAlpha(20),
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(color: _kPrimary.withAlpha(60)),
        ),
        child: Text('เปลี่ยนสถานะ',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
                color: _kPrimary, fontSize: 9.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCarStatusMenu(CarModel car) {
    final statuses = ['available', 'rented', 'maintenance', 'inactive'];
    showModalBottomSheet(
      context: context,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _kTextSecondary.withAlpha(60),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          SizedBox(height: 2.h),
          Text('${car.brand} ${car.model} (${car.plate})',
              style: GoogleFonts.dmSans(
                  color: _kTextPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 0.5.h),
          Text('เลือกสถานะใหม่',
              style:
                  GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 12.sp)),
          SizedBox(height: 2.h),
          ...statuses.map((s) {
            final color = _carStatusColor(s);
            final isCurrent = s == car.status;
            return ListTile(
              onTap: isCurrent
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      _updateCarStatus(car.id, s);
                    },
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(_carStatusIcon(s), color: color, size: 18),
              ),
              title: Text(_carStatusDisplay(s),
                  style: GoogleFonts.dmSans(
                      color: isCurrent ? _kTextSecondary : _kTextPrimary,
                      fontWeight:
                          isCurrent ? FontWeight.normal : FontWeight.w600)),
              trailing: isCurrent
                  ? const Icon(Icons.check_rounded, color: _kSuccess)
                  : null,
            );
          }),
          SizedBox(height: 1.h),
        ]),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: _kTextSecondary.withAlpha(100), size: 56),
        SizedBox(height: 2.h),
        Text(message,
            style: GoogleFonts.dmSans(color: _kTextSecondary, fontSize: 13.sp)),
      ]),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label,
          style: GoogleFonts.dmSans(
              color: color, fontSize: 9.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: color))
          : Icon(icon, size: 14),
      label: Text(label,
          style:
              GoogleFonts.dmSans(fontSize: 10.sp, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(30),
        foregroundColor: color,
        side: BorderSide(color: color.withAlpha(100)),
        padding: EdgeInsets.symmetric(vertical: 1.h),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  Color _bookingStatusColor(String status) {
    switch (status) {
      case 'pending':
        return _kAccent;
      case 'confirmed':
        return _kSecondary;
      case 'active':
        return _kSuccess;
      case 'completed':
        return _kTextSecondary;
      case 'cancelled':
        return _kError;
      default:
        return _kTextSecondary;
    }
  }

  Color _paymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return _kAccent;
      case 'paid':
        return _kSuccess;
      case 'failed':
        return _kError;
      case 'refunded':
        return _kSecondary;
      default:
        return _kTextSecondary;
    }
  }

  String _paymentStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'รอชำระ';
      case 'paid':
        return 'ชำระแล้ว';
      case 'failed':
        return 'ล้มเหลว';
      case 'refunded':
        return 'คืนเงิน';
      default:
        return status;
    }
  }

  String _paymentMethodDisplay(String method) {
    switch (method) {
      case 'promptpay':
        return 'PromptPay';
      case 'bank_transfer':
        return 'โอนเงิน';
      case 'cash':
        return 'เงินสด';
      case 'card':
        return 'บัตรเครดิต';
      default:
        return method;
    }
  }

  IconData _paymentMethodIcon(String method) {
    switch (method) {
      case 'promptpay':
        return Icons.qr_code_rounded;
      case 'bank_transfer':
        return Icons.account_balance_rounded;
      case 'cash':
        return Icons.payments_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _carStatusColor(String status) {
    switch (status) {
      case 'available':
        return _kSuccess;
      case 'rented':
        return _kSecondary;
      case 'maintenance':
        return _kAccent;
      case 'inactive':
        return _kTextSecondary;
      default:
        return _kTextSecondary;
    }
  }

  String _carStatusDisplay(String status) {
    switch (status) {
      case 'available':
        return 'ว่าง';
      case 'rented':
        return 'กำลังเช่า';
      case 'maintenance':
        return 'ซ่อมบำรุง';
      case 'inactive':
        return 'ไม่ใช้งาน';
      default:
        return status;
    }
  }

  IconData _carStatusIcon(String status) {
    switch (status) {
      case 'available':
        return Icons.check_circle_rounded;
      case 'rented':
        return Icons.directions_car_rounded;
      case 'maintenance':
        return Icons.build_rounded;
      case 'inactive':
        return Icons.block_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  String? _nextCarStatus(String current) {
    switch (current) {
      case 'available':
        return 'maintenance';
      case 'rented':
        return 'available';
      case 'maintenance':
        return 'available';
      case 'inactive':
        return 'available';
      default:
        return null;
    }
  }
}