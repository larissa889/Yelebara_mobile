import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/client_bottom_nav.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/home_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const HomeDrawer(),

      /// APPBAR ORANGE
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'YELEBARA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CARTE BIENVENUE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenue chez Yélébara',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Votre pressing mobile',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// TITRE
            const Text(
              'Nos services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// GRILLE SERVICES
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _serviceCard(
                  context,
                  icon: Icons.local_laundry_service,
                  title: 'Lavage simple',
                  price: 'à partir de 500 F',
                ),
                _serviceCard(
                  context,
                  icon: Icons.iron_rounded, // Changed from Icons.iron to ensure compatibility
                  title: 'Repassage',
                  price: 'à partir de 300 F',
                ),
                _serviceCard(
                  context,
                  icon: Icons.checkroom,
                  title: 'Pressing complet',
                  price: 'à partir de 1000 F',
                ),
                _serviceCard(
                  context,
                  icon: Icons.calculate,
                  title: 'Calculateur de prix',
                  price: 'Estimer le coût',
                  isCalculator: true,
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: const ClientBottomNav(activeIndex: 0),
    );
  }

  Widget _serviceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String price,
    bool isCalculator = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (!isCalculator) {
                  context.push(
                    '/create-order',
                    extra: {
                      'serviceTitle': title,
                      'servicePrice': price,
                      'serviceIcon': icon,
                      'serviceColor': colorScheme.primary, // Using primary since internal color logic is gone
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCalculator
                    ? Colors.teal
                    : colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Commander', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
