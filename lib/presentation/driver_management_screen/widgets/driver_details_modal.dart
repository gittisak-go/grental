import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DriverDetailsModal extends StatelessWidget {
  final Map<String, dynamic> driver;
  final Function(String action) onAction;

  const DriverDetailsModal({
    Key? key,
    required this.driver,
    required this.onAction,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'verified':
        return 'ตรวจสอบแล้ว';
      case 'pending':
        return 'รอตรวจสอบ';
      case 'expired':
        return 'หมดอายุ';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final license = driver['license'] as Map<String, dynamic>;
    final insurance = driver['insurance'] as Map<String, dynamic>;
    final backgroundCheck = driver['backgroundCheck'] as Map<String, dynamic>;
    final performance = driver['performance'] as Map<String, dynamic>;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with photo
            Stack(
              children: [
                Container(
                  height: 25.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20.0)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20.0)),
                    child: CachedNetworkImage(
                      imageUrl: driver['photo'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and rating
                    Text(
                      driver['name'],
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 1.w),
                        Text(
                          '${driver['rating']} (${driver['totalTrips']} เที่ยว)',
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      driver['vehicle'],
                      style:
                          TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),

                    Divider(height: 3.h),

                    // Document verification
                    Text(
                      'เอกสาร',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    _buildDocumentRow(
                      'ใบขับขี่',
                      license['status'],
                      'หมดอายุ: ${license['expiry']}',
                    ),
                    _buildDocumentRow(
                      'ประกันภัย',
                      insurance['status'],
                      'หมดอายุ: ${insurance['expiry']}',
                    ),
                    _buildDocumentRow(
                      'ตรวจประวัติ',
                      backgroundCheck['status'],
                      'ตรวจสอบ: ${backgroundCheck['date']}',
                    ),

                    Divider(height: 3.h),

                    // Performance metrics
                    Text(
                      'ประสิทธิภาพ',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    _buildPerformanceRow('อัตราการทำงานสำเร็จ',
                        '${performance['completionRate']}%'),
                    _buildPerformanceRow(
                        'เวลาตอบกลับเฉลี่ย', performance['avgResponseTime']),
                    _buildPerformanceRow('คะแนนจากลูกค้า',
                        performance['customerRating'].toString()),

                    Divider(height: 3.h),

                    // Earnings
                    Text(
                      'รายได้',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Text(
                          'วันนี้:',
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.grey[600]),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '฿${driver['dailyEarnings'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onAction('message');
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('ส่งข้อความ'),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onAction('reassign');
                          },
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('จัดสรรรถ'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onAction('earnings');
                          },
                          icon: const Icon(Icons.attach_money),
                          label: const Text('ปรับยอดรายได้'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            onAction('suspend');
                          },
                          icon: const Icon(Icons.block),
                          label: const Text('ระงับบัญชี'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentRow(String label, String status, String detail) {
    final statusColor = _getStatusColor(status);
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Icon(
            status == 'verified'
                ? Icons.check_circle
                : status == 'pending'
                    ? Icons.pending
                    : Icons.error,
            color: statusColor,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                ),
                Text(
                  detail,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              _getStatusText(status),
              style: TextStyle(
                fontSize: 11.sp,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
