import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_refresh_button.dart';
import '../../widgets/custom_pull_to_refresh.dart';
import '../../widgets/analytics_date_filter.dart';

class FuelAnalyticsScreen extends StatefulWidget {
  const FuelAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<FuelAnalyticsScreen> createState() => _FuelAnalyticsScreenState();
}

class _FuelAnalyticsScreenState extends State<FuelAnalyticsScreen> {
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
          'Fuel Analytics',
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
                future: firestoreService.getFuelAnalytics(_startDate, _endDate),
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
                  final totalPetrol = data['totalPetrol'] as double;
                  final averagePerDay = data['averagePerDay'] as double;
                  final days = data['days'] as int;

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
                                      'Total Spent',
                                      '₹${totalPetrol.toStringAsFixed(0)}',
                                      const Color(0xFF9C27B0),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildMetricCard(
                                      'Avg Per Day',
                                      '₹${averagePerDay.toStringAsFixed(0)}',
                                      const Color(0xFF2196F3),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildMetricCard(
                                'Total Days',
                                days.toString(),
                                const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                        if (days == 0) ...[
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
                                    'No fuel data in selected date range',
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
}
