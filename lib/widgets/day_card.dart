import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_sheet.dart';
import 'custom_card.dart';

class DayCard extends StatelessWidget {
  final DailySheet sheet;
  final VoidCallback onTap;

  const DayCard({
    Key? key,
    required this.sheet,
    required this.onTap,
  }) : super(key: key);

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
              Expanded(
                child: Text(
                  dateFormat.format(sheet.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  sheet.area,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetric('Returns', '${sheet.completedReturns}/${sheet.assignedReturns}', const Color(0xFFFF9800)),
              ),
              Expanded(
                child: _buildMetric('Earnings', '₹${sheet.earnings.toStringAsFixed(0)}', const Color(0xFF4CAF50)),
              ),
              Expanded(
                child: _buildMetric('Petrol', '₹${sheet.petrol.toStringAsFixed(0)}', const Color(0xFF9C27B0)),
              ),
            ],
          ),
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
