import 'package:delivery_tracker/screens/analytics/comprehensive_aalytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/daily_sheet.dart';
import '../../widgets/day_card.dart';
import '../../widgets/custom_pull_to_refresh.dart';
import '../../widgets/custom_refresh_button.dart';
import '../../widgets/custom_drop_up.dart';
import '../json_input/json_input_screen.dart';
import '../day_details/day_details_screen.dart';
import '../analytics/delivery_analytics_screen.dart';
import '../analytics/returns_analytics_screen.dart';
import '../analytics/fuel_analytics_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  void _showDropUp() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (dialogContext) => CustomDropUp(
        onRunsheetTap: () {
          Navigator.of(dialogContext).pop(); // close drop-up
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const JsonInputScreen(type: SheetType.runsheet),
            ),
          );
        },
        onPickupTap: () {
          Navigator.of(dialogContext).pop(); // close drop-up
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const JsonInputScreen(type: SheetType.pickup),
            ),
          );
        },
      ),
    );
  }

  Future<void> _closeSheet(DailySheet sheet) async {
    final auth = context.read<AuthService>();
    final firestoreService = FirestoreService(auth.currentUser!.uid);

    await firestoreService.closeSheet(sheet.id, sheet.type);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${sheet.type.name.toUpperCase()} closed successfully'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final firestoreService = FirestoreService(auth.currentUser!.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Tracker',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Runsheets & Pickups',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomRefreshButton(
                    onRefresh: _handleRefresh,
                    isLoading: _isRefreshing,
                  ),
                  GestureDetector(
                    onTap: () => _showMenu(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.more_vert,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CustomPullToRefresh(
                onRefresh: _handleRefresh,
                child: StreamBuilder<List<DailySheet>>(
                  stream: firestoreService.getAllSheets(),
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inbox,
                              size: 80,
                              color: Color(0xFFBDBDBD),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No sheets yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF757575),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Pull down to refresh',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: _showDropUp,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Add First Sheet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final sheet = snapshot.data![index];
                        return DayCard(
                          sheet: sheet,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DayDetailsScreen(sheet: sheet),
                              ),
                            );
                          },
                          onClose: sheet.isCompleted && !sheet.isClosed
                              ? () => _closeSheet(sheet)
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: _showDropUp,
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF2196F3),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context,
              'Delivery Analytics',
              Icons.analytics,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryAnalyticsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Returns Analytics',
              Icons.assignment_return,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReturnsAnalyticsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Comprehensive Analytics',
              Icons.pie_chart,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ComprehensiveAnalyticsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Fuel Analytics',
              Icons.local_gas_station,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FuelAnalyticsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Settings',
              Icons.settings,
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              'Sign Out',
              Icons.logout,
              () async {
                Navigator.pop(context);
                await context.read<AuthService>().signOut();
              },
              isDestructive: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDestructive
                  ? const Color(0xFFF44336)
                  : const Color(0xFF757575),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive
                    ? const Color(0xFFF44336)
                    : const Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
