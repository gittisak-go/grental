class FleetVehicleModel {
  final String id;
  final String brand;
  final String model;
  final int year;
  final String licenseplate;
  final String status;
  final String imageUrl;
  final double fuelLevel;
  final double fuelCapacity;
  final double currentMileage;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final DateTime? lastGpsUpdate;
  final DateTime? lastMaintenanceDate;
  final DateTime? nextMaintenanceDate;
  final double utilizationRate;
  final String transmission;
  final int seats;
  final String fuelType;
  final double pricePerDay;

  FleetVehicleModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.licenseplate,
    required this.status,
    required this.imageUrl,
    required this.fuelLevel,
    required this.fuelCapacity,
    required this.currentMileage,
    this.gpsLatitude,
    this.gpsLongitude,
    this.lastGpsUpdate,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    required this.utilizationRate,
    required this.transmission,
    required this.seats,
    required this.fuelType,
    required this.pricePerDay,
  });

  factory FleetVehicleModel.fromJson(Map<String, dynamic> json) {
    return FleetVehicleModel(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      licenseplate: json['license_plate'] as String? ?? '',
      status: json['status'] as String? ?? 'available',
      imageUrl: json['image_url'] as String,
      fuelLevel: (json['fuel_level'] as num?)?.toDouble() ?? 100.0,
      fuelCapacity: (json['fuel_capacity'] as num?)?.toDouble() ?? 50.0,
      currentMileage: (json['current_mileage'] as num?)?.toDouble() ?? 0.0,
      gpsLatitude: (json['gps_latitude'] as num?)?.toDouble(),
      gpsLongitude: (json['gps_longitude'] as num?)?.toDouble(),
      lastGpsUpdate: json['last_gps_update'] != null
          ? DateTime.parse(json['last_gps_update'] as String)
          : null,
      lastMaintenanceDate: json['last_maintenance_date'] != null
          ? DateTime.parse(json['last_maintenance_date'] as String)
          : null,
      nextMaintenanceDate: json['next_maintenance_date'] != null
          ? DateTime.parse(json['next_maintenance_date'] as String)
          : null,
      utilizationRate: (json['utilization_rate'] as num?)?.toDouble() ?? 0.0,
      transmission: json['transmission'] as String,
      seats: json['seats'] as int,
      fuelType: json['fuel_type'] as String,
      pricePerDay: (json['price_per_day'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get statusColor {
    switch (status) {
      case 'available':
        return '#4CAF50';
      case 'in_use':
        return '#2196F3';
      case 'maintenance':
        return '#FF9800';
      case 'offline':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'available':
        return 'พร้อมใช้งาน';
      case 'in_use':
        return 'กำลังใช้งาน';
      case 'maintenance':
        return 'ซ่อมบำรุง';
      case 'offline':
        return 'ไม่พร้อมใช้';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  double get fuelPercentage => (fuelLevel / fuelCapacity * 100).clamp(0, 100);

  String get gpsLocation {
    if (gpsLatitude != null && gpsLongitude != null) {
      return '${gpsLatitude!.toStringAsFixed(4)}, ${gpsLongitude!.toStringAsFixed(4)}';
    }
    return 'ไม่มีข้อมูล GPS';
  }

  int get daysUntilMaintenance {
    if (nextMaintenanceDate == null) return 0;
    return nextMaintenanceDate!.difference(DateTime.now()).inDays;
  }
}

class MaintenanceScheduleModel {
  final String id;
  final String vehicleId;
  final String serviceType;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String status;
  final String? notes;
  final double? cost;
  final String? technicianName;

  MaintenanceScheduleModel({
    required this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.scheduledDate,
    this.completedDate,
    required this.status,
    this.notes,
    this.cost,
    this.technicianName,
  });

  factory MaintenanceScheduleModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceScheduleModel(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      serviceType: json['service_type'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'] as String)
          : null,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      cost: (json['cost'] as num?)?.toDouble(),
      technicianName: json['technician_name'] as String?,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'scheduled':
        return 'กำหนดการแล้ว';
      case 'completed':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status) {
      case 'pending':
        return '#FF9800';
      case 'scheduled':
        return '#2196F3';
      case 'completed':
        return '#4CAF50';
      case 'cancelled':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }
}
