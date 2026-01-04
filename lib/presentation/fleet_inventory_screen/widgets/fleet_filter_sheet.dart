import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class FleetFilterSheet extends StatefulWidget {
  final String currentStatus;
  final Function(String) onApplyFilter;

  const FleetFilterSheet({
    super.key,
    required this.currentStatus,
    required this.onApplyFilter,
  });

  @override
  State<FleetFilterSheet> createState() => _FleetFilterSheetState();
}

class _FleetFilterSheetState extends State<FleetFilterSheet> {
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
  }

  final Map<String, String> _statusOptions = {
    'all': 'ทั้งหมด',
    'available': 'พร้อมใช้งาน',
    'in_use': 'กำลังใช้งาน',
    'maintenance': 'ซ่อมบำรุง',
    'offline': 'ไม่พร้อมใช้',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'กรองตามสถานะ',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 2.h),
          ..._statusOptions.entries.map((entry) {
            final isSelected = _selectedStatus == entry.key;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedStatus = entry.key);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 1.5.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withAlpha(26)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300]!,
                    width: 2.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400],
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _selectedStatus = 'all');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text('รีเซ็ต', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilter(_selectedStatus);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text('ใช้ตัวกรอง', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
        ],
      ),
    );
  }
}
