import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/daily_sheet.dart';
import '../../models/customer.dart';
import '../../widgets/custom_button.dart';

class JsonInputScreen extends StatefulWidget {
  const JsonInputScreen({Key? key}) : super(key: key);

  @override
  State<JsonInputScreen> createState() => _JsonInputScreenState();
}

class _JsonInputScreenState extends State<JsonInputScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processJson() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final jsonData = jsonDecode(_controller.text);
      
      if (!jsonData.containsKey('date') || 
          !jsonData.containsKey('area') || 
          !jsonData.containsKey('customers')) {
        throw Exception('Invalid JSON format. Required: date, area, customers');
      }

      final date = DateTime.parse(jsonData['date']);
      final area = jsonData['area'] as String;
      final customersJson = jsonData['customers'] as List;

      final auth = context.read<AuthService>();
      final firestoreService = FirestoreService(auth.currentUser!.uid);

      final sheet = DailySheet(
        id: '',
        userId: auth.currentUser!.uid,
        date: date,
        area: area,
        totalCustomers: customersJson.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final sheetId = await firestoreService.createDailySheet(sheet);

      final customers = <Customer>[];
      for (var i = 0; i < customersJson.length; i++) {
        final customerData = customersJson[i];
        
        String area = customerData['area'] as String? ?? jsonData['area'] as String;
        
        customers.add(Customer.fromJson(customerData, sheetId, i).copyWith(
          order: i,
        ));
      }

      await firestoreService.batchCreateCustomers(customers);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Add Daily Sheet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paste JSON Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Format: {"date": "2026-01-14", "area": "Location", "customers": [...]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: 20,
                      style: const TextStyle(
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Paste JSON here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: CustomButton(
              text: 'Process & Save',
              onPressed: _processJson,
              loading: _loading,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
