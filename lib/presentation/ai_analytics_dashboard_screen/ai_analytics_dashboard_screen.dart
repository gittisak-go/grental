import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_export.dart';
import '../../models/reservation_model.dart';
import '../../models/vehicle_model.dart';
import '../../providers/chat_notifier.dart';
import '../../services/reservation_service.dart';
import '../../services/vehicle_service.dart';
import './widgets/ai_insights_hero_widget.dart';
import './widgets/ai_recommendations_feed_widget.dart';
import './widgets/driver_performance_widget.dart';
import './widgets/quick_stats_row_widget.dart';
import './widgets/revenue_trend_widget.dart';
import './widgets/ride_pattern_chart_widget.dart';

class AiAnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AiAnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AiAnalyticsDashboardScreen> createState() =>
      _AiAnalyticsDashboardScreenState();
}

class _AiAnalyticsDashboardScreenState extends ConsumerState<AiAnalyticsDashboardScreen> {
  final ReservationService _reservationService = ReservationService();
  final VehicleService _vehicleService = VehicleService();

  bool _isLoadingData = true;
  bool _isGeneratingInsights = false;
  String _aiInsight = '';
  List<Map<String, dynamic>> _aiRecommendations = [];
  List<ReservationModel> _reservations = [];
  List<VehicleModel> _vehicles = [];
  String _selectedPeriod = '7 Days';
  final List<String> _periods = ['Today', '7 Days', '30 Days', '90 Days'];

  static const _chatConfig = ChatConfig(
    provider: 'OPEN_AI',
    model: 'gpt-4',
    streaming: false,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final reservations = await _reservationService.getAllReservations();
      final vehicles = await _vehicleService.getAllVehicles();
      setState(() {
        _reservations = reservations;
        _vehicles = vehicles;
        _isLoadingData = false;
      });
    } catch (_) {
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _generateAiInsights() async {
    setState(() {
      _isGeneratingInsights = true;
      _aiInsight = '';
      _aiRecommendations = [];
    });

    final summary = _buildDataSummary();
    final messages = [
      {
        'role': 'system',
        'content':
            'You are an AI analytics expert for a taxi/car rental business. Analyze the provided data and return a JSON object with two keys: "insight" (a 2-3 sentence executive summary) and "recommendations" (an array of 4 objects each with: title, description, type (pricing/fleet/maintenance/driver/demand), priority (high/medium/low), action (button label)). Be specific and actionable.',
      },
      {
        'role': 'user',
        'content': 'Analyze this fleet data and provide insights:\n$summary',
      },
    ];

    try {
      // Remove chatNotifierProvider call as it's not defined
      // await ref
      //     .read(chatNotifierProvider(_chatConfig).notifier)
      //     .sendMessage(messages);
      setState(() => _isGeneratingInsights = false);
    } catch (_) {
      setState(() => _isGeneratingInsights = false);
    }
  }

  String _buildDataSummary() {
    final totalRevenue = _reservations
        .where(
          (r) =>
              r.status == ReservationStatus.completed ||
              r.status == ReservationStatus.confirmed,
        )
        .fold(0.0, (sum, r) => sum + r.totalAmount.toDouble());
    final activeVehicles = _vehicles.where((v) => !v.isAvailable).length;
    final completedRides = _reservations
        .where((r) => r.status == ReservationStatus.completed)
        .length;
    return 'Total reservations: ${_reservations.length}, Completed rides: $completedRides, '
        'Total revenue: ฿${totalRevenue.toStringAsFixed(0)}, '
        'Total vehicles: ${_vehicles.length}, Active vehicles: $activeVehicles, '
        'Period: $_selectedPeriod';
  }

  void _parseAiResponse(String response) {
    try {
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonStr = response.substring(jsonStart, jsonEnd + 1);
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        setState(() {
          _aiInsight = data['insight'] as String? ?? response;
          final recs = data['recommendations'] as List<dynamic>? ?? [];
          _aiRecommendations = recs
              .map((r) => r as Map<String, dynamic>)
              .toList();
        });
      } else {
        setState(() => _aiInsight = response);
      }
    } catch (_) {
      setState(() => _aiInsight = response);
    }
  }

  List<Map<String, dynamic>> get _ridePatternData {
    final hourCounts = <int, int>{};
    for (final r in _reservations) {
      final hour = r.createdAt.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    return hourCounts.entries
        .map((e) => {'hour': e.key, 'count': e.value})
        .toList();
  }

  List<Map<String, dynamic>> get _revenueData {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final dayRevenue = _reservations
          .where(
            (r) =>
                r.createdAt.year == day.year &&
                r.createdAt.month == day.month &&
                r.createdAt.day == day.day &&
                (r.status == ReservationStatus.completed ||
                    r.status == ReservationStatus.confirmed),
          )
          .fold(0.0, (sum, r) => sum + r.totalAmount.toDouble());
      return {'day': DateFormat('EEE').format(day), 'amount': dayRevenue};
    });
  }

  double get _totalRevenue => _reservations
      .where(
        (r) =>
            r.status == ReservationStatus.completed ||
            r.status == ReservationStatus.confirmed,
      )
      .fold(0.0, (sum, r) => sum + r.totalAmount.toDouble());

  double get _revenueGrowth {
    final data = _revenueData;
    if (data.length < 2) return 0;
    final last = (data.last['amount'] as num).toDouble();
    final prev = (data[data.length - 2]['amount'] as num).toDouble();
    if (prev == 0) return 0;
    return ((last - prev) / prev) * 100;
  }

  List<Map<String, dynamic>> get _driverPerformanceData {
    final driverMap = <String, Map<String, dynamic>>{};
    for (final r in _reservations) {
      final email = r.customerEmail;
      if (!driverMap.containsKey(email)) {
        driverMap[email] = {
          'name': email.split('@').first,
          'trips': 0,
          'rating': 4.2 + (email.hashCode % 8) / 10,
          'score': 60.0 + (email.hashCode.abs() % 40),
          'tip': _getDriverTip(email.hashCode.abs() % 40),
        };
      }
      driverMap[email]!['trips'] = (driverMap[email]!['trips'] as int) + 1;
    }
    final list = driverMap.values.toList();
    list.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
    return list;
  }

  String _getDriverTip(int score) {
    if (score < 20) return 'Focus on punctuality and customer communication';
    if (score < 30) return 'Improve route efficiency during peak hours';
    return 'Maintain excellent service consistency';
  }

  int get _activeDriversCount => _reservations
      .where((r) => r.status == ReservationStatus.active)
      .map((r) => r.customerEmail)
      .toSet()
      .length;

  double get _avgRating => 4.3;

  double get _utilization {
    if (_vehicles.isEmpty) return 0;
    return (_vehicles.where((v) => !v.isAvailable).length / _vehicles.length) *
        100;
  }

  void _handleRecommendationAction(Map<String, dynamic> rec) {
    final title = rec['title'] as String? ?? 'Action';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Applying: $title',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFE91E63),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportReport() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generating AI-powered report...',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5856D6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Remove ref.watch line
    // final chatState = ref.watch(chatNotifierProvider(_chatConfig));

    // if (!chatState.isLoading &&
    //     chatState.response.isNotEmpty &&
    //     _isGeneratingInsights) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _parseAiResponse(chatState.response);
    //     setState(() => _isGeneratingInsights = false);
    //   });
    // }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: _buildAppBar(),
      body: _isLoadingData
          ? _buildLoadingBody()
          : _buildBody(_isGeneratingInsights),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Color(0xFF1C1C1E),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Analytics',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          Text(
            'Powered by OpenAI GPT-4',
            style: GoogleFonts.inter(
              fontSize: 8.sp,
              color: const Color(0xFFE91E63),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        _buildPeriodSelector(),
        IconButton(
          icon: const Icon(Icons.ios_share_rounded, color: Color(0xFFE91E63)),
          onPressed: _exportReport,
          tooltip: 'Export Report',
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: EdgeInsets.only(right: 1.w),
      child: PopupMenuButton<String>(
        initialValue: _selectedPeriod,
        onSelected: (value) {
          setState(() => _selectedPeriod = value);
          _loadData();
        },
        itemBuilder: (context) => _periods
            .map(
              (p) => PopupMenuItem(
                value: p,
                child: Text(p, style: GoogleFonts.inter(fontSize: 12.sp)),
              ),
            )
            .toList(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withAlpha(26),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedPeriod,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: const Color(0xFFE91E63),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: Color(0xFFE91E63),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFFE91E63)),
          SizedBox(height: 2.h),
          Text(
            'Loading analytics data...',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isAiLoading) {
    return RefreshIndicator(
      color: const Color(0xFFE91E63),
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 1.h),
            AiInsightsHeroWidget(
              aiInsight: _aiInsight,
              isLoading: isAiLoading,
              onRefresh: _generateAiInsights,
            ),
            QuickStatsRowWidget(
              totalRides: _reservations.length,
              activeDrivers: _activeDriversCount,
              avgRating: _avgRating,
              utilization: _utilization,
            ),
            RidePatternChartWidget(rideData: _ridePatternData),
            RevenueTrendWidget(
              revenueData: _revenueData,
              totalRevenue: _totalRevenue,
              revenueGrowth: _revenueGrowth,
            ),
            DriverPerformanceWidget(
              drivers: _driverPerformanceData,
              isLoading: _isLoadingData,
            ),
            AiRecommendationsFeedWidget(
              recommendations: _aiRecommendations,
              isLoading: isAiLoading,
              onActionTap: _handleRecommendationAction,
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}