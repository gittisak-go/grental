import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/advanced_options_section.dart';
import './widgets/destination_search_bar.dart';
import './widgets/fare_estimation_widget.dart';
import './widgets/map_preview_widget.dart';
import './widgets/pickup_location_chip.dart';
import './widgets/promo_banner_widget.dart';
import './widgets/quick_action_card_widget.dart';
import './widgets/request_ride_button.dart';
import './widgets/vehicle_selection_carousel.dart';
import './widgets/welcome_header_widget.dart';

class RideRequestScreen extends StatefulWidget {
  const RideRequestScreen({super.key});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _pickupLocation = "สนามบินนานาชาติอุดรธานี, จังหวัดอุดรธานี 41000";
  String _destinationLocation = "";
  int _selectedVehicleIndex = 0;
  bool _isAdvancedOptionsExpanded = false;
  bool _isLoading = false;
  bool _showSurgeNotification = false;
  DateTime? _scheduledTime;
  String _specialRequest = "";
  String _promoCode = "";

  final List<String> _recentDestinations = [
    "ศูนย์การค้าเซ็นทรัลพลาซ่า อุดรธานี",
    "โรงแรมเซ็นทารา อุดรธานี",
    "ตลาดกลางเวียง อุดรธานี",
    "มหาวิทยาลัยอุดรธานี",
    "หาดหนองประจักษ์ อุดรธานี",
  ];

  final List<Map<String, String>> _quickActions = [
    {
      "title": "Work",
      "address": "79QPF+QQM Chiang Phin, อุดรธานี",
      "icon": "work_outline",
    },
    {"title": "Home", "address": "สนามบินอุดรธานี", "icon": "home_outlined"},
    {
      "title": "Airport",
      "address": "สนามบินนานาชาติอุดรธานี",
      "icon": "local_airport",
    },
    {"title": "Gym", "address": "ศูนย์กีฬาอุดรธานี", "icon": "fitness_center"},
  ];

  final List<Map<String, dynamic>> _vehicleData = [
    {
      "type": "TaxiHouse Standard",
      "baseFare": "฿120",
      "estimatedTotal": "฿450",
    },
    {"type": "TaxiHouse Premium", "baseFare": "฿180", "estimatedTotal": "฿680"},
    {"type": "TaxiHouse XL", "baseFare": "฿220", "estimatedTotal": "฿800"},
    {"type": "TaxiHouse Eco", "baseFare": "฿95", "estimatedTotal": "฿370"},
  ];

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
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          '🚗 รถเช่าอุดรธานี ไม่ใช้บัตรเครดิต',
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.bankInfoScreen);
            },
            tooltip: 'ข้อมูลการชำระเงิน',
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
            tooltip: 'แจ้งเตือน',
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App bar with gradient
            SliverAppBar(
              expandedHeight: 25.h,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WelcomeHeaderWidget(
                          userName: "รุ่งโรจน์คาร์เร้นท์",
                          onNotificationTap: () => _showNotifications(),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🚗 รถเช่าอุดรธานี ไม่ใช้บัตรเครดิต',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'รับ-ส่งฟรีถึงมือ • รถใหม่สะอาด • บริการด้วยใจ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              systemOverlayStyle: SystemUiOverlayStyle.light,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  // Selling points banner
                  _buildSellingPointsBanner(theme),
                  SizedBox(height: 2.h),
                  // Contact information card
                  _buildContactCard(theme),
                  SizedBox(height: 2.h),
                  // Promo banner
                  PromoBannerWidget(
                    title: "🎉 รับส่วนลด 25%",
                    subtitle: "สำหรับการเดินทาง 3 ครั้งถัดไป",
                    promoCode: "RIDE25",
                    onTap: () => _applyPromoCode("RIDE25"),
                  ),
                  SizedBox(height: 2.h),
                  // Quick actions
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Access',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: _quickActions.length,
                          itemBuilder: (context, index) {
                            return QuickActionCardWidget(
                              title: _quickActions[index]["title"]!,
                              address: _quickActions[index]["address"]!,
                              iconName: _quickActions[index]["icon"]!,
                              onTap: () => _selectQuickDestination(
                                _quickActions[index]["address"]!,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Divider
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                  SizedBox(height: 2.h),
                  // Pickup location chip
                  PickupLocationChip(
                    location: _pickupLocation,
                    onEdit: () => _editPickupLocation(),
                    onDismiss: () => _dismissPickupLocation(),
                  ),
                  SizedBox(height: 2.h),
                  // Destination search bar
                  DestinationSearchBar(
                    controller: _destinationController,
                    onChanged: _onDestinationChanged,
                    onTap: () => _onDestinationTap(),
                    recentDestinations: _recentDestinations,
                    onDestinationSelected: _onDestinationSelected,
                  ),
                  SizedBox(height: 2.h),
                  // Map preview
                  MapPreviewWidget(
                    pickupLocation: _pickupLocation,
                    destinationLocation: _destinationLocation,
                    onMapTap: () => _openFullScreenMap(),
                  ),
                  SizedBox(height: 2.h),
                  // Vehicle selection carousel
                  VehicleSelectionCarousel(
                    selectedIndex: _selectedVehicleIndex,
                    onVehicleSelected: _onVehicleSelected,
                    onVehicleLongPress: _showVehicleDetails,
                  ),
                  SizedBox(height: 2.h),
                  // Fare estimation
                  if (_destinationLocation.isNotEmpty)
                    FareEstimationWidget(
                      baseFare: _vehicleData[_selectedVehicleIndex]["baseFare"]
                          as String,
                      estimatedTotal: _vehicleData[_selectedVehicleIndex]
                          ["estimatedTotal"] as String,
                      onInfoTap: () => _showFareBredownModal(),
                      showSurgeNotification: _showSurgeNotification,
                    ),
                  SizedBox(height: 2.h),
                  // Advanced options
                  AdvancedOptionsSection(
                    isExpanded: _isAdvancedOptionsExpanded,
                    onToggle: () => _toggleAdvancedOptions(),
                    onScheduleChanged: _onScheduleChanged,
                    onSpecialRequestChanged: _onSpecialRequestChanged,
                    onPromoCodeChanged: _onPromoCodeChanged,
                  ),
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
          SafeArea(
            child: RequestRideButton(
              onPressed: _destinationLocation.isNotEmpty ? _requestRide : null,
              isLoading: _isLoading,
              isEnabled: _destinationLocation.isNotEmpty,
              buttonText: _scheduledTime != null ? 'จองการเดินทาง' : 'เรียกรถ',
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
                    '/live-tracking-screen',
                    (route) => false,
                  );
                  break;
                case 2:
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/ride-history-screen',
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

  void _onDestinationChanged(String value) {
    setState(() {
      _destinationLocation = value;
    });
  }

  void _onDestinationTap() {
    // Handle destination search tap
    HapticFeedback.selectionClick();
  }

  void _onDestinationSelected(String destination) {
    setState(() {
      _destinationLocation = destination;
    });
    HapticFeedback.selectionClick();
  }

  void _onVehicleSelected(int index) {
    setState(() {
      _selectedVehicleIndex = index;
    });
    HapticFeedback.selectionClick();
  }

  void _showVehicleDetails(Map<String, dynamic> vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVehicleDetailsModal(vehicle),
    );
  }

  void _toggleAdvancedOptions() {
    setState(() {
      _isAdvancedOptionsExpanded = !_isAdvancedOptionsExpanded;
    });
    HapticFeedback.selectionClick();
  }

  void _onScheduleChanged(DateTime? scheduledTime) {
    setState(() {
      _scheduledTime = scheduledTime;
    });
  }

  void _onSpecialRequestChanged(String request) {
    _specialRequest = request;
  }

  void _onPromoCodeChanged(String promoCode) {
    _promoCode = promoCode;
  }

  void _editPickupLocation() {
    Navigator.pushNamed(context, '/location-detection-screen');
  }

  void _dismissPickupLocation() {
    // Handle pickup location dismissal
    HapticFeedback.lightImpact();
  }

  void _openFullScreenMap() {
    // Navigate to full screen map view
    Navigator.pushNamed(context, '/live-tracking-screen');
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

  void _selectQuickDestination(String destination) {
    setState(() {
      _destinationLocation = destination;
      _destinationController.text = destination;
    });
    HapticFeedback.selectionClick();
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
                    baseFare: _vehicleData[_selectedVehicleIndex]["baseFare"]
                        as String,
                    estimatedTotal: _vehicleData[_selectedVehicleIndex]
                        ["estimatedTotal"] as String,
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
    _destinationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
