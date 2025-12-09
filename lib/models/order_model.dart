class Order {
  final String? id;
  final String orderNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String status; // 'pending', 'processing', 'completed', 'cancelled'
  final String? paymentMethod;
  final String? paymentStatus;
  final String? customerName;
  final String? customerPhone;
  final String? tableNumber;
  final String? orderType; // 'dine_in', 'takeaway'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    required this.total,
    this.status = 'pending',
    this.paymentMethod,
    this.paymentStatus,
    this.customerName,
    this.customerPhone,
    this.tableNumber,
    this.orderType,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString(),
      orderNumber: json['order_number']?.toString() ?? json['id']?.toString() ?? '',
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : [],
      subtotal: _parseDouble(json['subtotal'] ?? json['total_price']),
      tax: _parseDouble(json['tax']),
      total: _parseDouble(json['total'] ?? json['total_price']),
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      tableNumber: json['table_number']?.toString(),
      orderType: json['order_type'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'order_number': orderNumber,
      'items': items.map((i) => i.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (customerName != null) 'customer_name': customerName,
      if (customerPhone != null) 'customer_phone': customerPhone,
      if (tableNumber != null) 'table_number': tableNumber,
      if (orderType != null) 'order_type': orderType,
    };
  }
}

class OrderItem {
  final String? id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;
  final String? variant;
  final String? notes;

  OrderItem({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
    this.variant,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id']?.toString(),
      productId: json['product_id']?.toString() ?? '',
      productName: json['product_name'] ?? json['name'] ?? '',
      quantity: json['quantity'] is String 
          ? int.tryParse(json['quantity']) ?? 1 
          : (json['quantity'] ?? 1),
      price: Order._parseDouble(json['price']),
      total: Order._parseDouble(json['total']),
      variant: json['variant'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
      if (variant != null) 'variant': variant,
      if (notes != null) 'notes': notes,
    };
  }
}
