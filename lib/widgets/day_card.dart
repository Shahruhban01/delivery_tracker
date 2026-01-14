import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_sheet.dart';
import 'custom_card.dart';

class DayCard extends StatelessWidget {
  final DailySheet sheet;
  final VoidCallback onTap;
  final VoidCallback? onClose;

  const DayCard({
    Key? key,
    required this.sheet,
    required this.onTap,
    this.onClose,
  }) : super(key: key);

  Color _getTypeColor() {
    return sheet.type == SheetType.runsheet
        ? const Color(0xFF2196F3)
        : const Color(0xFFFF9800);
  }

  IconData _getTypeIcon() {
    return sheet.type == SheetType.runsheet
        ? Icons.local_shipping
        : Icons.assignment_return;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(),
                  size: 20,
                  color: _getTypeColor(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(sheet.date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sheet.area,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              if (sheet.isClosed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF757575).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 14,
                        color: Color(0xFF757575),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Closed',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (sheet.isCompleted && !sheet.isClosed)
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Close Sheet',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetric('Picked', sheet.picked, const Color(0xFF2196F3)),
              ),
              Expanded(
                child: _buildMetric('Delivered', sheet.delivered, const Color(0xFF4CAF50)),
              ),
              Expanded(
                child: _buildMetric('Failed', sheet.failed, const Color(0xFFF44336)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Returns',
                  '${sheet.completedReturns}/${sheet.assignedReturns}',
                  const Color(0xFFFF9800),
                ),
              ),
              Expanded(
                child: _buildMetric('Earnings', '₹${sheet.earnings.toStringAsFixed(0)}', const Color(0xFF4CAF50)),
              ),
              Expanded(
                child: _buildMetric('Petrol', '₹${sheet.petrol.toStringAsFixed(0)}', const Color(0xFF9C27B0)),
              ),
            ],
          ),
          if (sheet.isCompleted && !sheet.isClosed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF4CAF50),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All customers processed. Close sheet to finalize.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, dynamic value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
