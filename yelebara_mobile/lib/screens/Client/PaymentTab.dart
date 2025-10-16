import 'package:flutter/material.dart';
class PaymentTab extends StatelessWidget {
  const PaymentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final payments = [
      {'id': '#245', 'amount': '7 000', 'date': '14 Octobre', 'method': 'OM'},
      {'id': '#244', 'amount': '3 500', 'date': '10 Octobre', 'method': 'Espèces'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 Mes paiements',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...payments.map((p) => _buildPaymentCard(p)).toList(),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, String> p) {
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
          Text('Commande ${p['id']}'),
          Text('${p['amount']} FCFA – ${p['method']}'),
        ],
      ),
    );
  }
}
