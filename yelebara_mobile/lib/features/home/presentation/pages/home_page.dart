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
      backgroundColor: const Color(0xFFF8F9FA), // Off-white background
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
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                     Color(0xFFF97316), // Orange 500
                     Color(0xFFEA580C), // Orange 600
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                      color: Colors.white.withOpacity(0.2), // Glass effect
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Votre pressing mobile',
                      style: TextStyle(
                        color: Colors.white,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827), // Darker text
              ),
            ),

            const SizedBox(height: 16),

            /// GRILLE SERVICES
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              childAspectRatio: 0.7,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _serviceCard(
                  context,
                  imagePath: 'assets/images/lavage_simple.png',
                  title: 'Lavage simple',
                  icon: Icons.local_laundry_service,
                ),
                _serviceCard(
                  context,
                  imagePath: 'assets/images/repassage.png',
                  title: 'Repassage',
                  icon: Icons.iron_rounded,
                ),
                _serviceCard(
                  context,
                  imagePath: 'assets/images/pressing_complet.png',
                  title: 'Pressing complet',
                  icon: Icons.checkroom,
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
    String? imagePath,
    required String title,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Super rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16), // Slightly more rounded icon bg
            ),
            child: imagePath != null 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 28,
                    height: 28,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, color: colorScheme.primary);
                    },
                  ),
                )
              : Icon(
                  icon,
                  color: colorScheme.primary,
                  size: 28,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.push(
                  '/create-order',
                  extra: {
                    'serviceTitle': title,
                    'serviceIcon': icon,
                    'serviceColor': colorScheme.primary,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const StadiumBorder(), // Pill shape
                elevation: 0,
              ),
              child: const Text(
                'Commander', 
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
