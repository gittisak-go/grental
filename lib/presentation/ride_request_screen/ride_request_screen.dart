import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

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

  String _pickupLocation = "Times Square, New York, NY";
  String _destinationLocation = "";
  int _selectedVehicleIndex = 0;
  bool _isAdvancedOptionsExpanded = false;
  bool _isLoading = false;
  bool _showSurgeNotification = false;
  DateTime? _scheduledTime;
  String _specialRequest = "";
  String _promoCode = "";

  final List<String> _recentDestinations = [
    "Central Park, New York, NY",
    "Brooklyn Bridge, New York, NY",
    "Empire State Building, New York, NY",
    "Statue of Liberty, New York, NY",
    "One World Trade Center, New York, NY",
  ];

  final List<Map<String, String>> _quickActions = [
    {
      "title": "Work",
      "address": "350 5th Ave, New York",
      "icon": "work_outline"
    },
    {"title": "Home", "address": "Times Square", "icon": "home_outlined"},
    {
      "title": "Airport",
      "address": "JFK International",
      "icon": "local_airport"
    },
    {"title": "Gym", "address": "Central Park West", "icon": "fitness_center"},
  ];

  final List<Map<String, dynamic>> _vehicleData = [
    {
      "type": "TaxiHouse Standard",
      "baseFare": "\$3.50",
      "estimatedTotal": "\$12.50",
    },
    {
      "type": "TaxiHouse Premium",
      "baseFare": "\$5.25",
      "estimatedTotal": "\$18.75",
    },
    {
      "type": "TaxiHouse XL",
      "baseFare": "\$6.50",
      "estimatedTotal": "\$22.00",
    },
    {
      "type": "TaxiHouse Eco",
      "baseFare": "\$2.75",
      "estimatedTotal": "\$10.25",
    },
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App bar with gradient
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
                    child: WelcomeHeaderWidget(
                      userName: "John",
                      onNotificationTap: () => _showNotifications(),
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
                  // Promo banner
                  PromoBannerWidget(
                    title: "🎉 Get 25% OFF",
                    subtitle: "On your next 3 rides",
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
                                  _quickActions[index]["address"]!),
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
              buttonText:
                  _scheduledTime != null ? 'Schedule Ride' : 'Request Ride',
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
            'Contact our support team for assistance with your ride booking.'),
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

    // Simulate ride request processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Navigate to live tracking screen with ride details
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.liveTracking,
        arguments: {
          'pickup': _pickupLocation,
          'destination': _destinationLocation,
          'vehicleType': _vehicleData[_selectedVehicleIndex]["type"],
          'estimatedFare': _vehicleData[_selectedVehicleIndex]
              ["estimatedTotal"],
          'scheduledTime': _scheduledTime,
          'specialRequest': _specialRequest,
          'promoCode': _promoCode,
        },
      );
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
        content: Text('Promo code "$code" applied!'),
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
                  'No new notifications',
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
          // Handle bar
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
          // Vehicle details content
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
                  // Features list
                  Text(
                    'Features',
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
          // Handle bar
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
          // Fare breakdown content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fare Breakdown',
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
