class CarModel {
  final String id;
  final String? ownerId;
  final String brand;
  final String model;
  final int year;
  final String plate;
  final double dailyRate;
  final String status; // available / rented / maintenance / inactive
  final List<String> imageUrls;
  final String? location;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CarModel({
    required this.id,
    this.ownerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.dailyRate,
    required this.status,
    this.imageUrls = const [],
    this.location,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String?,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      year: (json['year'] as num?)?.toInt() ?? 2020,
      plate: json['plate'] as String? ?? '',
      dailyRate: (json['daily_rate'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'available',
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (ownerId != null) 'owner_id': ownerId,
        'brand': brand,
        'model': model,
        'year': year,
        'plate': plate,
        'daily_rate': dailyRate,
        'status': status,
        'image_urls': imageUrls,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
      };

  bool get isAvailable => status == 'available';

  String get displayName => '$brand $model ($year)';

  String get formattedRate => '฿${dailyRate.toStringAsFixed(0)}/วัน';
}
