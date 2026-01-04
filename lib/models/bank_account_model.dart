class BankAccountModel {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String? branch;
  final String accountType;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.branch,
    required this.accountType,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String,
      bankName: json['bank_name'] as String,
      accountNumber: json['account_number'] as String,
      accountName: json['account_name'] as String,
      branch: json['branch'] as String?,
      accountType: json['account_type'] as String,
      isActive: json['is_active'] as bool,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
      'branch': branch,
      'account_type': accountType,
      'is_active': isActive,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class RentalTermModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RentalTermModel({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.displayOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentalTermModel.fromJson(Map<String, dynamic> json) {
    return RentalTermModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      displayOrder: json['display_order'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
