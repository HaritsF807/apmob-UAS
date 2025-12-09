class DashboardStats {
  final double totalRevenue;
  final int totalOrders;
  final double todaySales;
  final int todayOrders;
  final int pendingOrders;
  final int completedOrders;
  final List<SalesData>? salesData;

  DashboardStats({
    this.totalRevenue = 0.0,
    this.totalOrders = 0,
    this.todaySales = 0.0,
    this.todayOrders = 0,
    this.pendingOrders = 0,
    this.completedOrders = 0,
    this.salesData,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalRevenue: _parseDouble(json['total_revenue']),
      totalOrders: json['total_orders'] is String 
          ? int.tryParse(json['total_orders']) ?? 0 
          : (json['total_orders'] ?? 0),
      todaySales: _parseDouble(json['today_sales']),
      todayOrders: json['today_orders'] is String 
          ? int.tryParse(json['today_orders']) ?? 0 
          : (json['today_orders'] ?? 0),
      pendingOrders: json['pending_orders'] is String 
          ? int.tryParse(json['pending_orders']) ?? 0 
          : (json['pending_orders'] ?? 0),
      completedOrders: json['completed_orders'] is String 
          ? int.tryParse(json['completed_orders']) ?? 0 
          : (json['completed_orders'] ?? 0),
      salesData: json['sales_data'] != null
          ? (json['sales_data'] as List)
              .map((s) => SalesData.fromJson(s))
              .toList()
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
}

class SalesData {
  final String date;
  final double amount;
  final int orderCount;

  SalesData({
    required this.date,
    required this.amount,
    this.orderCount = 0,
  });

  factory SalesData.fromJson(Map<String, dynamic> json) {
    return SalesData(
      date: json['date']?.toString() ?? '',
      amount: DashboardStats._parseDouble(json['amount'] ?? json['total']),
      orderCount: json['order_count'] is String 
          ? int.tryParse(json['order_count']) ?? 0 
          : (json['order_count'] ?? 0),
    );
  }
}
