class VehicleModel {
  final String? id;
  final String brand;
  final String model;
  final int year;
  final double pricePerDay;
  final String transmission;
  final int seats;
  final String fuelType;
  final String imageUrl;
  final bool isAvailable;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.transmission,
    required this.seats,
    required this.fuelType,
    required this.imageUrl,
    this.isAvailable = true,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString(),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      pricePerDay: (json['price_per_day'] ?? 0).toDouble(),
      transmission: json['transmission'] ?? 'Manual',
      seats: json['seats'] ?? 4,
      fuelType: json['fuel_type'] ?? 'Petrol',
      imageUrl: json['image_url'] ?? '',
      isAvailable: json['is_available'] ?? true,
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'price_per_day': pricePerDay,
      'transmission': transmission,
      'seats': seats,
      'fuel_type': fuelType,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  VehicleModel copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    double? pricePerDay,
    String? transmission,
    int? seats,
    String? fuelType,
    String? imageUrl,
    bool? isAvailable,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      transmission: transmission ?? this.transmission,
      seats: seats ?? this.seats,
      fuelType: fuelType ?? this.fuelType,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
