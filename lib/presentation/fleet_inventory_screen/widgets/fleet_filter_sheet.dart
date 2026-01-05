import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FleetFilterSheet extends StatefulWidget {
  final String currentStatus;
  final double? minPrice;
  final double? maxPrice;
  final List<String> selectedTransmissions;
  final List<String> selectedFuelTypes;
  final int? selectedSeats;
  final DateTime? availabilityStartDate;
  final DateTime? availabilityEndDate;
  final Function({
    required String status,
    double? minPrice,
    double? maxPrice,
    List<String>? transmissions,
    List<String>? fuelTypes,
    int? seats,
    DateTime? startDate,
    DateTime? endDate,
  }) onApplyFilter;

  const FleetFilterSheet({
    super.key,
    required this.currentStatus,
    this.minPrice,
    this.maxPrice,
    this.selectedTransmissions = const [],
    this.selectedFuelTypes = const [],
    this.selectedSeats,
    this.availabilityStartDate,
    this.availabilityEndDate,
    required this.onApplyFilter,
  });

  @override
  State<FleetFilterSheet> createState() => _FleetFilterSheetState();
}

class _FleetFilterSheetState extends State<FleetFilterSheet> {
  late String _selectedStatus;
  late RangeValues _priceRange;
  late Set<String> _selectedTransmissions;
  late Set<String> _selectedFuelTypes;
  int? _selectedSeats;
  DateTime? _startDate;
  DateTime? _endDate;

  final double _minPrice = 0;
  final double _maxPrice = 5000;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _priceRange = RangeValues(
      widget.minPrice ?? _minPrice,
      widget.maxPrice ?? _maxPrice,
    );
    _selectedTransmissions = Set.from(widget.selectedTransmissions);
    _selectedFuelTypes = Set.from(widget.selectedFuelTypes);
    _selectedSeats = widget.selectedSeats;
    _startDate = widget.availabilityStartDate;
    _endDate = widget.availabilityEndDate;
  }

  final Map<String, String> _statusOptions = {
    'all': 'ทั้งหมด',
    'available': 'พร้อมใช้งาน',
    'in_use': 'กำลังใช้งาน',
    'maintenance': 'ซ่อมบำรุง',
    'offline': 'ไม่พร้อมใช้',
  };

  final List<String> _transmissionOptions = ['Automatic', 'Manual'];
  final List<String> _fuelTypeOptions = [
    'Petrol',
    'Diesel',
    'Hybrid',
    'Electric'
  ];
  final List<int> _seatsOptions = [4, 5, 7, 8];

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedStatus = 'all';
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _selectedTransmissions.clear();
      _selectedFuelTypes.clear();
      _selectedSeats = null;
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ตัวกรองขั้นสูง',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      child: Text(
                        'รีเซ็ตทั้งหมด',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter
                  Text(
                    'สถานะรถ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _statusOptions.entries.map((entry) {
                      final isSelected = _selectedStatus == entry.key;
                      return FilterChip(
                        label: Text(entry.value),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedStatus = entry.key);
                        },
                        backgroundColor: Colors.grey[50],
                        selectedColor:
                            Theme.of(context).primaryColor.withAlpha(51),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 2.h),

                  // Price Range Filter
                  Text(
                    'ช่วงราคา (฿${_priceRange.start.round()} - ฿${_priceRange.end.round()})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _minPrice,
                    max: _maxPrice,
                    divisions: 50,
                    activeColor: Theme.of(context).primaryColor,
                    labels: RangeLabels(
                      '฿${_priceRange.start.round()}',
                      '฿${_priceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                  SizedBox(height: 2.h),

                  // Transmission Filter
                  Text(
                    'ระบบเกียร์',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _transmissionOptions.map((transmission) {
                      final isSelected =
                          _selectedTransmissions.contains(transmission);
                      return FilterChip(
                        label: Text(transmission),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTransmissions.add(transmission);
                            } else {
                              _selectedTransmissions.remove(transmission);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[50],
                        selectedColor:
                            Theme.of(context).primaryColor.withAlpha(51),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 2.h),

                  // Fuel Type Filter
                  Text(
                    'ประเภทเชื้อเพลิง',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _fuelTypeOptions.map((fuelType) {
                      final isSelected = _selectedFuelTypes.contains(fuelType);
                      return FilterChip(
                        label: Text(fuelType),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFuelTypes.add(fuelType);
                            } else {
                              _selectedFuelTypes.remove(fuelType);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[50],
                        selectedColor:
                            Theme.of(context).primaryColor.withAlpha(51),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 2.h),

                  // Seats Filter
                  Text(
                    'จำนวนที่นั่ง',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _seatsOptions.map((seats) {
                      final isSelected = _selectedSeats == seats;
                      return FilterChip(
                        label: Text('$seats ที่นั่ง'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSeats = selected ? seats : null;
                          });
                        },
                        backgroundColor: Colors.grey[50],
                        selectedColor:
                            Theme.of(context).primaryColor.withAlpha(51),
                        checkmarkColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          fontSize: 12.sp,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black87,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 2.h),

                  // Availability Date Range
                  Text(
                    'ช่วงวันที่ต้องการ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  InkWell(
                    onTap: _selectDateRange,
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 20.sp,
                              color: Theme.of(context).primaryColor),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              _startDate != null && _endDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'เลือกช่วงวันที่',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: _startDate != null
                                    ? Colors.black87
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                          if (_startDate != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _startDate = null;
                                  _endDate = null;
                                });
                              },
                              child: Icon(Icons.clear,
                                  size: 20.sp, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8.0,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilter(
                  status: _selectedStatus,
                  minPrice: _priceRange.start,
                  maxPrice: _priceRange.end,
                  transmissions: _selectedTransmissions.toList(),
                  fuelTypes: _selectedFuelTypes.toList(),
                  seats: _selectedSeats,
                  startDate: _startDate,
                  endDate: _endDate,
                );
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
    );
  }
}
