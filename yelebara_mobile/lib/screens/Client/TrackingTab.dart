import 'package:flutter/material.dart';
class TrackingTab extends StatelessWidget {
  const TrackingTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {'id': '#245', 'service': 'Lavage + repassage', 'status': '🟡 En cours'},
      {'id': '#244', 'service': 'Lavage simple', 'status': '🟢 Terminé'},
      {'id': '#243', 'service': 'Repassage', 'status': '🟠 Livré'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚚 Suivi de mes commandes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...orders.map((o) => _buildOrderCard(o)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, String> o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${o['id']} – ${o['service']}'),
          Text(o['status']!),
        ],
      ),
    );
  }
}
