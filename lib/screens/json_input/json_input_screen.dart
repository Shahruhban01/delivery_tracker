import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/daily_sheet.dart';
import '../../models/customer.dart';
import '../../widgets/custom_button.dart';

class JsonInputScreen extends StatefulWidget {
  final SheetType type;

  const JsonInputScreen({
    Key? key,
    this.type = SheetType.runsheet,
  }) : super(key: key);

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

    final date = jsonData['date'] != null
        ? DateTime.parse(jsonData['date'])
        : DateTime.now();

    final area = jsonData['area'] as String? ?? 'Unknown Area';
    final customersJson = jsonData['customers'] as List? ?? [];

    if (customersJson.isEmpty) {
      throw Exception('No customers found in JSON');
    }

    final auth = context.read<AuthService>();
    final firestoreService = FirestoreService(auth.currentUser!.uid);

    final settings = await firestoreService.getSettings().first;

    final sheet = DailySheet(
      id: '',
      userId: auth.currentUser!.uid,
      date: date,
      area: area,
      type: widget.type,
      totalCustomers: customersJson.length,
      petrol: settings.defaultPetrolCost,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final sheetId = await firestoreService.createSheet(sheet);

    final customers = <Customer>[];
    for (var i = 0; i < customersJson.length; i++) {
      final customerData = customersJson[i] as Map<String, dynamic>;

      final name = customerData['name'] as String? ?? 'Unknown';
      final address = customerData['address'] as String? ?? '';
      String phone = customerData['phone']?.toString() ?? '';

      if (phone.isEmpty) {
        phone = '+91 1234567890';
      }

      final customerArea = customerData['area'] as String? ?? area;

      final customer = Customer(
        id: '',
        dayId: sheetId,
        sheetType: widget.type.name,
        name: name,
        address: address,
        phone: phone,
        area: customerArea,
        order: i,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      customers.add(customer);
    }

    // 1) Batch create customers
    await firestoreService.batchCreateCustomers(customers);

    // 2) One-time set picked = total customers count
    await firestoreService.updateSheet(
      sheetId,
      widget.type,
      {
        'picked': customers.length,
        'totalCustomers': customers.length,
      },
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${widget.type.name.toUpperCase()} created with ${customers.length} customers'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    final typeColor = widget.type == SheetType.runsheet
        ? const Color(0xFF2196F3)
        : const Color(0xFFFF9800);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
        ),
        title: Text(
          'Add ${widget.type == SheetType.runsheet ? 'Runsheet' : 'Pickup Sheet'}',
          style: const TextStyle(
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: typeColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.type == SheetType.runsheet
                              ? Icons.local_shipping
                              : Icons.assignment_return,
                          size: 20,
                          color: typeColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.type == SheetType.runsheet
                                ? 'Delivery runsheet for outgoing parcels'
                                : 'Pickup sheet for returns collection',
                            style: TextStyle(
                              fontSize: 12,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Paste JSON Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Defaults applied:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF57F17),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '• Missing phone → +91 1234567890\n• Missing date → Today\'s date\n• Petrol cost → From settings',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFF57F17),
                          ),
                        ),
                      ],
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
                        hintText: '{\n  "date": "2026-01-15",\n  "area": "Sopore",\n  "customers": [\n    {\n      "name": "Customer Name",\n      "address": "Full Address",\n      "phone": "9419012345"\n    }\n  ]\n}',
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
              backgroundColor: typeColor,
            ),
          ),
        ],
      ),
    );
  }
}
