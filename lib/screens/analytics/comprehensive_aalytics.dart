import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/daily_sheet.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_refresh_button.dart';
import '../../widgets/custom_pull_to_refresh.dart';
import '../../widgets/analytics_date_filter.dart';

class ComprehensiveAnalyticsScreen extends StatefulWidget {
  const ComprehensiveAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<ComprehensiveAnalyticsScreen> createState() => _ComprehensiveAnalyticsScreenState();
}

class _ComprehensiveAnalyticsScreenState extends State<ComprehensiveAnalyticsScreen> {
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
          'Comprehensive Analytics',
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
                future: _fetchAllAnalytics(firestoreService),
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
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewSection(data),
                        const SizedBox(height: 16),
                        _buildSuccessRateCard(data),
                        const SizedBox(height: 16),
                        _buildDeliveryTrendChart(data),
                        const SizedBox(height: 16),
                        _buildEarningsChart(data),
                        const SizedBox(height: 16),
                        _buildDistributionPieChart(data),
                        const SizedBox(height: 16),
                        _buildDetailedMetrics(data),
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

  Future<Map<String, dynamic>> _fetchAllAnalytics(FirestoreService service) async {
    final deliveryData = await service.getDeliveryAnalytics(_startDate, _endDate, null);
    final fuelData = await service.getFuelAnalytics(_startDate, _endDate);
    
    // Fetch daily breakdown for charts
    final sheets = await service.getSheetsByDateRange(_startDate, _endDate);
    
    return {
      ...deliveryData,
      ...fuelData,
      'dailySheets': sheets,
    };
  }

  Widget _buildOverviewSection(Map<String, dynamic> data) {
    final totalDelivered = data['totalDelivered'] as int;
    final totalFailed = data['totalFailed'] as int;
    final totalPicked = data['totalPicked'] as int;
    final totalPetrol = data['totalPetrol'] as double;
    final totalEarnings = totalDelivered * 15.0; // Will use settings value

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Total Picked',
                totalPicked.toString(),
                const Color(0xFF2196F3),
                Icons.shopping_bag,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Delivered',
                totalDelivered.toString(),
                const Color(0xFF4CAF50),
                Icons.check_circle,
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
                Icons.cancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Earnings',
                '₹${totalEarnings.toStringAsFixed(0)}',
                const Color(0xFF4CAF50),
                Icons.currency_rupee,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Fuel Cost',
                '₹${totalPetrol.toStringAsFixed(0)}',
                const Color(0xFF9C27B0),
                Icons.local_gas_station,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Net Profit',
                '₹${(totalEarnings - totalPetrol).toStringAsFixed(0)}',
                const Color(0xFFFF9800),
                Icons.trending_up,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessRateCard(Map<String, dynamic> data) {
    final totalPicked = data['totalPicked'] as int;
    final totalDelivered = data['totalDelivered'] as int;
    final totalFailed = data['totalFailed'] as int;
    
    final successRate = totalPicked > 0 ? (totalDelivered / totalPicked * 100) : 0.0;
    final failureRate = totalPicked > 0 ? (totalFailed / totalPicked * 100) : 0.0;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Success Metrics',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${successRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Success Rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: const Color(0xFFE0E0E0),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${failureRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF44336),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Failure Rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildProgressBar('Success Rate', successRate / 100, const Color(0xFF4CAF50)),
          const SizedBox(height: 12),
          _buildProgressBar('Failure Rate', failureRate / 100, const Color(0xFFF44336)),
        ],
      ),
    );
  }

  Widget _buildDeliveryTrendChart(Map<String, dynamic> data) {
    final sheets = data['dailySheets'] as List<DailySheet>;
    
    if (sheets.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Trend',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE0E0E0),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF757575),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < sheets.length) {
                          final date = sheets[value.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF757575),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: sheets.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.delivered.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: sheets.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.failed.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFFF44336),
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFF44336).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Delivered', const Color(0xFF4CAF50)),
              const SizedBox(width: 20),
              _buildLegend('Failed', const Color(0xFFF44336)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart(Map<String, dynamic> data) {
    final sheets = data['dailySheets'] as List<DailySheet>;
    
    if (sheets.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Earnings vs Fuel Cost',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE0E0E0),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${value.toInt()}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF757575),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < sheets.length) {
                          final date = sheets[value.toInt()].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('M/d').format(date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF757575),
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sheets.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.earnings,
                        color: const Color(0xFF4CAF50),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: e.value.petrol,
                        color: const Color(0xFF9C27B0),
                        width: 12,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Earnings', const Color(0xFF4CAF50)),
              const SizedBox(width: 20),
              _buildLegend('Fuel', const Color(0xFF9C27B0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionPieChart(Map<String, dynamic> data) {
    final totalDelivered = (data['totalDelivered'] as int).toDouble();
    final totalFailed = (data['totalFailed'] as int).toDouble();
    final totalPending = (data['totalPicked'] as int).toDouble() - totalDelivered;

    if (totalDelivered + totalFailed + totalPending == 0) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Distribution',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: totalDelivered,
                    title: '${((totalDelivered / (totalDelivered + totalFailed + totalPending)) * 100).toStringAsFixed(0)}%',
                    color: const Color(0xFF4CAF50),
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalFailed,
                    title: '${((totalFailed / (totalDelivered + totalFailed + totalPending)) * 100).toStringAsFixed(0)}%',
                    color: const Color(0xFFF44336),
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalPending,
                    title: '${((totalPending / (totalDelivered + totalFailed + totalPending)) * 100).toStringAsFixed(0)}%',
                    color: const Color(0xFF2196F3),
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegend('Delivered', const Color(0xFF4CAF50)),
              _buildLegend('Failed', const Color(0xFFF44336)),
              _buildLegend('In Progress', const Color(0xFF2196F3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics(Map<String, dynamic> data) {
    final totalDelivered = data['totalDelivered'] as int;
    final totalPicked = data['totalPicked'] as int;
    final avgPerDay = data['averagePerDay'] as double;
    final days = data['days'] as int;

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Metrics',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Total Parcels Handled', totalPicked.toString()),
          const SizedBox(height: 12),
          _buildDetailRow('Successfully Delivered', totalDelivered.toString()),
          const SizedBox(height: 12),
          _buildDetailRow('Average Fuel/Day', '₹${avgPerDay.toStringAsFixed(0)}'),
          const SizedBox(height: 12),
          _buildDetailRow('Working Days', days.toString()),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Avg Deliveries/Day',
            days > 0 ? (totalDelivered / days).toStringAsFixed(1) : '0',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF757575),
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

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
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
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}
