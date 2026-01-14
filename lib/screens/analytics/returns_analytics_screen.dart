import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_refresh_button.dart';
import '../../widgets/custom_pull_to_refresh.dart';
import '../../widgets/analytics_date_filter.dart';

class ReturnsAnalyticsScreen extends StatefulWidget {
  const ReturnsAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<ReturnsAnalyticsScreen> createState() => _ReturnsAnalyticsScreenState();
}

class _ReturnsAnalyticsScreenState extends State<ReturnsAnalyticsScreen> {
  DateFilterType _selectedFilter = DateFilterType.last7Days;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _isRefreshing = false;

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
        ),
        title: const Text(
          'Returns Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        actions: [
          CustomRefreshButton(
            onRefresh: _handleRefresh,
            isLoading: _isRefreshing,
          ),
        ],
      ),
      body: CustomPullToRefresh(
        onRefresh: _handleRefresh,
        child: Column(
          children: [
            AnalyticsDateFilter(
              selectedFilter: _selectedFilter,
              startDate: _startDate,
              endDate: _endDate,
              onFilterChanged: (filter, start, end) {
                setState(() {
                  _selectedFilter = filter;
                  _startDate = start;
                  _endDate = end;
                });
              },
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                key: ValueKey('${_startDate}_${_endDate}'),
                future: firestoreService.getReturnsAnalytics(_startDate, _endDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text(
                        'No data available',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final totalAssigned = data['totalAssigned'] as int;
                  final totalCompleted = data['totalCompleted'] as int;
                  final totalFailed = data['totalFailed'] as int;
                  final completionRate = data['completionRate'] as double;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Overview',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricCard(
                                      'Assigned',
                                      totalAssigned.toString(),
                                      const Color(0xFF2196F3),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMetricCard(
                                      'Completed',
                                      totalCompleted.toString(),
                                      const Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMetricCard(
                                      'Failed',
                                      totalFailed.toString(),
                                      const Color(0xFFF44336),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMetricCard(
                                      'Completion Rate',
                                      '${completionRate.toStringAsFixed(1)}%',
                                      const Color(0xFF9C27B0),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Performance',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF212121),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildProgressBar(
                                'Completion Rate',
                                totalAssigned > 0 ? (totalCompleted / totalAssigned) : 0.0,
                                const Color(0xFF4CAF50),
                              ),
                              const SizedBox(height: 16),
                              _buildProgressBar(
                                'Failure Rate',
                                totalAssigned > 0 ? (totalFailed / totalAssigned) : 0.0,
                                const Color(0xFFF44336),
                              ),
                            ],
                          ),
                        ),
                        if (totalAssigned == 0) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9C4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, size: 20, color: Color(0xFFF57F17)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No returns in selected date range',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFFF57F17),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
