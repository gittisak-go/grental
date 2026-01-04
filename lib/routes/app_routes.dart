import 'package:flutter/material.dart';

import '../presentation/admin_dashboard_screen/admin_dashboard_screen.dart';
import '../presentation/admin_reservations_screen/admin_reservations_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/bank_info_screen/bank_info_screen.dart';
import '../presentation/checkout_screen/checkout_screen.dart';
import '../presentation/driver_management_screen/driver_management_screen.dart';
import '../presentation/driver_profile_screen/driver_profile_screen.dart';
import '../presentation/fleet_inventory_screen/fleet_inventory_screen.dart';
import '../presentation/live_tracking_screen/live_tracking_screen.dart';
import '../presentation/location_detection_screen/location_detection_screen.dart';
import '../presentation/payment_screen/payment_screen.dart';
import '../presentation/rental_status_screen/rental_status_screen.dart';
import '../presentation/ride_history_screen/ride_history_screen.dart';
import '../presentation/ride_request_screen/ride_request_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/user_profile_screen/user_profile_screen.dart';
import '../presentation/vehicle_management_screen/vehicle_management_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
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
  static const String driverManagementScreen = '/driver-management-screen';
  static const String fleetInventoryScreen = '/fleet-inventory-screen';
  static const String checkoutScreen = '/checkout-screen';
  static const String rentalStatusScreen = '/rental-status-screen';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const RideRequestScreen(),
        rideRequest: (context) => const RideRequestScreen(),
        liveTracking: (context) => const LiveTrackingScreen(),
        splash: (context) => const SplashScreen(),
        payment: (context) => const PaymentScreen(),
        userProfile: (context) => const UserProfileScreen(),
        driverProfile: (context) => const DriverProfileScreen(),
        authentication: (context) => const AuthenticationScreen(),
        rideHistory: (context) => const RideHistoryScreen(),
        locationDetection: (context) => const LocationDetectionScreen(),
        vehicleManagement: (context) => const VehicleManagementScreen(),
        adminReservations: (context) => const AdminReservationsScreen(),
        bankInfoScreen: (context) => const BankInfoScreen(),
        adminDashboardScreen: (context) => const AdminDashboardScreen(),
        driverManagementScreen: (context) => const DriverManagementScreen(),
        fleetInventoryScreen: (context) => const FleetInventoryScreen(),
        checkoutScreen: (context) => const CheckoutScreen(),
        rentalStatusScreen: (context) => const RentalStatusScreen(),
        // TODO: Add your other routes here
      };
}
