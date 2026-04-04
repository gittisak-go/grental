import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/car_model.dart';
import '../../services/booking_service.dart';
import '../../routes/app_routes.dart';

/// Car selection screen — shows available cars, date picker, availability check
class CarSelectionScreen extends StatefulWidget {
  const CarSelectionScreen({super.key});

  @override
  State<CarSelectionScreen> createState() => _CarSelectionScreenState();
}

class _CarSelectionScreenState extends State<CarSelectionScreen> {
  final BookingService _bookingService = BookingService();

  List<CarModel> _cars = [];
  bool _isLoading = true;
  String _errorMessage = '';

  DateTime? _startDate;
  DateTime? _endDate;
  String _checkingCarId = '';

  static const Color _kPrimary = Color(0xFFFF2D78);
  static const Color _kBackground = Color(0xFF0A0A12);
  static const Color _kSurface = Color(0xFF16161E);
  static const Color _kAccent = Color(0xFFFFE500);
  static const Color _kSuccess = Color(0xFF00FFC2);
  static const Color _kError = Color(0xFFFF453A);

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final cars = await _bookingService.getAvailableCars();
      setState(() {
        _cars = cars;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate?.add(const Duration(days: 1)) ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: _startDate?.add(const Duration(days: 1)) ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: _kPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _selectCar(CarModel car) async {
    if (_startDate == null || _endDate == null) {
      _showSnack('กรุณาเลือกวันรับและวันคืนรถก่อน', isError: true);
      return;
    }

    setState(() => _checkingCarId = car.id);
    HapticFeedback.lightImpact();

    try {
      final available = await _bookingService.checkCarAvailability(
        carId: car.id,
        startDate: _startDate!,
        endDate: _endDate!,
      );

      if (!mounted) return;
      setState(() => _checkingCarId = '');

      if (!available) {
        _showSnack('รถคันนี้ไม่ว่างในช่วงวันที่เลือก กรุณาเลือกวันอื่น',
            isError: true);
        return;
      }

      final days = _endDate!.difference(_startDate!).inDays + 1;
      final total = car.dailyRate * days;

      Navigator.pushNamed(
        context,
        AppRoutes.bookingPaymentScreen,
        arguments: {
          'car': car,
          'startDate': _startDate,
          'endDate': _endDate,
          'totalDays': days,
          'totalAmount': total,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _checkingCarId = '');
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
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

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        title: Text(
          'เลือกรถเช่า',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadCars,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(child: _buildCarList()),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kPrimary.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📅 เลือกวันที่เช่า',
            style: GoogleFonts.urbanist(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'รับรถ',
                  date: _startDate,
                  onTap: _selectStartDate,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildDateButton(
                  label: 'คืนรถ',
                  date: _endDate,
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),
          if (_rentalDays > 0)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: _kPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: _kPrimary, size: 16),
                    SizedBox(width: 2.w),
                    Text(
                      'ระยะเวลา: $_rentalDays วัน',
                      style: GoogleFonts.poppins(
                        color: _kPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: date != null
              ? _kPrimary.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                date != null ? _kPrimary : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.4.h),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'เลือกวันที่',
              style: GoogleFonts.poppins(
                color: date != null ? _kPrimary : Colors.white54,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _kPrimary),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: _kError, size: 48),
            SizedBox(height: 2.h),
            Text(
              _errorMessage,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadCars,
              style: ElevatedButton.styleFrom(backgroundColor: _kPrimary),
              child: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      );
    }

    if (_cars.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined,
                color: Colors.white38, size: 64),
            SizedBox(height: 2.h),
            Text(
              'ไม่มีรถว่างในขณะนี้',
              style: GoogleFonts.urbanist(
                color: Colors.white60,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCars,
      color: _kPrimary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        itemCount: _cars.length,
        itemBuilder: (context, index) => _buildCarCard(_cars[index]),
      ),
    );
  }

  Widget _buildCarCard(CarModel car) {
    final isChecking = _checkingCarId == car.id;
    final days = _rentalDays > 0 ? _rentalDays : 1;
    final estimatedTotal = car.dailyRate * days;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: car.imageUrls.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: car.imageUrls.first,
                    height: 18.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _buildCarPlaceholder(),
                  )
                : _buildCarPlaceholder(),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        car.displayName,
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.4.h),
                      decoration: BoxDecoration(
                        color: _kSuccess.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ว่าง',
                        style: GoogleFonts.poppins(
                          color: _kSuccess,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        color: Colors.white38, size: 14),
                    SizedBox(width: 1.w),
                    Text(
                      car.plate,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    if (car.location != null) ...[
                      SizedBox(width: 3.w),
                      const Icon(Icons.location_on_outlined,
                          color: Colors.white38, size: 14),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          car.location!,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 1.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car.formattedRate,
                          style: GoogleFonts.urbanist(
                            color: _kAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        if (_rentalDays > 0)
                          Text(
                            'รวม $_rentalDays วัน: ฿${estimatedTotal.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      width: 35.w,
                      child: ElevatedButton(
                        onPressed: isChecking ? null : () => _selectCar(car),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _kPrimary.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 1.2.h),
                        ),
                        child: isChecking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'เลือกรถนี้',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
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
  }

  Widget _buildCarPlaceholder() {
    return Container(
      height: 18.h,
      width: double.infinity,
      color: Colors.white.withValues(alpha: 0.05),
      child: const Icon(Icons.directions_car, color: Colors.white24, size: 64),
    );
  }
}
