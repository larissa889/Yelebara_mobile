import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yelebara_mobile/features/orders/presentation/providers/order_provider.dart';

class ClientBottomNav extends ConsumerStatefulWidget {
  final int activeIndex;
  const ClientBottomNav({Key? key, required this.activeIndex})
    : super(key: key);

  @override
  ConsumerState<ClientBottomNav> createState() => _ClientBottomNavState();
}

class _ClientBottomNavState extends ConsumerState<ClientBottomNav> {
  @override
  Widget build(BuildContext context) {
    // Watch orders to update the badge count
    final orderState = ref.watch(orderProvider);
    final int ordersCount = orderState.orders.length;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.activeIndex,
      selectedItemColor: const Color(0xFFF97316), // Orange
      unselectedItemColor: const Color(0xFF9CA3AF), // Soft Gray
      onTap: (index) {
        if (index == widget.activeIndex) return;
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/pressing');
            break;
          case 2:
            context.go('/orders');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        const BottomNavigationBarItem(
          icon: Icon(Icons.local_laundry_service),
          label: 'Pressing',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.receipt_long),
              if (ordersCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Center(
                      child: Text(
                        '$ordersCount',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
            ),
          label: 'Commandes',
        ),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    ); 
  }
}
