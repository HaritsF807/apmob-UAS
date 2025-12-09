class TableModel {
  final String? id;
  final String tableNumber;
  final int capacity;
  final String status; // 'available', 'occupied', 'reserved'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TableModel({
    this.id,
    required this.tableNumber,
    required this.capacity,
    this.status = 'available',
    this.createdAt,
    this.updatedAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id']?.toString(),
      tableNumber: json['table_number']?.toString() ?? json['number']?.toString() ?? '',
      capacity: json['capacity'] is String 
          ? int.tryParse(json['capacity']) ?? 2 
          : (json['capacity'] ?? 2),
      status: json['status'] ?? 'available',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status,
    };
  }

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isReserved => status == 'reserved';
}
