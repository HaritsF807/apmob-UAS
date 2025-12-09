import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final ApiService _apiService = ApiService();
  Order? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getOrderDetail(widget.orderId);
      setState(() {
        _order = Order.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(AppConstants.primaryColorValue),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Order not found'))
              : RefreshIndicator(
                  onRefresh: _loadOrderDetail,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Info Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Order Number',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    _buildStatusBadge(_order!.status),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _order!.orderNumber,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_order!.createdAt != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    Formatters.formatDateTime(_order!.createdAt!),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Customer Info
                        if (_order!.customerName != null ||
                            _order!.tableNumber != null) ...[
                          const Text(
                            'Customer Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  if (_order!.customerName != null)
                                    _buildInfoRow(
                                      Icons.person,
                                      'Name',
                                      _order!.customerName!,
                                    ),
                                  if (_order!.customerPhone != null)
                                    _buildInfoRow(
                                      Icons.phone,
                                      'Phone',
                                      _order!.customerPhone!,
                                    ),
                                  if (_order!.tableNumber != null)
                                    _buildInfoRow(
                                      Icons.table_restaurant,
                                      'Table',
                                      _order!.tableNumber!,
                                    ),
                                  if (_order!.orderType != null)
                                    _buildInfoRow(
                                      Icons.shopping_bag,
                                      'Type',
                                      _order!.orderType!,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Order Items
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._order!.items.map((item) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      const Color(AppConstants.primaryColorValue)
                                          .withOpacity(0.1),
                                  child: Text(
                                    '${item.quantity}x',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(AppConstants.primaryColorValue),
                                    ),
                                  ),
                                ),
                                title: Text(item.productName),
                                subtitle: item.variant != null
                                    ? Text('Variant: ${item.variant}')
                                    : null,
                                trailing: Text(
                                  Formatters.formatCurrency(item.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )),
                        const SizedBox(height: 16),

                        // Payment Summary
                        Card(
                          color: const Color(AppConstants.primaryColorValue)
                              .withOpacity(0.05),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: const Color(AppConstants.primaryColorValue)
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildPriceRow('Subtotal',
                                    Formatters.formatCurrency(_order!.subtotal)),
                                if (_order!.tax > 0)
                                  _buildPriceRow('Tax',
                                      Formatters.formatCurrency(_order!.tax)),
                                const Divider(height: 20),
                                _buildPriceRow(
                                  'Total',
                                  Formatters.formatCurrency(_order!.total),
                                  isTotal: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'processing':
        color = Colors.blue;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isTotal
                  ? const Color(AppConstants.primaryColorValue)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
