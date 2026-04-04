import 'package:flutter/material.dart';

import '../presentation/about_app_screen/about_app_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/bank_info_screen/bank_info_screen.dart';
import '../presentation/driver_profile_screen/driver_profile_screen.dart';
import '../presentation/fleet_inventory_screen/fleet_inventory_screen.dart';
import '../presentation/live_tracking_screen/live_tracking_screen.dart';
import '../presentation/location_detection_screen/location_detection_screen.dart';
import '../presentation/payment_screen/payment_screen.dart';
import '../presentation/required_documents_screen/required_documents_screen.dart';
import '../presentation/ride_history_screen/ride_history_screen.dart';
import '../presentation/ride_request_screen/ride_request_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/viewer_dashboard_screen/viewer_dashboard_screen.dart';
import '../services/magic_link_auth_service.dart';
import '../services/supabase_service.dart';

class AppRoutes {
  static const String initial = '/';
  static const String rideRequest = '/ride-request-screen';
  static const String liveTracking = '/live-tracking-screen';
  static const String splash = '/splash-screen';
  static const String payment = '/payment-screen';
  static const String userProfile = '/user-profile-screen';
  static const String driverProfile = '/driver-profile-screen';
  static const String authentication = '/authentication-screen';
  static const String rideHistory = '/ride-history-screen';
  static const String locationDetection = '/location-detection-screen';
  static const String vehicleManagement = '/vehicle-management-screen';
  static const String adminReservations = '/admin-reservations-screen';
  static const String bankInfoScreen = '/bank-info-screen';
  static const String adminDashboardScreen = '/admin-dashboard-screen';
  static const String viewerDashboardScreen = '/viewer-dashboard-screen';
  static const String driverManagementScreen = '/driver-management-screen';
  static const String fleetInventoryScreen = '/fleet-inventory-screen';
  static const String checkoutScreen = '/checkout-screen';
  static const String rentalStatusScreen = '/rental-status-screen';
  static const String aboutAppScreen = '/about-app-screen';
  static const String notificationPreferencesScreen =
      '/notification-preferences-screen';
  static const String requiredDocumentsScreen = '/required-documents-screen';

  // New booking flow routes
  static const String carSelectionScreen = '/car-selection-screen';
  static const String bookingPaymentScreen = '/booking-payment-screen';
  static const String bookingStatusScreen = '/booking-status-screen';

  // Role-protected routes (Admin/Super_Admin only)
  static const Set<String> _adminOnlyRoutes = {
    '/admin-dashboard-screen',
    '/admin-reservations-screen',
    '/driver-management-screen',
    '/vehicle-management-screen',
  };

  // Routes requiring authentication (User+)
  static const Set<String> _authRequiredRoutes = {
    '/car-selection-screen',
    '/booking-payment-screen',
    '/booking-status-screen',
    '/rental-status-screen',
    '/checkout-screen',
    '/user-profile-screen',
    '/notification-preferences-screen',
  };

  /// Returns redirect route if access is denied, null if allowed.
  static String? guardRoute(String routeName) {
    final client = SupabaseService.instance.client;
    final user = client.auth.currentUser;

    if (_adminOnlyRoutes.contains(routeName)) {
      if (user == null) return authentication;
      final authSvc = MagicLinkAuthService();
      if (!authSvc.isCurrentUserAdmin) return rideRequest;
    }

    if (_authRequiredRoutes.contains(routeName)) {
      if (user == null) return authentication;
    }

    return null;
  }

  static Map<String, WidgetBuilder> get routes => {
    initial: (context) => const RideRequestScreen(),
    rideRequest: (context) => const RideRequestScreen(),
    liveTracking: (context) => const LiveTrackingScreen(),
    splash: (context) => const SplashScreen(),
    payment: (context) => const PaymentScreen(),
    driverProfile: (context) => const DriverProfileScreen(),
    authentication: (context) => const AuthenticationScreen(),
    rideHistory: (context) => const RideHistoryScreen(),
    locationDetection: (context) => const LocationDetectionScreen(),
    bankInfoScreen: (context) => const BankInfoScreen(),
    viewerDashboardScreen: (context) => const ViewerDashboardScreen(),
    fleetInventoryScreen: (context) => const FleetInventoryScreen(),
    aboutAppScreen: (context) => const AboutAppScreen(),
    requiredDocumentsScreen: (context) => const RequiredDocumentsScreen(),
  };

  /// Wraps a widget with route guard logic.
  static Widget _guardedRoute(
    BuildContext context,
    String routeName,
    Widget screen,
  ) {
    final redirect = guardRoute(routeName);
    if (redirect != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('คุณไม่มีสิทธิ์เข้าถึงหน้านี้ กรุณาเข้าสู่ระบบ'),
            backgroundColor: Color(0xFFFF453A),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushReplacementNamed(context, redirect);
      });
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A12),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF2D78)),
        ),
      );
    }
    return screen;
  }
}
