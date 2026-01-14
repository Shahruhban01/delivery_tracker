import 'package:flutter/material.dart';
import '../models/customer.dart';
import 'customer_card.dart';

class DraggableCustomerList extends StatefulWidget {
  final List<Customer> customers;
  final Function(Customer) onCustomerTap;
  final Function(Customer, int) onCallCountChanged;
  final Function(Customer, String, String?) onStatusChanged;
  final Function(List<Customer>) onReorder;

  const DraggableCustomerList({
    Key? key,
    required this.customers,
    required this.onCustomerTap,
    required this.onCallCountChanged,
    required this.onStatusChanged,
    required this.onReorder,
  }) : super(key: key);

  @override
  State<DraggableCustomerList> createState() => _DraggableCustomerListState();
}

class _DraggableCustomerListState extends State<DraggableCustomerList> {
  late List<Customer> _customers;
  Map<String, bool> _expandedAreas = {};

  @override
  void initState() {
    super.initState();
    _customers = List.from(widget.customers);
    _initializeExpandedAreas();
  }

  @override
  void didUpdateWidget(DraggableCustomerList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customers != oldWidget.customers) {
      _customers = List.from(widget.customers);
      _initializeExpandedAreas();
    }
  }

  void _initializeExpandedAreas() {
    final areas = _customers.map((c) => c.area).toSet();
    for (final area in areas) {
      _expandedAreas[area] ??= true;
    }
  }

  Map<String, List<Customer>> _groupByArea() {
    final Map<String, List<Customer>> grouped = {};
    for (final customer in _customers) {
      grouped.putIfAbsent(customer.area, () => []).add(customer);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByArea();
    final areas = grouped.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: areas.length,
      itemBuilder: (context, index) {
        final area = areas[index];
        final customers = grouped[area]!;
        final isExpanded = _expandedAreas[area] ?? true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedAreas[area] = !isExpanded;
                });
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$area (${customers.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              ...customers.map((customer) {
                return LongPressDraggable<Customer>(
                  data: customer,
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Opacity(
                      opacity: 0.8,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 32,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: CustomerCard(
                      customer: customer,
                      onTap: () {},
                      onCallCountChanged: (_) {},
                      onStatusChanged: (_, __) {},
                    ),
                  ),
                  child: DragTarget<Customer>(
                    onAcceptWithDetails: (details) {
                      final draggedCustomer = details.data;
                      if (draggedCustomer.id != customer.id) {
                        setState(() {
                          final oldIndex = _customers.indexWhere((c) => c.id == draggedCustomer.id);
                          final newIndex = _customers.indexWhere((c) => c.id == customer.id);
                          
                          _customers.removeAt(oldIndex);
                          _customers.insert(newIndex, draggedCustomer);
                          
                          widget.onReorder(_customers);
                        });
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return CustomerCard(
                        customer: customer,
                        onTap: () => widget.onCustomerTap(customer),
                        onCallCountChanged: (count) => widget.onCallCountChanged(customer, count),
                        onStatusChanged: (status, notes) => widget.onStatusChanged(customer, status, notes),
                      );
                    },
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }
}
