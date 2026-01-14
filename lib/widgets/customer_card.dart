import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import 'custom_card.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final Function(int) onCallCountChanged;
  final Function(String, String?) onStatusChanged;
  final bool isReadOnly;

  const CustomerCard({
    Key? key,
    required this.customer,
    required this.onTap,
    required this.onCallCountChanged,
    required this.onStatusChanged,
    this.isReadOnly = false,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF4CAF50);
      case 'Cancelled with Code (RTO)':
        return const Color(0xFFF44336);
      case 'Confirmed (will accept)':
        return const Color(0xFF2196F3);
      case 'Heavy Load':
        return const Color(0xFFFF9800);
      case 'Reschedule':
        return const Color(0xFF9C27B0);
      case 'Not Responding':
        return const Color(0xFF757575);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color _getCardBackgroundColor() {
    final colorState = customer.getColorState();
    
    switch (colorState) {
      case CustomerColorState.red:
        return const Color(0xFFFFEBEE); // Light red
      case CustomerColorState.yellow:
        return const Color(0xFFFFF9C4); // Light yellow
      case CustomerColorState.green:
        return const Color(0xFFE8F5E9); // Light green
      case CustomerColorState.oliveGreen:
        return const Color(0xFFF1F8E9); // Light olive
      case CustomerColorState.normal:
        return Colors.white;
    }
  }

  Color _getCardBorderColor() {
    final colorState = customer.getColorState();
    
    switch (colorState) {
      case CustomerColorState.red:
        return const Color(0xFFE57373);
      case CustomerColorState.yellow:
        return const Color(0xFFFFD54F);
      case CustomerColorState.green:
        return const Color(0xFF81C784);
      case CustomerColorState.oliveGreen:
        return const Color(0xFF9CCC65);
      case CustomerColorState.normal:
        return const Color(0xFFE0E0E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getCardBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getCardBorderColor(), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(customer.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        customer.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusColor(customer.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  customer.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF616161),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Text(
                      customer.area,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.phone, size: 14, color: Color(0xFF757575)),
                    const SizedBox(width: 4),
                    Text(
                      customer.phone,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                if (!isReadOnly) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (customer.callCount > 0) {
                            onCallCountChanged(customer.callCount - 1);
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 18,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          Text(
                            '${customer.callCount}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const Text(
                            'calls',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          onCallCountChanged(customer.callCount + 1);
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (customer.lastCallTime != null)
                        Text(
                          'Last: ${timeFormat.format(customer.lastCallTime!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF757575),
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _showStatusDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1976D2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 18,
                                color: Color(0xFF1976D2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (customer.notes != null && customer.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.note,
                          size: 14,
                          color: Color(0xFFF57F17),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.notes!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF57F17),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (customer.lastEditedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.edit, size: 12, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 4),
                      Text(
                        'Edited ${DateFormat('MMM d, HH:mm').format(customer.lastEditedAt!)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9E9E9E),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context) {
    if (isReadOnly) return;
    
    final statuses = [
      'Pending',
      'Confirmed (will accept)',
      'Not Responding',
      'Cancelled with Code (RTO)',
      'Delivered',
      'Heavy Load',
      'Reschedule',
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              ...statuses.map((status) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    if (status != customer.status) {
                      _showNotesDialog(context, status);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 14,
                              color: status == customer.status
                                  ? const Color(0xFF2196F3)
                                  : const Color(0xFF212121),
                              fontWeight: status == customer.status
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (status == customer.status)
                          const Icon(
                            Icons.check,
                            size: 18,
                            color: Color(0xFF2196F3),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, String newStatus) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Notes (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter notes...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onStatusChanged(newStatus, null);
                      },
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'Skip',
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
                      onTap: () {
                        final notes = notesController.text.trim();
                        Navigator.pop(context);
                        onStatusChanged(
                          newStatus,
                          notes.isEmpty ? null : notes,
                        );
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
    );
  }
}
