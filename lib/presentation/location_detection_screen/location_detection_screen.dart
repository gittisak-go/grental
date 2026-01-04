import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/dummy_map_widget.dart';
import './widgets/address_bottom_sheet.dart';
import './widgets/favorites_modal.dart';
import './widgets/gps_accuracy_indicator.dart';
import './widgets/location_pin_widget.dart';

/// Location Detection Screen for automatic pickup location identification
/// with manual refinement through intuitive map interactions
class LocationDetectionScreen extends StatefulWidget {
  const LocationDetectionScreen({super.key});

  @override
  State<LocationDetectionScreen> createState() =>
      _LocationDetectionScreenState();
}

class _LocationDetectionScreenState extends State<LocationDetectionScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _mapAnimationController;
  late AnimationController _loadingController;
  late Animation<double> _mapFadeAnimation;
  late Animation<double> _loadingAnimation;

  // Map controller
  DummyMapController? _mapController;

  // Location state
  Position? _currentPosition;
  String _detectedAddress = '';
  bool _isLoadingLocation = true;
  bool _isLocationPermissionGranted = false;
  double _gpsAccuracy = 0.0;
  bool _isGpsEnabled = false;

  // UI state
  bool _isDarkMode = false;
  int _currentBottomNavIndex = 0;

  // Mock data for recent and favorite locations
  final List<Map<String, dynamic>> _recentLocations = [
    {
      'name': 'Home',
      'address': '123 Oak Street, Downtown District, New York, NY 10001',
      'type': 'home',
      'latitude': 40.7128,
      'longitude': -74.0060,
    },
    {
      'name': 'Office',
      'address': '456 Business Ave, Financial District, New York, NY 10005',
      'type': 'work',
      'latitude': 40.7074,
      'longitude': -74.0113,
    },
    {
      'name': 'Central Park Mall',
      'address': '789 Shopping Blvd, Midtown, New York, NY 10019',
      'type': 'shopping',
      'latitude': 40.7589,
      'longitude': -73.9851,
    },
  ];

  final List<Map<String, dynamic>> _favoriteLocations = [
    {
      'name': 'Home Sweet Home',
      'address': '123 Oak Street, Downtown District, New York, NY 10001',
      'type': 'home',
      'latitude': 40.7128,
      'longitude': -74.0060,
    },
    {
      'name': 'TechCorp Office',
      'address': '456 Business Ave, Financial District, New York, NY 10005',
      'type': 'work',
      'latitude': 40.7074,
      'longitude': -74.0113,
    },
    {
      'name': 'FitLife Gym',
      'address': '321 Fitness St, Health District, New York, NY 10003',
      'type': 'gym',
      'latitude': 40.7282,
      'longitude': -73.9942,
    },
    {
      'name': 'Bella Vista Restaurant',
      'address': '654 Culinary Lane, Food District, New York, NY 10014',
      'type': 'restaurant',
      'latitude': 40.7353,
      'longitude': -74.0037,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocation();
  }

  void _initializeAnimations() {
    _mapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _mapFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mapAnimationController,
      curve: Curves.easeInOut,
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _loadingController.repeat(reverse: true);
  }

  Future<void> _initializeLocation() async {
    try {
      // Check and request location permissions
      final permissionStatus = await _requestLocationPermission();
      if (!permissionStatus) {
        setState(() {
          _isLoadingLocation = false;
          _detectedAddress = 'Location permission denied';
        });
        return;
      }

      // Check if GPS is enabled
      final isGpsEnabled = await Geolocator.isLocationServiceEnabled();
      setState(() {
        _isGpsEnabled = isGpsEnabled;
      });

      if (!isGpsEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _detectedAddress =
              'GPS is disabled. Please enable location services.';
        });
        return;
      }

      // Get current position
      await _getCurrentLocation();

      // Start map animation after location is loaded
      _mapAnimationController.forward();
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _detectedAddress = 'Unable to detect location. Please try again.';
      });
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Show dialog to open app settings
      _showPermissionDialog();
      return false;
    }

    final isGranted = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;

    setState(() {
      _isLocationPermissionGranted = isGranted;
    });

    return isGranted;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentPosition = position;
        _gpsAccuracy = position.accuracy;
        _isLoadingLocation = false;
      });

      // Animate map to current position
      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0,
          ),
        );
      }

      // Simulate address lookup (in real app, use geocoding)
      await _performAddressLookup(position);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _detectedAddress = 'Unable to get precise location';
      });
    }
  }

  Future<void> _performAddressLookup(Position position) async {
    // Simulate network delay for address lookup
    await Future.delayed(const Duration(seconds: 1));

    // Mock address based on coordinates (in real app, use reverse geocoding)
    setState(() {
      _detectedAddress =
          '142 West 57th Street, Midtown Manhattan, New York, NY 10019, United States';
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'This app needs location access to detect your pickup point. Please enable location permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    HapticFeedback.lightImpact();
  }

  void _onLocationPinTap() {
    HapticFeedback.mediumImpact();
    // Simulate pin adjustment with map animation
    setState(() {
      _isLoadingLocation = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoadingLocation = false;
        _detectedAddress =
            '140 West 57th Street, Midtown Manhattan, New York, NY 10019, United States';
      });

      // Animate map slightly to show location adjustment
      if (_mapController != null && _currentPosition != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentPosition!.latitude + 0.0001,
                _currentPosition!.longitude + 0.0001),
            15.5,
          ),
        );
      }
    });
  }

  void _onMapCreated(DummyMapController controller) {
    _mapController = controller;

    // If we already have a position, animate to it
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  void _onConfirmLocation() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/ride-request-screen');
  }

  void _onLocationSelected(Map<String, dynamic> location) {
    HapticFeedback.selectionClick();
    setState(() {
      _detectedAddress = location['address'] as String;
      _isLoadingLocation = false;
    });

    // Animate map to selected location
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location['latitude'], location['longitude']),
          15.0,
        ),
      );
    }
  }

  void _showFavoritesModal() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FavoritesModal(
        favoriteLocations: _favoriteLocations,
        onLocationSelected: _onLocationSelected,
        onAddFavorite: () {
          // Handle add favorite location
        },
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Add current location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current detected position',
          ),
        ),
      );
    }

    // Add favorite location markers
    for (int i = 0; i < _favoriteLocations.length; i++) {
      final location = _favoriteLocations[i];
      markers.add(
        Marker(
          markerId: MarkerId('favorite_$i'),
          position: LatLng(location['latitude'], location['longitude']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: location['name'],
            snippet: location['address'],
          ),
        ),
      );
    }

    return markers;
  }

  @override
  void dispose() {
    _mapAnimationController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.home,
        title: _detectedAddress.isNotEmpty
            ? _detectedAddress
            : 'Detecting location...',
        onLocationTap: () {
          // Handle location tap - could show location search
        },
        actions: [
          IconButton(
            onPressed: _toggleTheme,
            icon: CustomIconWidget(
              iconName: _isDarkMode ? 'light_mode' : 'dark_mode',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
            child: CustomIconWidget(
              iconName: 'person',
              color: AppTheme.primaryLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          // Dummy map with fade animation
          AnimatedBuilder(
            animation: _mapFadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _mapFadeAnimation.value,
                child: DummyMapWidget(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(_currentPosition!.latitude,
                            _currentPosition!.longitude)
                        : const LatLng(40.7589, -73.9851), // Default to NYC
                    zoom: 15.0,
                  ),
                  markers: _buildMarkers(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // We'll use custom FAB
                  zoomControlsEnabled: true,
                ),
              );
            },
          ),

          // GPS accuracy indicator
          if (_isLocationPermissionGranted && _gpsAccuracy > 0)
            Positioned(
              top: 2.h,
              left: 0,
              right: 0,
              child: GpsAccuracyIndicator(
                accuracy: _gpsAccuracy,
                isVisible: !_isLoadingLocation,
              ),
            ),

          // Floating action button for favorites
          Positioned(
            bottom: 35.h,
            right: 4.w,
            child: FloatingActionButton(
              onPressed: _showFavoritesModal,
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: AppTheme.primaryLight,
              elevation: 4,
              child: CustomIconWidget(
                iconName: 'favorite',
                color: AppTheme.primaryLight,
                size: 24,
              ),
            ),
          ),

          // Center location pin overlay
          if (!_isLoadingLocation)
            Center(
              child: LocationPinWidget(
                isActive: !_isLoadingLocation && _currentPosition != null,
                onTap: _onLocationPinTap,
                size: 48,
              ),
            ),

          // Loading overlay
          if (_isLoadingLocation)
            Container(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _loadingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 0.8 + (_loadingAnimation.value * 0.2),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryLight.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'location_searching',
                              color: AppTheme.primaryLight,
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Detecting your location...',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please ensure GPS is enabled',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Address bottom sheet
          AddressBottomSheet(
            detectedAddress: _detectedAddress,
            recentLocations: _recentLocations,
            isLoading: _isLoadingLocation,
            onConfirmLocation: _onConfirmLocation,
            onLocationSelected: _onLocationSelected,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        variant: CustomBottomBarVariant.standard,
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
