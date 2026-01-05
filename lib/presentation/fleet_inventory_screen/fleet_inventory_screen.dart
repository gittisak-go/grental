import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../models/fleet_vehicle_model.dart';
import '../../services/fleet_service.dart';
import './widgets/fleet_filter_sheet.dart';
import './widgets/fleet_vehicle_card.dart';
import './widgets/vehicle_details_modal.dart';

class FleetInventoryScreen extends StatefulWidget {
  const FleetInventoryScreen({super.key});

  @override
  State<FleetInventoryScreen> createState() => _FleetInventoryScreenState();
}

class _FleetInventoryScreenState extends State<FleetInventoryScreen> {
  final FleetService _fleetService = FleetService();
  List<FleetVehicleModel> _vehicles = [];
  List<FleetVehicleModel> _filteredVehicles = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  double? _minPrice;
  double? _maxPrice;
  List<String> _selectedTransmissions = [];
  List<String> _selectedFuelTypes = [];
  int? _selectedSeats;
  DateTime? _availabilityStartDate;
  DateTime? _availabilityEndDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFleetVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFleetVehicles() async {
    setState(() => _isLoading = true);
    try {
      final vehicles = await _fleetService.getFleetVehicles();
      setState(() {
        _vehicles = vehicles;
        _filteredVehicles = vehicles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<void> _filterVehicles() async {
    setState(() => _isLoading = true);

    try {
      List<FleetVehicleModel> filtered = List.from(_vehicles);

      // Search filter
      if (_searchQuery.isNotEmpty) {
        filtered = filtered.where((vehicle) {
          return vehicle.brand
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              vehicle.model
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              vehicle.licenseplate
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
        }).toList();
      }

      // Status filter
      if (_selectedStatus != 'all') {
        filtered = filtered
            .where((vehicle) => vehicle.status == _selectedStatus)
            .toList();
      }

      // Price range filter
      if (_minPrice != null || _maxPrice != null) {
        filtered = await _fleetService.filterByPriceRange(
          filtered.map((v) => v.id).toList(),
          _minPrice,
          _maxPrice,
        );
      }

      // Transmission filter
      if (_selectedTransmissions.isNotEmpty) {
        filtered = filtered.where((vehicle) {
          return _selectedTransmissions.contains(vehicle.transmission);
        }).toList();
      }

      // Fuel type filter
      if (_selectedFuelTypes.isNotEmpty) {
        filtered = filtered.where((vehicle) {
          return _selectedFuelTypes.contains(vehicle.fuelType);
        }).toList();
      }

      // Seats filter
      if (_selectedSeats != null) {
        filtered = filtered
            .where((vehicle) => vehicle.seats == _selectedSeats)
            .toList();
      }

      // Availability date filter
      if (_availabilityStartDate != null && _availabilityEndDate != null) {
        final availableVehicleIds = await _fleetService.checkAvailability(
          _availabilityStartDate!,
          _availabilityEndDate!,
        );
        filtered = filtered.where((vehicle) {
          return availableVehicleIds.contains(vehicle.id);
        }).toList();
      }

      setState(() {
        _filteredVehicles = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการกรอง: $e')),
        );
      }
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: 80.h,
        child: FleetFilterSheet(
          currentStatus: _selectedStatus,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          selectedTransmissions: _selectedTransmissions,
          selectedFuelTypes: _selectedFuelTypes,
          selectedSeats: _selectedSeats,
          availabilityStartDate: _availabilityStartDate,
          availabilityEndDate: _availabilityEndDate,
          onApplyFilter: ({
            required String status,
            double? minPrice,
            double? maxPrice,
            List<String>? transmissions,
            List<String>? fuelTypes,
            int? seats,
            DateTime? startDate,
            DateTime? endDate,
          }) {
            setState(() {
              _selectedStatus = status;
              _minPrice = minPrice;
              _maxPrice = maxPrice;
              _selectedTransmissions = transmissions ?? [];
              _selectedFuelTypes = fuelTypes ?? [];
              _selectedSeats = seats;
              _availabilityStartDate = startDate;
              _availabilityEndDate = endDate;
            });
            _filterVehicles();
          },
        ),
      ),
    );
  }

  void _showVehicleDetails(FleetVehicleModel vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleDetailsModal(
        vehicle: vehicle,
        onStatusChanged: () => _loadFleetVehicles(),
      ),
    );
  }

  bool get _hasActiveFilters {
    return _selectedStatus != 'all' ||
        _minPrice != null ||
        _maxPrice != null ||
        _selectedTransmissions.isNotEmpty ||
        _selectedFuelTypes.isNotEmpty ||
        _selectedSeats != null ||
        _availabilityStartDate != null;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedStatus != 'all') count++;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_selectedTransmissions.isNotEmpty) count++;
    if (_selectedFuelTypes.isNotEmpty) count++;
    if (_selectedSeats != null) count++;
    if (_availabilityStartDate != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Fleet Inventory',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.filter_list, color: Colors.black87),
                onPressed: _showFilterSheet,
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(0.5.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 4.w,
                      minHeight: 4.w,
                    ),
                    child: Center(
                      child: Text(
                        '$_activeFilterCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadFleetVehicles,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(3.w),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _filterVehicles();
              },
              decoration: InputDecoration(
                hintText: 'ค้นหารถ (ยี่ห้อ, รุ่น, ทะเบียน)',
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, size: 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _filterVehicles();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'พบ ${_filteredVehicles.length} คัน',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                if (_hasActiveFilters)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = 'all';
                        _minPrice = null;
                        _maxPrice = null;
                        _selectedTransmissions = [];
                        _selectedFuelTypes = [];
                        _selectedSeats = null;
                        _availabilityStartDate = null;
                        _availabilityEndDate = null;
                      });
                      _filterVehicles();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ตัวกรอง: $_activeFilterCount',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredVehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_outlined,
                                size: 60.sp, color: Colors.grey[400]),
                            SizedBox(height: 2.h),
                            Text(
                              'ไม่พบรถที่ตรงกับเงื่อนไข',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 1.h),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedStatus = 'all';
                                  _minPrice = null;
                                  _maxPrice = null;
                                  _selectedTransmissions = [];
                                  _selectedFuelTypes = [];
                                  _selectedSeats = null;
                                  _availabilityStartDate = null;
                                  _availabilityEndDate = null;
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                                _filterVehicles();
                              },
                              child: Text('ล้างตัวกรอง'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFleetVehicles,
                        child: GridView.builder(
                          padding: EdgeInsets.all(3.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredVehicles.length,
                          itemBuilder: (context, index) {
                            return FleetVehicleCard(
                              vehicle: _filteredVehicles[index],
                              onTap: () =>
                                  _showVehicleDetails(_filteredVehicles[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
