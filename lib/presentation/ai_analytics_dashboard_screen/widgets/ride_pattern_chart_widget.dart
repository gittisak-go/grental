import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class RidePatternChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> rideData;

  const RidePatternChartWidget({super.key, required this.rideData});

  @override
  State<RidePatternChartWidget> createState() => _RidePatternChartWidgetState();
}

class _RidePatternChartWidgetState extends State<RidePatternChartWidget> {
  int _selectedIndex = -1;

  List<BarChartGroupData> _buildBarGroups() {
    final hours = List.generate(24, (i) => i);
    return hours.map((hour) {
      final data = widget.rideData.firstWhere(
        (d) => d['hour'] == hour,
        orElse: () => {'hour': hour, 'count': 0},
      );
      final count = (data['count'] as num).toDouble();
      final isSelected = _selectedIndex == hour;
      final isPeak = count > 15;
      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: count,
            color: isSelected
                ? const Color(0xFFAD1457)
                : isPeak
                ? const Color(0xFFE91E63)
                : const Color(0xFFE91E63).withAlpha(128),
            width: 8,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFFE91E63),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Peak Booking Times',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C1C1E),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withAlpha(26),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Today',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: const Color(0xFFE91E63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 18.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 30,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchCallback: (event, response) {
                    if (response?.spot != null) {
                      setState(() {
                        _selectedIndex = response!.spot!.touchedBarGroupIndex;
                      });
                    }
                  },
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: const Color(0xFF1C1C1E),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${group.x}:00\n${rod.toY.toInt()} rides',
                        GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 6 == 0) {
                          return Text(
                            '${value.toInt()}h',
                            style: GoogleFonts.inter(
                              fontSize: 8.sp,
                              color: const Color(0xFF8E8E93),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 10 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.inter(
                              fontSize: 8.sp,
                              color: const Color(0xFF8E8E93),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 24,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.withAlpha(51), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFFE91E63), 'Peak Hours'),
              SizedBox(width: 4.w),
              _buildLegend(
                const Color(0xFFE91E63).withAlpha(128),
                'Normal Hours',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3.0),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ],
    );
  }
}