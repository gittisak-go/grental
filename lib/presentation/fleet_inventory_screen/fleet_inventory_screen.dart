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

  void _filterVehicles() {
    setState(() {
      _filteredVehicles = _vehicles.where((vehicle) {
        final matchesSearch = _searchQuery.isEmpty ||
            vehicle.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            vehicle.model.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            vehicle.licenseplate
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        final matchesStatus =
            _selectedStatus == 'all' || vehicle.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FleetFilterSheet(
        currentStatus: _selectedStatus,
        onApplyFilter: (status) {
          setState(() => _selectedStatus = status);
          _filterVehicles();
        },
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
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.black87),
            onPressed: _showFilterSheet,
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
                if (_selectedStatus != 'all')
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'กรอง: $_selectedStatus',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedStatus = 'all');
                            _filterVehicles();
                          },
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
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
                              'ไม่พบรถในระบบ',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
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
