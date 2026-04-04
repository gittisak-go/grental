import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/booking_payment_model.dart';
import '../../services/booking_service.dart';
import '../../services/supabase_service.dart';
import '../../routes/app_routes.dart';

/// Booking status screen — shows user's bookings with real-time payment status
class BookingStatusScreen extends StatefulWidget {
  const BookingStatusScreen({super.key});

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen> {
  final BookingService _bookingService = BookingService();

  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _highlightBookingId;

  // Realtime channels per booking
  final Map<String, RealtimeChannel> _channels = {};

  static const Color _kPrimary = Color(0xFFFF2D78);
  static const Color _kBackground = Color(0xFF0A0A12);
  static const Color _kSurface = Color(0xFF16161E);
  static const Color _kAccent = Color(0xFFFFE500);
  static const Color _kSuccess = Color(0xFF00FFC2);
  static const Color _kError = Color(0xFFFF453A);
  static const Color _kSecondary = Color(0xFF2979FF);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _highlightBookingId = args?['bookingId'] as String?;
  }

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void dispose() {
    for (final ch in _channels.values) {
      ch.unsubscribe();
    }
    super.dispose();
  }

  Future<void> _loadBookings() async {
    final user = SupabaseService.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'กรุณาเข้าสู่ระบบ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final bookings = await _bookingService.getUserBookings(user.id);
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
      _subscribeToAll(bookings);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _subscribeToAll(List<BookingModel> bookings) {
    for (final booking in bookings) {
      if (booking.id == null) continue;
      final ch = _bookingService.subscribeToBooking(
        bookingId: booking.id!,
        onUpdate: (data) {
          if (!mounted) return;
          setState(() {
            final idx = _bookings.indexWhere((b) => b.id == booking.id);
            if (idx >= 0) {
              _bookings[idx] = BookingModel.fromJson({
                ..._bookings[idx].toInsertJson(),
                'id': booking.id,
                'status': data['status'] ?? _bookings[idx].status,
                'cars': _bookings[idx].car,
                'payments': _bookings[idx].payments,
              });
            }
          });
        },
      );
      _channels[booking.id!] = ch;
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('ยืนยันการยกเลิก',
            style: GoogleFonts.urbanist(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('คุณต้องการยกเลิกการจองนี้ใช่หรือไม่?',
            style: GoogleFonts.poppins(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('ไม่', style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _kError),
            child: Text('ยกเลิกการจอง',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _bookingService.cancelBooking(bookingId);
        _loadBookings();
        _showSnack('ยกเลิกการจองสำเร็จ');
      } catch (e) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
      backgroundColor: isError ? _kError : _kSuccess,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        title: Text(
          'สถานะการจอง',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.rideRequest,
            (route) => false,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final user = SupabaseService.instance.client.auth.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white38, size: 64),
            SizedBox(height: 2.h),
            Text('กรุณาเข้าสู่ระบบ',
                style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.authentication),
              style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
              child: Text('เข้าสู่ระบบ',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _kPrimary));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: _kError, size: 48),
            SizedBox(height: 2.h),
            Text(_errorMessage,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadBookings,
              style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      );
    }

    if (_bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.car_rental, color: Colors.white24, size: 64),
            SizedBox(height: 2.h),
            Text('ยังไม่มีการจอง',
                style: GoogleFonts.urbanist(
                    color: Colors.white60,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.carSelectionScreen),
              style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
              child: Text('จองรถเลย',
                  style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: _kPrimary,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _bookings.length,
        itemBuilder: (context, index) => _buildBookingCard(_bookings[index]),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final isHighlighted = booking.id == _highlightBookingId;
    final car = booking.car;
    final payments = booking.payments ?? [];

    Color statusColor;
    switch (booking.status) {
      case 'confirmed':
        statusColor = _kSuccess;
        break;
      case 'active':
        statusColor = _kSecondary;
        break;
      case 'completed':
        statusColor = Colors.white38;
        break;
      case 'cancelled':
        statusColor = _kError;
        break;
      default:
        statusColor = _kAccent;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isHighlighted ? _kPrimary : Colors.white.withValues(alpha: 0.08),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.id != null
                      ? 'จอง #${booking.id!.substring(0, 8).toUpperCase()}'
                      : 'การจอง',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    booking.statusDisplay,
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car info
                if (car != null)
                  Text(
                    '${car['brand'] ?? ''} ${car['model'] ?? ''} (${car['year'] ?? ''})',
                    style: GoogleFonts.urbanist(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                SizedBox(height: 1.h),

                // Dates
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white38, size: 14),
                    SizedBox(width: 1.5.w),
                    Text(
                      '${_formatDate(booking.startDate)} → ${_formatDate(booking.endDate)}',
                      style: GoogleFonts.poppins(
                          color: Colors.white60, fontSize: 12),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '(${booking.rentalDays} วัน)',
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),

                SizedBox(height: 0.8.h),

                // Amount
                Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: Colors.white38, size: 14),
                    SizedBox(width: 1.5.w),
                    Text(
                      '฿${booking.totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.urbanist(
                        color: _kAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Payments
                if (payments.isNotEmpty) ...[
                  SizedBox(height: 1.5.h),
                  const Divider(color: Colors.white12),
                  SizedBox(height: 1.h),
                  ...payments.map((p) => _buildPaymentRow(p)),
                ],

                // Actions
                if (booking.status == 'pending') ...[
                  SizedBox(height: 1.5.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.bookingPaymentScreen,
                            arguments: {
                              'bookingId': booking.id,
                              'paymentId': payments.isNotEmpty
                                  ? payments.first['id']
                                  : null,
                            },
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _kPrimary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('ชำระเงิน',
                              style: GoogleFonts.poppins(
                                  color: _kPrimary, fontSize: 12)),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: booking.id != null
                              ? () => _cancelBooking(booking.id!)
                              : null,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _kError),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('ยกเลิก',
                              style: GoogleFonts.poppins(
                                  color: _kError, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(Map<String, dynamic> payment) {
    final status = payment['status'] as String? ?? 'pending';
    Color color;
    switch (status) {
      case 'paid':
        color = _kSuccess;
        break;
      case 'failed':
        color = _kError;
        break;
      default:
        color = _kAccent;
    }

    final method = payment['method'] as String? ?? '';
    String methodLabel;
    switch (method) {
      case 'promptpay':
        methodLabel = 'PromptPay';
        break;
      case 'bank_transfer':
        methodLabel = 'โอนเงิน';
        break;
      case 'cash':
        methodLabel = 'เงินสด';
        break;
      case 'card':
        methodLabel = 'บัตร';
        break;
      default:
        methodLabel = method;
    }

    String statusLabel;
    switch (status) {
      case 'paid':
        statusLabel = 'ชำระแล้ว';
        break;
      case 'failed':
        statusLabel = 'ล้มเหลว';
        break;
      case 'refunded':
        statusLabel = 'คืนเงินแล้ว';
        break;
      default:
        statusLabel = 'รอชำระ';
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_outlined,
                  color: Colors.white38, size: 14),
              SizedBox(width: 1.5.w),
              Text(
                '$methodLabel • ฿${(payment['amount'] as num?)?.toStringAsFixed(0) ?? '0'}',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

extension on BookingModel {
  Map<String, dynamic> toInsertJson() => {
        'car_id': carId,
        'user_id': userId,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'total_amount': totalAmount,
        'status': status,
      };
}
