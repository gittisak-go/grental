import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/car_model.dart';
import '../../services/booking_service.dart';
import '../../services/supabase_service.dart';
import '../../routes/app_routes.dart';

/// Booking + Payment screen
/// Flow: confirm details → choose payment method → create booking+payment → upload slip → real-time status
class BookingPaymentScreen extends StatefulWidget {
  const BookingPaymentScreen({super.key});

  @override
  State<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  final BookingService _bookingService = BookingService();
  final ImagePicker _picker = ImagePicker();

  // Args from navigation
  CarModel? _car;
  DateTime? _startDate;
  DateTime? _endDate;
  int _totalDays = 1;
  double _totalAmount = 0;

  // State
  String _selectedMethod = 'promptpay';
  bool _isCreatingBooking = false;
  bool _isUploadingSlip = false;
  bool _bookingCreated = false;
  String? _bookingId;
  String? _paymentId;
  String _bookingStatus = 'pending';
  String _paymentStatus = 'pending';
  String? _slipUrl;
  String _errorMessage = '';

  // Realtime subscriptions
  RealtimeChannel? _bookingChannel;
  RealtimeChannel? _paymentChannel;

  static const Color _kPrimary = Color(0xFFFF2D78);
  static const Color _kSecondary = Color(0xFF2979FF);
  static const Color _kBackground = Color(0xFF0A0A12);
  static const Color _kSurface = Color(0xFF16161E);
  static const Color _kAccent = Color(0xFFFFE500);
  static const Color _kSuccess = Color(0xFF00FFC2);
  static const Color _kError = Color(0xFFFF453A);

  static const String _promptPayNumber = '0963638519';

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'promptpay',
      'icon': Icons.qr_code,
      'label': 'PromptPay',
      'desc': 'สแกน QR โอนเงิน',
    },
    {
      'id': 'bank_transfer',
      'icon': Icons.account_balance,
      'label': 'โอนเงิน',
      'desc': 'โอนผ่านธนาคาร',
    },
    {
      'id': 'cash',
      'icon': Icons.payments_outlined,
      'label': 'เงินสด',
      'desc': 'ชำระเมื่อรับรถ',
    },
    {
      'id': 'card',
      'icon': Icons.credit_card,
      'label': 'บัตรเครดิต/เดบิต',
      'desc': 'ชำระด้วยบัตร',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _car == null) {
      setState(() {
        _car = args['car'] as CarModel?;
        _startDate = args['startDate'] as DateTime?;
        _endDate = args['endDate'] as DateTime?;
        _totalDays = args['totalDays'] as int? ?? 1;
        _totalAmount = (args['totalAmount'] as num?)?.toDouble() ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _bookingChannel?.unsubscribe();
    _paymentChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _createBooking() async {
    final user = SupabaseService.instance.client.auth.currentUser;
    if (user == null) {
      _showSnack('กรุณาเข้าสู่ระบบก่อนจอง', isError: true);
      Navigator.pushNamed(context, AppRoutes.authentication);
      return;
    }

    if (_car == null || _startDate == null || _endDate == null) {
      _showSnack('ข้อมูลไม่ครบถ้วน', isError: true);
      return;
    }

    setState(() {
      _isCreatingBooking = true;
      _errorMessage = '';
    });
    HapticFeedback.mediumImpact();

    try {
      final result = await _bookingService.createBookingWithPayment(
        carId: _car!.id,
        userId: user.id,
        startDate: _startDate!,
        endDate: _endDate!,
        totalAmount: _totalAmount,
        paymentMethod: _selectedMethod,
      );

      final bookingId = result['booking']['id'] as String;
      final paymentId = result['payment']['id'] as String;

      setState(() {
        _bookingId = bookingId;
        _paymentId = paymentId;
        _bookingCreated = true;
        _isCreatingBooking = false;
      });

      HapticFeedback.heavyImpact();
      _subscribeToUpdates(bookingId, paymentId);
    } catch (e) {
      setState(() {
        _isCreatingBooking = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      _showSnack(_errorMessage, isError: true);
    }
  }

  void _subscribeToUpdates(String bookingId, String paymentId) {
    _bookingChannel = _bookingService.subscribeToBooking(
      bookingId: bookingId,
      onUpdate: (data) {
        if (mounted) {
          setState(() =>
              _bookingStatus = data['status'] as String? ?? _bookingStatus);
        }
      },
    );

    _paymentChannel = _bookingService.subscribeToPayment(
      paymentId: paymentId,
      onUpdate: (data) {
        if (mounted) {
          setState(() {
            _paymentStatus = data['status'] as String? ?? _paymentStatus;
            if (data['slip_url'] != null) {
              _slipUrl = data['slip_url'] as String;
            }
          });
          if (_paymentStatus == 'paid') {
            HapticFeedback.heavyImpact();
            _showPaymentConfirmedDialog();
          }
        }
      },
    );
  }

  Future<void> _uploadSlip() async {
    if (_paymentId == null) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;

    setState(() => _isUploadingSlip = true);

    try {
      final client = SupabaseService.instance.client;
      final fileName =
          'slip_${_paymentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      String uploadedUrl;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await client.storage.from('payment-slips').uploadBinary(fileName, bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'));
      } else {
        final file = File(image.path);
        await client.storage.from('payment-slips').upload(
              fileName,
              file,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      }

      uploadedUrl = client.storage.from('payment-slips').getPublicUrl(fileName);

      await _bookingService.uploadSlip(
        paymentId: _paymentId!,
        slipUrl: uploadedUrl,
      );

      setState(() {
        _slipUrl = uploadedUrl;
        _isUploadingSlip = false;
      });

      _showSnack('อัปโหลดสลิปสำเร็จ รอการยืนยันจากแอดมิน');
    } catch (e) {
      setState(() => _isUploadingSlip = false);
      _showSnack(
          'อัปโหลดสลิปไม่สำเร็จ: ${e.toString().replaceFirst('Exception: ', '')}',
          isError: true);
    }
  }

  void _showPaymentConfirmedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '✅ ชำระเงินสำเร็จ!',
          style: GoogleFonts.urbanist(
              color: _kSuccess, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'การชำระเงินของคุณได้รับการยืนยันแล้ว',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.bookingStatusScreen,
                arguments: {'bookingId': _bookingId},
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _kSuccess),
            child: Text('ดูสถานะการจอง',
                style: GoogleFonts.poppins(color: Colors.black)),
          ),
        ],
      ),
    );
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
          _bookingCreated ? 'ชำระเงิน' : 'ยืนยันการจอง',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_car != null) _buildCarSummary(),
            SizedBox(height: 2.h),
            _buildBookingSummary(),
            SizedBox(height: 2.h),
            if (!_bookingCreated) ...[
              _buildPaymentMethodSelector(),
              SizedBox(height: 3.h),
              _buildConfirmButton(),
            ] else ...[
              _buildPaymentInstructions(),
              SizedBox(height: 2.h),
              _buildStatusCard(),
              SizedBox(height: 2.h),
              _buildSlipUploadSection(),
              SizedBox(height: 2.h),
              _buildViewStatusButton(),
            ],
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCarSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _car!.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _car!.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.directions_car,
                          color: Colors.white24,
                          size: 32),
                    ),
                  )
                : const Icon(Icons.directions_car,
                    color: Colors.white24, size: 32),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _car!.displayName,
                  style: GoogleFonts.urbanist(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.3.h),
                Text(
                  _car!.plate,
                  style:
                      GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _car!.formattedRate,
                  style: GoogleFonts.urbanist(
                    color: _kAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    final start = _startDate != null
        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
        : '-';
    final end = _endDate != null
        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
        : '-';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สรุปการจอง',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildSummaryRow('วันรับรถ', start),
          _buildSummaryRow('วันคืนรถ', end),
          _buildSummaryRow('จำนวนวัน', '$_totalDays วัน'),
          const Divider(color: Colors.white12),
          _buildSummaryRow(
            'ยอดรวม',
            '฿${_totalAmount.toStringAsFixed(0)}',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool highlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: highlight ? _kAccent : Colors.white,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              fontSize: highlight ? 16 : 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'วิธีชำระเงิน',
          style: GoogleFonts.urbanist(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 1.5.h),
        ...(_paymentMethods.map((method) {
          final isSelected = _selectedMethod == method['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedMethod = method['id']),
            child: Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.all(3.5.w),
              decoration: BoxDecoration(
                color:
                    isSelected ? _kPrimary.withValues(alpha: 0.15) : _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? _kPrimary
                      : Colors.white.withValues(alpha: 0.08),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    method['icon'] as IconData,
                    color: isSelected ? _kPrimary : Colors.white54,
                    size: 22,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method['label'] as String,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          method['desc'] as String,
                          style: GoogleFonts.poppins(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: _kPrimary, size: 20),
                ],
              ),
            ),
          );
        })),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreatingBooking ? null : _createBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kPrimary,
          disabledBackgroundColor: _kPrimary.withValues(alpha: 0.4),
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isCreatingBooking
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : Text(
                'ยืนยันการจอง',
                style: GoogleFonts.urbanist(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    if (_selectedMethod == 'promptpay') {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kSecondary.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Text(
              '📱 PromptPay',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'เบอร์มือถือ: $_promptPayNumber',
              style: GoogleFonts.poppins(
                color: _kAccent,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'ยอดโอน: ฿${_totalAmount.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                color: _kSuccess,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'โอนเงินแล้วกรุณาแนบสลิปด้านล่าง',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_selectedMethod == 'bank_transfer') {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kSecondary.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🏦 โอนเงินผ่านธนาคาร',
              style: GoogleFonts.urbanist(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'กรุณาโอนเงินและแนบสลิปด้านล่าง\nแอดมินจะยืนยันภายใน 30 นาที',
              style: GoogleFonts.poppins(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_selectedMethod == 'cash') {
      return Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kSuccess.withValues(alpha: 0.4)),
        ),
        child: Text(
          '💵 ชำระเงินสดเมื่อรับรถ\nกรุณาเตรียมเงินสดให้พร้อม',
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        '💳 ชำระด้วยบัตรเครดิต/เดบิต\nแอดมินจะติดต่อกลับเพื่อดำเนินการ',
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color bookingColor;
    switch (_bookingStatus) {
      case 'confirmed':
        bookingColor = _kSuccess;
        break;
      case 'active':
        bookingColor = _kSecondary;
        break;
      case 'completed':
        bookingColor = Colors.white54;
        break;
      case 'cancelled':
        bookingColor = _kError;
        break;
      default:
        bookingColor = _kAccent;
    }

    Color paymentColor;
    switch (_paymentStatus) {
      case 'paid':
        paymentColor = _kSuccess;
        break;
      case 'failed':
        paymentColor = _kError;
        break;
      case 'refunded':
        paymentColor = Colors.orange;
        break;
      default:
        paymentColor = _kAccent;
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สถานะ (อัปเดตแบบ Real-time)',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: _buildStatusChip(
                  'การจอง',
                  _bookingStatusLabel(_bookingStatus),
                  bookingColor,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatusChip(
                  'การชำระเงิน',
                  _paymentStatusLabel(_paymentStatus),
                  paymentColor,
                ),
              ),
            ],
          ),
          if (_bookingId != null)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                'รหัสการจอง: ${_bookingId!.substring(0, 8).toUpperCase()}',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
          ),
          SizedBox(height: 0.3.h),
          Text(
            value,
            style: GoogleFonts.urbanist(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _bookingStatusLabel(String s) {
    switch (s) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'confirmed':
        return 'ยืนยันแล้ว';
      case 'active':
        return 'กำลังใช้งาน';
      case 'completed':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return s;
    }
  }

  String _paymentStatusLabel(String s) {
    switch (s) {
      case 'pending':
        return 'รอชำระ';
      case 'paid':
        return 'ชำระแล้ว';
      case 'failed':
        return 'ล้มเหลว';
      case 'refunded':
        return 'คืนเงินแล้ว';
      default:
        return s;
    }
  }

  Widget _buildSlipUploadSection() {
    if (_selectedMethod == 'cash') return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _slipUrl != null
              ? _kSuccess.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📎 แนบสลิปการโอนเงิน',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 1.h),
          if (_slipUrl != null)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    _slipUrl!,
                    height: 20.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 8.h,
                      color: Colors.white.withValues(alpha: 0.05),
                      child: const Icon(Icons.image, color: Colors.white24),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: _kSuccess, size: 16),
                    SizedBox(width: 2.w),
                    Text(
                      'อัปโหลดสลิปแล้ว รอการยืนยัน',
                      style:
                          GoogleFonts.poppins(color: _kSuccess, fontSize: 12),
                    ),
                  ],
                ),
              ],
            )
          else
            Text(
              'อัปโหลดสลิปหลังโอนเงินเพื่อให้แอดมินยืนยัน',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          SizedBox(height: 1.5.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isUploadingSlip ? null : _uploadSlip,
              icon: _isUploadingSlip
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: _kPrimary, strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file, color: _kPrimary),
              label: Text(
                _isUploadingSlip
                    ? 'กำลังอัปโหลด...'
                    : (_slipUrl != null ? 'เปลี่ยนสลิป' : 'อัปโหลดสลิป'),
                style: GoogleFonts.poppins(
                    color: _kPrimary, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _kPrimary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 1.2.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewStatusButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.bookingStatusScreen,
          arguments: {'bookingId': _bookingId},
        ),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: Text(
          'ดูสถานะการจองทั้งหมด',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kSecondary,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
