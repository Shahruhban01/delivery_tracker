import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DateFilterType {
  today,
  yesterday,
  last7Days,
  last15Days,
  custom,
}

class AnalyticsDateFilter extends StatelessWidget {
  final DateFilterType selectedFilter;
  final DateTime startDate;
  final DateTime endDate;
  final Function(DateFilterType, DateTime, DateTime) onFilterChanged;

  const AnalyticsDateFilter({
    Key? key,
    required this.selectedFilter,
    required this.startDate,
    required this.endDate,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                'Today',
                DateFilterType.today,
                () {
                  final now = DateTime.now();
                  onFilterChanged(
                    DateFilterType.today,
                    DateTime(now.year, now.month, now.day),
                    DateTime(now.year, now.month, now.day, 23, 59, 59),
                  );
                },
              ),
              _buildFilterChip(
                'Yesterday',
                DateFilterType.yesterday,
                () {
                  final yesterday = DateTime.now().subtract(const Duration(days: 1));
                  onFilterChanged(
                    DateFilterType.yesterday,
                    DateTime(yesterday.year, yesterday.month, yesterday.day),
                    DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
                  );
                },
              ),
              _buildFilterChip(
                'Last 7 Days',
                DateFilterType.last7Days,
                () {
                  final now = DateTime.now();
                  onFilterChanged(
                    DateFilterType.last7Days,
                    now.subtract(const Duration(days: 7)),
                    now,
                  );
                },
              ),
              _buildFilterChip(
                'Last 15 Days',
                DateFilterType.last15Days,
                () {
                  final now = DateTime.now();
                  onFilterChanged(
                    DateFilterType.last15Days,
                    now.subtract(const Duration(days: 15)),
                    now,
                  );
                },
              ),
              _buildFilterChip(
                'Custom',
                DateFilterType.custom,
                () => _showCustomDatePicker(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: Color(0xFF757575)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${DateFormat('MMM d, yyyy').format(startDate)} - ${DateFormat('MMM d, yyyy').format(endDate)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF212121),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DateFilterType type, VoidCallback onTap) {
    final isSelected = selectedFilter == type;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF757575),
          ),
        ),
      ),
    );
  }

  void _showCustomDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CustomDateRangePicker(
        initialStartDate: startDate,
        initialEndDate: endDate,
        onDateSelected: (start, end) {
          onFilterChanged(DateFilterType.custom, start, end);
        },
      ),
    );
  }
}

class _CustomDateRangePicker extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onDateSelected;

  const _CustomDateRangePicker({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onDateSelected,
  });

  @override
  State<_CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<_CustomDateRangePicker> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Custom Date Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 20),
            _buildDateSelector(
              'Start Date',
              _startDate,
              (date) => setState(() => _startDate = date),
            ),
            const SizedBox(height: 12),
            _buildDateSelector(
              'End Date',
              _endDate,
              (date) => setState(() => _endDate = date),
            ),
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
                    onTap: () {
                      if (_startDate.isBefore(_endDate) || _startDate.isAtSameMomentAs(_endDate)) {
                        widget.onDateSelected(_startDate, _endDate);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Start date must be before end date'),
                            backgroundColor: Color(0xFFF44336),
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
                          'Apply',
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
    );
  }

  Widget _buildDateSelector(String label, DateTime date, Function(DateTime) onDateChanged) {
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
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF2196F3),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF757575)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DateFormat('MMM d, yyyy').format(date),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
