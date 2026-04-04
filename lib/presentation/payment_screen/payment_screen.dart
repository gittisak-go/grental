import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/reservation_model.dart';
import '../../services/reservation_service.dart';
import '../../services/supabase_service.dart';
import './widgets/fare_breakdown_card.dart';
import './widgets/payment_method_card.dart';
import './widgets/promo_code_widget.dart';
import './widgets/ride_summary_card.dart';
import './widgets/security_indicators_widget.dart';
import './widgets/tip_selection_widget.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  int selectedPaymentMethodIndex = 0;
  double tipAmount = 0.0;
  double discountAmount = 0.0;
  String appliedPromoCode = '';
  bool isProcessingPayment = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Ride details loaded from route arguments or Supabase
  Map<String, dynamic> rideDetails = {
    'pickup': '-',
    'destination': '-',
    'duration': '-',
    'distance': '-',
    'driverName': '-',
    'vehicleInfo': '-',
    'rideId': '-',
    'reservationId': null,
  };

  Map<String, dynamic> fareDetails = {
    'breakdown': [
      {'label': 'ค่าเช่าพื้นฐาน', 'amount': '฿0', 'isTotal': false},
    ],
    'subtotal': '฿0',
    'total': '฿0',
    'discount': null,
  };

  double _baseAmount = 0.0;

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 1,
      'type': 'card',
      'name': 'Visa •••• 4532',
      'details': 'หมดอายุ 12/26',
      'isDefault': true,
    },
    {
      'id': 2,
      'type': 'apple_pay',
      'name': 'Apple Pay',
      'details': 'Touch ID หรือ Face ID',
      'isDefault': false,
    },
    {
      'id': 3,
      'type': 'google_pay',
      'name': 'Google Pay',
      'details': 'ลายนิ้วมือหรือ PIN',
      'isDefault': false,
    },
    {
      'id': 4,
      'type': 'cash',
      'name': 'เงินสด',
      'details': 'ชำระให้คนขับโดยตรง',
      'isDefault': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRideDetails();
  }

  Future<void> _loadRideDetails() async {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      // Load from passed arguments
      final reservationId = args['reservationId'] as String?;
      if (reservationId != null) {
        await _loadFromSupabase(reservationId);
        return;
      }
      // Use passed data directly
      setState(() {
        rideDetails = {
          'pickup': args['pickup'] ?? '-',
          'destination': args['destination'] ?? '-',
          'duration': args['duration'] ?? '-',
          'distance': args['distance'] ?? '-',
          'driverName': args['driverName'] ?? '-',
          'vehicleInfo': args['vehicleInfo'] ?? '-',
          'rideId': args['rideId'] ?? '-',
          'reservationId': args['reservationId'],
        };
        _baseAmount = (args['totalAmount'] as num?)?.toDouble() ?? 0.0;
        _updateFareDetails();
      });
    } else {
      // Try to load latest reservation from Supabase
      await _loadLatestReservation();
    }
  }

  Future<void> _loadFromSupabase(String reservationId) async {
    try {
      final service = ReservationService();
      final reservation = await service.getReservationById(reservationId);
      _applyReservationData(reservation);
    } catch (_) {}
  }

  Future<void> _loadLatestReservation() async {
    try {
      final user = SupabaseService.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await SupabaseService.instance.client
          .from('reservations')
          .select('*')
          .eq('customer_email', user.email ?? '')
          .inFilter('status', ['confirmed', 'active', 'pending'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        final reservation = ReservationModel.fromJson(response);
        _applyReservationData(reservation);
      }
    } catch (_) {}
  }

  void _applyReservationData(ReservationModel reservation) {
    if (!mounted) return;
    setState(() {
      rideDetails = {
        'pickup': reservation.pickupLocation ?? '-',
        'destination': reservation.dropoffLocation ?? '-',
        'duration': '-',
        'distance': '-',
        'driverName': '-',
        'vehicleInfo': reservation.vehicleId ?? '-',
        'rideId': reservation.id ?? '-',
        'reservationId': reservation.id,
      };
      _baseAmount = reservation.totalAmount;
      _updateFareDetails();
    });
  }

  void _updateFareDetails() {
    fareDetails = {
      'breakdown': [
        {
          'label': 'ค่าเช่าพื้นฐาน',
          'amount': '฿${_baseAmount.toStringAsFixed(0)}',
          'isTotal': false
        },
      ],
      'subtotal': '฿${_baseAmount.toStringAsFixed(0)}',
      'total': '฿${_baseAmount.toStringAsFixed(0)}',
      'discount': null,
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          'การชำระเงิน',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showReceiptPreview(),
            icon: CustomIconWidget(
              iconName: 'receipt',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 1.h),
                    RideSummaryCard(rideDetails: rideDetails),
                    FareBreakdownCard(fareDetails: fareDetails),
                    _buildPaymentMethodsSection(),
                    TipSelectionWidget(
                      onTipChanged: (tip) {
                        setState(() {
                          tipAmount = tip;
                        });
                        _updateTotalAmount();
                      },
                      initialTip: tipAmount,
                    ),
                    PromoCodeWidget(
                      onPromoApplied: (promoCode, discount) {
                        setState(() {
                          appliedPromoCode = promoCode;
                          discountAmount = discount;
                          fareDetails['discount'] =
                              '฿${discount.toStringAsFixed(2)}';
                        });
                        _updateTotalAmount();
                      },
                      onPromoRemoved: () {
                        setState(() {
                          appliedPromoCode = '';
                          discountAmount = 0.0;
                          fareDetails['discount'] = null;
                        });
                        _updateTotalAmount();
                      },
                    ),
                    const SecurityIndicatorsWidget(),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'payment',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'วิธีการชำระเงิน',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          ...paymentMethods.asMap().entries.map((entry) {
            final index = entry.key;
            final method = entry.value;

            return PaymentMethodCard(
              paymentMethod: method,
              isSelected: index == selectedPaymentMethodIndex,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  selectedPaymentMethodIndex = index;
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentButton() {
    final theme = Theme.of(context);
    final totalAmount = _calculateTotalAmount();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ยอดรวมทั้งหมด',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '฿${totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: isProcessingPayment ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isProcessingPayment
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'กำลังดำเนินการ...',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: _getPaymentIcon(),
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'จ่ายเงิน ฿${totalAmount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentIcon() {
    final selectedMethod = paymentMethods[selectedPaymentMethodIndex];
    switch (selectedMethod['type'] as String) {
      case 'apple_pay':
        return 'apple';
      case 'google_pay':
        return 'google';
      case 'cash':
        return 'money';
      default:
        return 'credit_card';
    }
  }

  double _calculateTotalAmount() {
    double total = _baseAmount + tipAmount - discountAmount;
    return total > 0 ? total : 0;
  }

  void _updateTotalAmount() {
    final total = _calculateTotalAmount();
    setState(() {
      fareDetails['total'] = '฿${total.toStringAsFixed(2)}';
    });
  }

  Future<void> _processPayment() async {
    setState(() {
      isProcessingPayment = true;
    });

    HapticFeedback.mediumImpact();

    try {
      // Update reservation status to completed if we have a reservation ID
      final reservationId = rideDetails['reservationId'] as String?;
      if (reservationId != null) {
        final service = ReservationService();
        await service.updateReservationStatus(
          reservationId,
          ReservationStatus.completed,
        );
      }
    } catch (_) {}

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        isProcessingPayment = false;
      });
      _showPaymentSuccess();
    }
  }

  void _showPaymentSuccess() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successLight,
                size: 40,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'ชำระเงินสำเร็จ!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'การเดินทางของคุณได้รับการชำระเงินเรียบร้อยแล้ว ใบเสร็จถูกส่งไปยังอีเมลของคุณ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/ride-history-screen',
                    (route) => false,
                  );
                },
                child: const Text('ดูใบเสร็จ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptPreview() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'ตัวอย่างใบเสร็จ',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReceiptHeader(),
                      SizedBox(height: 2.h),
                      RideSummaryCard(rideDetails: rideDetails),
                      FareBreakdownCard(fareDetails: fareDetails),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('ปิด'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _shareReceipt();
                      },
                      child: const Text('แชร์'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'รุ่งโรจน์คาร์เร้นท์',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'ใบเสร็จการเดินทาง',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'รหัสการเดินทาง: ${rideDetails['rideId']}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            'วันที่: ${DateTime.now().toString().split(' ')[0]}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _shareReceipt() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('แชร์ใบเสร็จสำเร็จ!'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }
}
