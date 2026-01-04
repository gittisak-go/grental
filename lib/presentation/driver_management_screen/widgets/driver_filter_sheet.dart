import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DriverFilterSheet extends StatefulWidget {
  final String selectedFilter;
  final String selectedSort;
  final Function(String filter, String sort) onApply;

  const DriverFilterSheet({
    Key? key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.onApply,
  }) : super(key: key);

  @override
  State<DriverFilterSheet> createState() => _DriverFilterSheetState();
}

class _DriverFilterSheetState extends State<DriverFilterSheet> {
  late String _selectedFilter;
  late String _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
    _selectedSort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Text(
                  'กรองและเรียงลำดับ',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'all';
                      _selectedSort = 'name';
                    });
                  },
                  child: const Text('รีเซ็ต'),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Filter section
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'กรองตามสถานะ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: [
                    _buildFilterChip('ทั้งหมด', 'all'),
                    _buildFilterChip('ออนไลน์', 'online'),
                    _buildFilterChip('กำลังทำงาน', 'busy'),
                    _buildFilterChip('ออฟไลน์', 'offline'),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          // Sort section
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เรียงลำดับตาม',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 1.h),
                _buildSortOption('ชื่อ', 'name', Icons.sort_by_alpha),
                _buildSortOption('คะแนนสูงสุด', 'rating', Icons.star),
                _buildSortOption(
                    'รายได้สูงสุด', 'earnings', Icons.attach_money),
                _buildSortOption('จำนวนเที่ยว', 'trips', Icons.directions_car),
              ],
            ),
          ),

          // Apply button
          Padding(
            padding: EdgeInsets.all(3.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_selectedFilter, _selectedSort);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'ใช้งาน',
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
      labelStyle: TextStyle(
        fontSize: 12.sp,
        color: isSelected ? Colors.blue[700] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _selectedSort == value;
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedSort,
      onChanged: (newValue) {
        setState(() {
          _selectedSort = newValue!;
        });
      },
      title: Row(
        children: [
          Icon(icon,
              size: 20, color: isSelected ? Colors.blue : Colors.grey[600]),
          SizedBox(width: 2.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
