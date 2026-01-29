import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelebara_mobile/features/home/presentation/providers/home_provider.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/service_card.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/client_bottom_nav.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/home_drawer.dart';
import 'package:yelebara_mobile/features/home/presentation/widgets/gps_disabled_layer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom App Bar with Large Header
              SliverAppBar(
                expandedHeight: 120.0,
                floating: true,
                pinned: true,
                backgroundColor: colorScheme.surface,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1.1,
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.primary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(Icons.person, color: Colors.grey.shade600, size: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              state.greeting,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              state.userName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined),
                        color: colorScheme.onSurface,
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 12),
                    _buildSectionHeader(context, 'Pressing'),
                    const SizedBox(height: 12),
                    ServiceCard(
                      title: 'Lavage & Repassage',
                      price: 'À partir de 500 FCFA',
                      icon: Icons.local_laundry_service_rounded,
                      color: colorScheme.primary, // Use Primary Orange
                      onTap: () => _navigateToOrder(
                        context,
                        'Lavage & Repassage',
                        '500 FCFA / kg',
                        Icons.local_laundry_service_rounded,
                        colorScheme.primary,
                      ),
                    ),
                    ServiceCard(
                      title: 'Repassage seul',
                      price: 'À partir de 300 FCFA',
                      icon: Icons.iron_rounded,
                      color: const Color(0xFF009688), // Teal
                      onTap: () => _navigateToOrder(
                        context,
                        'Repassage seul',
                        '300 FCFA / habit',
                        Icons.iron_rounded,
                        const Color(0xFF009688),
                      ),
                    ),
                    ServiceCard(
                      title: 'Nettoyage à sec',
                      price: 'À partir de 2000 FCFA',
                      icon: Icons.dry_cleaning_rounded,
                      color: const Color(0xFF7E57C2), // Deep Purple
                      onTap: () => _navigateToOrder(
                        context,
                        'Nettoyage à sec',
                        '2000 FCFA / habit',
                        Icons.dry_cleaning_rounded,
                        const Color(0xFF7E57C2),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Spécial'),
                    const SizedBox(height: 12),
                    ServiceCard(
                      title: 'Nettoyage Tapis',
                      price: '2500 FCFA / m²',
                      icon: Icons.layers_rounded,
                      color: const Color(0xFF5D4037), // Brownish
                      onTap: () => _navigateToOrder(
                        context,
                        'Nettoyage Tapis',
                        '2500 FCFA / m2',
                        Icons.layers_rounded,
                        const Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom nav
                  ]),
                ),
              ),
            ],
          ),
          const GpsDisabledLayer(),
        ],
      ),
      drawer: const HomeDrawer(),
      bottomNavigationBar: const ClientBottomNav(activeIndex: 0),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  void _navigateToOrder(
    BuildContext context,
    String title,
    String price,
    IconData icon,
    Color color,
  ) {
    context.push(
      '/create-order',
      extra: {
        'serviceTitle': title,
        'servicePrice': price,
        'serviceIcon': icon,
        'serviceColor': color,
      },
    );
  }
}

