import 'package:delivery_tracker/widgets/custom_pull_to_refresh.dart';
import 'package:delivery_tracker/widgets/custom_refresh_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/daily_sheet.dart';
import '../../models/customer.dart';
import '../../models/call_log.dart';
import '../../models/status_change.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/draggable_customer_list.dart';
import '../customer_detail/customer_detail_screen.dart';

class DayDetailsScreen extends StatefulWidget {
  final DailySheet sheet;

  const DayDetailsScreen({Key? key, required this.sheet}) : super(key: key);

  @override
  State<DayDetailsScreen> createState() => _DayDetailsScreenState();
}

class _DayDetailsScreenState extends State<DayDetailsScreen> {
  String _searchQuery = '';
  bool _isRefreshing = false;

  final TextEditingController _earningsController = TextEditingController();
  final TextEditingController _petrolController = TextEditingController();
  final TextEditingController _pickedController = TextEditingController();
  final TextEditingController _deliveredController = TextEditingController();
  final TextEditingController _failedController = TextEditingController();
  final TextEditingController _assignedReturnsController =
      TextEditingController();
  final TextEditingController _completedReturnsController =
      TextEditingController();
  final TextEditingController _failedReturnsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _earningsController.text = widget.sheet.earnings.toStringAsFixed(0);
    _petrolController.text = widget.sheet.petrol.toStringAsFixed(0);
    _pickedController.text = widget.sheet.picked.toString();
    _deliveredController.text = widget.sheet.delivered.toString();
    _failedController.text = widget.sheet.failed.toString();
    _assignedReturnsController.text = widget.sheet.assignedReturns.toString();
    _completedReturnsController.text = widget.sheet.completedReturns.toString();
    _failedReturnsController.text = widget.sheet.failedReturns.toString();
  }

  @override
  void dispose() {
    _earningsController.dispose();
    _petrolController.dispose();
    _pickedController.dispose();
    _deliveredController.dispose();
    _failedController.dispose();
    _assignedReturnsController.dispose();
    _completedReturnsController.dispose();
    _failedReturnsController.dispose();
    super.dispose();
  }

  List<Customer> _filterCustomers(List<Customer> customers) {
    if (_searchQuery.isEmpty) return customers;

    final query = _searchQuery.toLowerCase();
    return customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.address.toLowerCase().contains(query) ||
          customer.phone.contains(query) ||
          customer.area.toLowerCase().contains(query) ||
          customer.status.toLowerCase().contains(query) ||
          (customer.notes?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _updateDailyMetrics(FirestoreService service) async {
    await service.updateDailySheet(widget.sheet.id, {
      'earnings': double.tryParse(_earningsController.text) ?? 0.0,
      'petrol': double.tryParse(_petrolController.text) ?? 0.0,
      'picked': int.tryParse(_pickedController.text) ?? 0,
      'delivered': int.tryParse(_deliveredController.text) ?? 0,
      'failed': int.tryParse(_failedController.text) ?? 0,
      'assignedReturns': int.tryParse(_assignedReturnsController.text) ?? 0,
      'completedReturns': int.tryParse(_completedReturnsController.text) ?? 0,
      'failedReturns': int.tryParse(_failedReturnsController.text) ?? 0,
    });
  }

  void _showMetricsDialog(FirestoreService service) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Daily Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMetricField('Picked', _pickedController),
                const SizedBox(height: 12),
                _buildMetricField('Delivered', _deliveredController),
                const SizedBox(height: 12),
                _buildMetricField('Failed', _failedController),
                const SizedBox(height: 12),
                _buildMetricField(
                    'Assigned Returns', _assignedReturnsController),
                const SizedBox(height: 12),
                _buildMetricField(
                    'Completed Returns', _completedReturnsController),
                const SizedBox(height: 12),
                _buildMetricField('Failed Returns', _failedReturnsController),
                const SizedBox(height: 12),
                _buildMetricField('Earnings (₹)', _earningsController),
                const SizedBox(height: 12),
                _buildMetricField('Petrol (₹)', _petrolController),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF757575),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          await _updateDailyMetrics(service);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Metrics updated'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final firestoreService = FirestoreService(auth.currentUser!.uid);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(widget.sheet.date),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            Text(
              widget.sheet.area,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
        actions: [
          CustomRefreshButton(
            onRefresh: _handleRefresh,
            isLoading: _isRefreshing,
          ),
          GestureDetector(
            onTap: () => _showMetricsDialog(firestoreService),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.edit,
                color: Color(0xFF757575),
                size: 22,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: CustomSearchBar(
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              hint: 'Search customers...',
            ),
          ),
          Expanded(
            child: CustomPullToRefresh(
              onRefresh: _handleRefresh,
              child: StreamBuilder<List<Customer>>(
                stream: firestoreService.getCustomersByDay(widget.sheet.id),
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No customers found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  );
                }

                final filteredCustomers = _filterCustomers(snapshot.data!);

                if (filteredCustomers.isEmpty) {
                  return const Center(
                    child: Text(
                      'No matching customers',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                  );
                }

                return DraggableCustomerList(
                  customers: filteredCustomers,
                  onCustomerTap: (customer) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomerDetailScreen(customer: customer),
                      ),
                    );
                  },
                  onCallCountChanged: (customer, count) async {
                    await firestoreService.updateCustomer(customer.id, {
                      'callCount': count,
                      'lastCallTime': DateTime.now(),
                    });

                    await firestoreService.createCallLog(
                      CallLog(
                        id: '',
                        customerId: customer.id,
                        dayId: customer.dayId,
                        attemptNumber: count,
                        timestamp: DateTime.now(),
                      ),
                    );
                  },
                  onStatusChanged: (customer, status, notes) async {
                    final oldStatus = customer.status;

                    await firestoreService.updateCustomer(customer.id, {
                      'status': status,
                      if (notes != null) 'notes': notes,
                    });

                    await firestoreService.createStatusChange(
                      StatusChange(
                        id: '',
                        customerId: customer.id,
                        dayId: customer.dayId,
                        oldStatus: oldStatus,
                        newStatus: status,
                        notes: notes,
                        timestamp: DateTime.now(),
                      ),
                    );
                  },
                  onReorder: (reorderedCustomers) async {
                    for (var i = 0; i < reorderedCustomers.length; i++) {
                      await firestoreService.updateCustomerOrder(
                        reorderedCustomers[i].id,
                        i,
                      );
                    }
                  },
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
