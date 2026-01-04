import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DriverCardWidget extends StatelessWidget {
  final Map<String, dynamic> driver;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onSelectionChanged;

  const DriverCardWidget({
    Key? key,
    required this.driver,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onSelectionChanged,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'online':
        return Colors.green;
      case 'busy':
        return Colors.orange;
      case 'offline':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'online':
        return 'ออนไลน์';
      case 'busy':
        return 'กำลังทำงาน';
      case 'offline':
        return 'ออฟไลน์';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'online':
        return Icons.check_circle;
      case 'busy':
        return Icons.local_shipping;
      case 'offline':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  bool _hasDocumentIssues() {
    final license = driver['license'] as Map<String, dynamic>;
    final insurance = driver['insurance'] as Map<String, dynamic>;
    final backgroundCheck = driver['backgroundCheck'] as Map<String, dynamic>;

    return license['status'] != 'verified' ||
        insurance['status'] != 'verified' ||
        backgroundCheck['status'] != 'verified';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(driver['status']);
    final hasIssues = _hasDocumentIssues();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
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
            // Header with photo and status
            Stack(
              children: [
                Container(
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12.0)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12.0)),
                    child: CachedNetworkImage(
                      imageUrl: driver['photo'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),

                // Selection checkbox
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSelectionChanged(value ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                // Status badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getStatusIcon(driver['status']),
                            size: 12, color: Colors.white),
                        SizedBox(width: 1.w),
                        Text(
                          _getStatusText(driver['status']),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Document issue indicator
                if (hasIssues)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(1.w),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning,
                          size: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),

            // Driver info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      driver['name'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),

                    // Vehicle
                    Text(
                      driver['vehicle'],
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),

                    // Rating and trips
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 1.w),
                        Text(
                          driver['rating'].toString(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${driver['totalTrips']} เที่ยว',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),

                    // Daily earnings
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 14, color: Colors.green),
                        Text(
                          '฿${driver['dailyEarnings'].toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          ' วันนี้',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
}
