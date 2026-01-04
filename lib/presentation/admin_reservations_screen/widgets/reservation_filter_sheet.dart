import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/reservation_model.dart';

class ReservationFilterSheet extends StatefulWidget {
  final ReservationStatus? selectedStatus;
  final Function(ReservationStatus?) onFilterApplied;

  const ReservationFilterSheet({
    Key? key,
    this.selectedStatus,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  State<ReservationFilterSheet> createState() => _ReservationFilterSheetState();
}

class _ReservationFilterSheetState extends State<ReservationFilterSheet> {
  ReservationStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.blue;
      case ReservationStatus.active:
        return Colors.green;
      case ReservationStatus.completed:
        return Colors.grey;
      case ReservationStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'กรองตามสถานะ',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // All option
          ListTile(
            leading: Icon(Icons.all_inclusive, color: Colors.grey[700]),
            title: Text('ทั้งหมด'),
            trailing: _selectedStatus == null
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () {
              setState(() => _selectedStatus = null);
            },
          ),

          Divider(),

          // Status options
          ...ReservationStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return ListTile(
              leading: Icon(
                Icons.circle,
                color: _getStatusColor(status),
              ),
              title: Text(status.displayName),
              trailing: isSelected
                  ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                  : null,
              onTap: () {
                setState(() => _selectedStatus = status);
              },
            );
          }).toList(),

          SizedBox(height: 2.h),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onFilterApplied(_selectedStatus);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'ใช้ตัวกรอง',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}
