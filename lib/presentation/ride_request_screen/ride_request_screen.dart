import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/advanced_options_section.dart';
import './widgets/fare_estimation_widget.dart';
import './widgets/promo_banner_widget.dart';
import './widgets/request_ride_button.dart';
import './widgets/vehicle_selection_carousel.dart';
import './widgets/welcome_header_widget.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final ScrollController _scrollController = ScrollController();

  int _selectedVehicleIndex = 0;
  bool _isLoading = false;
  DateTime? _pickupDate;
  DateTime? _returnDate;
  String _pickupLocation = "สนามบินนานาชาติอุดรธานี";
  String _specialRequest = "";
  String _promoCode = "";
  int _rentalDays = 1;
  bool _showSurgeNotification = false;

  @override
  void initState() {
    super.initState();
    _checkSurgeStatus();
  }

  void _checkSurgeStatus() {
    // Simulate surge pricing check
    final now = DateTime.now();
    final isRushHour =
        (now.hour >= 7 && now.hour <= 9) || (now.hour >= 17 && now.hour <= 19);
    setState(() {
      _showSurgeNotification = isRushHour;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header with gradient
            SliverAppBar(
              expandedHeight: 18.h,
              floating: false,
              pinned: true,
              backgroundColor: theme.colorScheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '🚗 รถเช่าอุดรธานี',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'ไม่ใช้บัตรเครดิต • รับ-ส่งฟรี • รถใหม่สะอาด',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.account_balance, color: Colors.white),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.bankInfoScreen),
                  tooltip: 'ข้อมูลการชำระเงิน',
                ),
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () => _showNotifications(),
                  tooltip: 'แจ้งเตือน',
                ),
              ],
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // HERO SECTION: Vehicle Selection (Most Prominent)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎯 เลือกรถเช่าของคุณ',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'รถใหม่ทุกคัน • เช็คคุณภาพก่อนส่งมอบ • พร้อมใช้งาน',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Enhanced Vehicle Carousel (Bigger, more prominent)
                  VehicleSelectionCarousel(
                    selectedIndex: _selectedVehicleIndex,
                    onVehicleSelected: _onVehicleSelected,
                  ),

                  SizedBox(height: 3.h),

                  // Rental Date Selection
                  _buildRentalDateSection(theme),

                  SizedBox(height: 2.h),

                  // Pickup Location
                  _buildPickupLocationSection(theme),

                  SizedBox(height: 2.h),

                  // Selling Points Banner
                  _buildSellingPointsBanner(theme),

                  SizedBox(height: 2.h),

                  // Contact Card
                  _buildContactCard(theme),

                  SizedBox(height: 2.h),

                  // Promo Banner
                  PromoBannerWidget(
                    title: "🎉 รับส่วนลด 25%",
                    subtitle: "สำหรับการเช่า 7 วันขึ้นไป",
                    promoCode: "RENT25",
                    onTap: () => _applyPromoCode("RENT25"),
                  ),

                  SizedBox(height: 2.h),

                  // Additional Options
                  _buildAdditionalOptionsSection(theme),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pricing Summary
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ค่าเช่า $_rentalDays วัน',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _calculateTotalPrice(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (_rentalDays >= 7)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer,
                              size: 14, color: Colors.green),
                          SizedBox(width: 1.w),
                          Text(
                            'ประหยัด 25% สำหรับการเช่า 7 วันขึ้นไป',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SafeArea(
            child: RequestRideButton(
              onPressed: _canBookRental() ? _bookRental : null,
              isLoading: _isLoading,
              isEnabled: _canBookRental(),
              buttonText: 'จองรถเช่า',
            ),
          ),
          CustomBottomBar(
            variant: CustomBottomBarVariant.standard,
            currentIndex: 0,
            onTap: (index) {
              HapticFeedback.lightImpact();
              switch (index) {
                case 0:
                  break;
                case 1:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/admin-reservations-screen',
                    (route) => false,
                  );
                  break;
                case 2:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/fleet-inventory-screen',
                    (route) => false,
                  );
                  break;
                case 3:
                  Navigator.pushNamed(context, '/user-profile-screen');
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRentalDateSection(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'วันที่เช่า',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  theme,
                  'รับรถ',
                  _pickupDate,
                  () => _selectPickupDate(),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildDateButton(
                  theme,
                  'คืนรถ',
                  _returnDate,
                  () => _selectReturnDate(),
                ),
              ),
            ],
          ),
          if (_pickupDate != null && _returnDate != null)
            Padding(
              padding: EdgeInsets.only(top: 1.5.h),
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'ระยะเวลาเช่า: $_rentalDays วัน',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
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

  Widget _buildDateButton(
    ThemeData theme,
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: date != null
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: date != null
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : 'เลือกวันที่',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: date != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupLocationSection(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.location_on,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สถานที่รับรถ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  _pickupLocation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, size: 20),
            onPressed: () => _changePickupLocation(),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptionsSection(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ตัวเลือกเพิ่มเติม',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.5.h),
          TextField(
            decoration: InputDecoration(
              labelText: 'ความต้องการพิเศษ (ถ้ามี)',
              hintText: 'เช่น ต้องการเบาะเด็ก, GPS เพิ่มเติม',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.note_add),
            ),
            maxLines: 3,
            onChanged: (value) => _specialRequest = value,
          ),
        ],
      ),
    );
  }

  Widget _buildSellingPointsBanner(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✨ จุดเด่นของเรา',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildSellingPoint(
            theme,
            '🎯',
            'รถเช่าอุดรไม่ใช้บัตรเครดิต',
            'เงื่อนไขง่ายที่สุด ไม่ต้องมีบัตรเครดิตก็เช่าได้',
          ),
          SizedBox(height: 1.h),
          _buildSellingPoint(
            theme,
            '🚗',
            'รับ-ส่งฟรีถึงมือ',
            'ทั้งสนามบินอุดรธานี และในตัวเมือง สะดวกสบาย ไม่ต้องรอนาน',
          ),
          SizedBox(height: 1.h),
          _buildSellingPoint(
            theme,
            '✅',
            'รถใหม่ สะอาด มั่นใจ',
            'ตรวจเช็คก่อนส่งมอบทุกคัน แอร์เย็นฉ่ำสู้แดดวันหยุด',
          ),
          SizedBox(height: 1.h),
          _buildSellingPoint(
            theme,
            '💝',
            'บริการด้วยใจ',
            'แอดมินใจดี คุยง่าย พร้อมให้คำแนะนำ',
          ),
        ],
      ),
    );
  }

  Widget _buildSellingPoint(
    ThemeData theme,
    String emoji,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 20.sp),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'phone',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'ติดต่อจองรถ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _buildContactRow(theme, 'phone', 'สายด่วน', '086-634-8619'),
          SizedBox(height: 1.h),
          _buildContactRow(theme, 'phone', 'สายด่วน 2', '096-363-8519'),
          SizedBox(height: 1.h),
          _buildContactRow(theme, 'chat', 'Line ID', '@rungroj'),
          SizedBox(height: 1.5.h),
          Divider(height: 1),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.primary,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สถานที่รับรถ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'รถเช่าอุดรธานี รุ่งโรจน์คาร์เร้นท์\n79QPF+QQM Chiang Phin, Mueang Udon Thani\nUdon Thani 41000',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'เปิดให้บริการ 24 ชั่วโมง',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    ThemeData theme,
    String iconName,
    String label,
    String value,
  ) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: theme.colorScheme.onSurfaceVariant,
          size: 18,
        ),
        SizedBox(width: 2.w),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _onVehicleSelected(int index) {
    setState(() {
      _selectedVehicleIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _selectPickupDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickupDate ?? now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _pickupDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
        _calculateRentalDays();
      });
    }
  }

  Future<void> _selectReturnDate() async {
    if (_pickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเลือกวันรับรถก่อน'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? _pickupDate!.add(Duration(days: 1)),
      firstDate: _pickupDate!.add(Duration(days: 1)),
      lastDate: _pickupDate!.add(Duration(days: 90)),
    );

    if (picked != null) {
      setState(() {
        _returnDate = picked;
        _calculateRentalDays();
      });
    }
  }

  void _calculateRentalDays() {
    if (_pickupDate != null && _returnDate != null) {
      setState(() {
        _rentalDays = _returnDate!.difference(_pickupDate!).inDays;
      });
    }
  }

  String _calculateTotalPrice() {
    final dailyRate = 800; // Base daily rate
    int total = dailyRate * _rentalDays;

    // Apply discount for weekly rentals
    if (_rentalDays >= 7) {
      total = (total * 0.75).round();
    }

    return '฿${total.toString()}';
  }

  bool _canBookRental() {
    return _pickupDate != null && _returnDate != null && _rentalDays > 0;
  }

  void _changePickupLocation() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.flight),
              title: Text('สนามบินนานาชาติอุดรธานี'),
              onTap: () {
                setState(() => _pickupLocation = 'สนามบินนานาชาติอุดรธานี');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.location_city),
              title: Text('สำนักงานในเมือง'),
              onTap: () {
                setState(() => _pickupLocation =
                    'สำนักงานในเมือง - 79QPF+QQM Chiang Phin');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _bookRental() async {
    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    await _openMessenger();

    setState(() => _isLoading = false);
  }

  void _showFareBredownModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFareBreakdownModal(),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Need Help?'),
        content: Text(
          'Contact our support team for assistance with your ride booking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle contact support
            },
            child: Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    _checkSurgeStatus();
    setState(() {});
  }

  void _requestRide() async {
    setState(() {
      _isLoading = true;
    });

    // Provide haptic feedback
    HapticFeedback.mediumImpact();

    // Open Facebook Messenger to Rungroj Car Rental
    await _openMessenger();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openMessenger() async {
    final messengerUrl = Uri.parse('https://m.me/RungrojCarRental');

    try {
      if (await canLaunchUrl(messengerUrl)) {
        await launchUrl(
          messengerUrl,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'ไม่สามารถเปิด Messenger ได้ กรุณาติดต่อโดยตรงที่ 086-634-8619'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด กรุณาติดต่อที่ 086-634-8619'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _applyPromoCode(String code) {
    setState(() {
      _promoCode = code;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('โค้ดโปรโมชั่น "$code" ถูกใช้แล้ว!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNotificationsModal(),
    );
  }

  Widget _buildNotificationsModal() {
    final theme = Theme.of(context);

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'ไม่มีการแจ้งเตือนใหม่',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetailsModal(Map<String, dynamic> vehicle) {
    final theme = Theme.of(context);

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle["type"] as String,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    vehicle["description"] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'คุณสมบัติ',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...(vehicle["features"] as List<String>).map(
                    (feature) => Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            feature,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildFareBreakdownModal() {
    final theme = Theme.of(context);
    
    final dailyRate = 800;
    int total = dailyRate * _rentalDays;
    if (_rentalDays >= 7) {
      total = (total * 0.75).round();
    }
    final baseFare = '฿${dailyRate.toString()}';
    final estimatedTotal = '฿${total.toString()}';

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายละเอียดค่าโดยสาร',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  FareEstimationWidget(
                    baseFare: baseFare,
                    estimatedTotal: estimatedTotal,
                    showSurgeNotification: _showSurgeNotification,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}