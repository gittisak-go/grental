import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/checkout_service.dart';
import './widgets/customer_info_section.dart';
import './widgets/payment_method_section.dart';
import './widgets/rental_details_section.dart';
import './widgets/terms_section.dart';
import './widgets/vehicle_summary_card.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AuthService _authService = AuthService();
  final CheckoutService _checkoutService = CheckoutService();

  Map<String, dynamic>? _vehicleData;
  Map<String, dynamic>? _rentalData;
  bool _isLoading = false;
  bool _termsAccepted = false;
  String _selectedPaymentMethod = 'bank_transfer';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idCardController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _vehicleData = args['vehicle'];
        _rentalData = args['rentalData'];
      });

      // Pre-fill user data if authenticated
      if (_authService.isAuthenticated) {
        final userId = _authService.currentUserId;
        if (userId != null) {
          final profile = await _authService.getUserProfile(userId);
          if (profile != null) {
            _nameController.text = profile['full_name'] ?? '';
            _phoneController.text = profile['phone'] ?? '';
          }
        }
      }
    }
  }

  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      _showErrorDialog('กรุณายอมรับข้อกำหนดและเงื่อนไข');
      return;
    }

    if (!_authService.isAuthenticated) {
      _showLoginRequired();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUserId!;
      final userEmail = _authService.currentUser!.email!;

      final result = await _checkoutService.createReservation(
        vehicleId: _vehicleData!['id'],
        customerId: userId,
        customerName: _nameController.text,
        customerEmail: userEmail,
        customerPhone: _phoneController.text,
        customerIdCard: _idCardController.text,
        startDate: DateTime.parse(_rentalData!['startDate']),
        endDate: DateTime.parse(_rentalData!['endDate']),
        pickupLocation: _rentalData!['pickupLocation'],
        dropoffLocation: _rentalData!['dropoffLocation'],
        dailyRate: _vehicleData!['price_per_day'].toDouble(),
        totalDays: _rentalData!['totalDays'],
        totalAmount: _rentalData!['totalAmount'].toDouble(),
        depositAmount: _rentalData!['depositAmount'].toDouble(),
        specialRequests: _rentalData!['specialRequests'],
        paymentMethod: _selectedPaymentMethod,
      );

      setState(() => _isLoading = false);

      _showSuccessDialog(result);
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorDialog(error.toString());
    }
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ต้องเข้าสู่ระบบ'),
        content: const Text('กรุณาเข้าสู่ระบบเพื่อทำการจอง'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.authentication);
            },
            child: const Text('เข้าสู่ระบบ'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('จองสำเร็จ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64.0),
            SizedBox(height: 2.h),
            const Text('การจองของคุณสำเร็จแล้ว'),
            SizedBox(height: 1.h),
            Text(
                'หมายเลขการจอง: ${result['reservation']['id'].toString().substring(0, 8)}',
                style: TextStyle(fontSize: 12.sp)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.rentalStatusScreen,
                arguments: result['reservation']['id'],
              );
            },
            child: const Text('ดูสถานะการจอง'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เกิดข้อผิดพลาด'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_vehicleData == null || _rentalData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ชำระเงิน')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระเงิน'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(4.w),
              children: [
                VehicleSummaryCard(vehicleData: _vehicleData!),
                SizedBox(height: 2.h),
                RentalDetailsSection(
                  rentalData: _rentalData!,
                  vehiclePrice: _vehicleData!['price_per_day'].toDouble(),
                ),
                SizedBox(height: 2.h),
                CustomerInfoSection(
                  nameController: _nameController,
                  phoneController: _phoneController,
                  idCardController: _idCardController,
                ),
                SizedBox(height: 2.h),
                PaymentMethodSection(
                  selectedMethod: _selectedPaymentMethod,
                  onMethodChanged: (value) => setState(
                      () => _selectedPaymentMethod = value ?? 'bank_transfer'),
                ),
                SizedBox(height: 2.h),
                TermsSection(
                  isAccepted: _termsAccepted,
                  onChanged: (value) =>
                      setState(() => _termsAccepted = value ?? false),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('ยืนยันการจอง',
                            style: TextStyle(
                                fontSize: 16.sp, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}