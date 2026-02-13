import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelebara_mobile/features/orders/domain/entities/order_entity.dart';
import 'package:yelebara_mobile/features/orders/presentation/providers/order_provider.dart';

// models
class Order {
  final String id;
  final String clientName;
  final String serviceType;
  final String status;
  final String address;
  final double price;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.clientName,
    required this.serviceType,
    required this.status,
    required this.address,
    required this.price,
    required this.createdAt,
  });
}

class Client {
  final String id;
  final String name;
  final String address;
  final String phone;
  final int ordersCount;
  final double rating;

  Client({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.ordersCount,
    required this.rating,
  });
}


class PresseurHomePage extends ConsumerStatefulWidget {
  const PresseurHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<PresseurHomePage> createState() => _PresseurHomePageState();
}

class _PresseurHomePageState extends ConsumerState<PresseurHomePage> {
  int _currentIndex = 0;
  String _coveredZones = 'Ouaga 2000, Zone du Bois, Gounghin'; // Valeur par défaut

  final List<Widget> _pages = const [
    _PresserOrdersPage(),
    _PresserClientsPage(),
    _PresserStatsPage(),
    _PresserProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadCoveredZones();
    // Load orders on init
    Future.microtask(() => ref.read(orderProvider.notifier).loadOrders());
  }

  Future<void> _loadCoveredZones() async {
    final prefs = await SharedPreferences.getInstance();
    final zonesJson = prefs.getString('zones') ??
        '[{"id": "1", "name": "Ouaga 2000", "status": "active"}, {"id": "2", "name": "Zone du Bois", "status": "active"}, {"id": "3", "name": "Gounghin", "status": "active"}]';
    try {
      final List<dynamic> zonesList = json.decode(zonesJson);
      final activeZones =
          zonesList.where((zone) => zone["status"] == "active").toList();
      final zoneNames =
          activeZones.map((zone) => zone["name"].toString()).toList();

      if (mounted) {
        setState(() {
          _coveredZones = zoneNames.join(', ');
        });
      }
    } catch (e) {
      // En cas d'erreur, garder la valeur par défaut
      print('Erreur lors du chargement des zones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange.shade700,
        title: _currentIndex == 0 ? const Text('Commandes Attribuées') : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(orderProvider.notifier).loadOrders();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content:
                      const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: const Text('Confirmer',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Commandes'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Clients'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// page commandes
class _PresserOrdersPage extends ConsumerWidget {
  const _PresserOrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderProvider);

    if (orderState.isLoading && orderState.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderState.orders.isEmpty) {
      return const Center(child: Text("Aucune commande assignée pour le moment."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orderState.orders.length,
      itemBuilder: (context, index) {
        final order = orderState.orders[index];
        return _OrderCard(
          order: order,
          onAccept: () => _updateOrderStatus(context, ref, order, OrderStatus.processing),
          onReject: () => _updateOrderStatus(context, ref, order, OrderStatus.cancelled), // Or specific rejected status
          onComplete: () => _showCompleteDialog(context, ref, order),
        );
      },
    );
  }

  void _updateOrderStatus(BuildContext context, WidgetRef ref, OrderEntity order, OrderStatus newStatus) {
    ref.read(orderProvider.notifier).updateOrder(order.copyWith(status: newStatus));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Statut mis à jour: ${newStatus.name}')),
    );
  }

  void _showCompleteDialog(BuildContext context, WidgetRef ref, OrderEntity order) {
    final weightController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la commande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez entrer le poids du linge (kg):'),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(suffixText: 'kg'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null) {
                ref.read(orderProvider.notifier).updateOrder(
                      order.copyWith(status: OrderStatus.completed, weight: weight),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Commande terminée avec succès !')),
                );
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onComplete;

  const _OrderCard({
    Key? key,
    required this.order,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    // Fallback since client name isn't directly in OrderEntity yet, 
                    // ideally fetched via relation or stored in entity.
                    // For now, displaying ID.
                    'Client #${order.id}', 
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(order.serviceIcon, size: 16, color: Colors.grey[600]), // Use icon from entity
                const SizedBox(width: 6),
                Text(
                  order.serviceTitle,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            if (order.items != null && order.items!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Détails de la commande:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              ...order.items!.map((item) {
                final name = item['name'] ?? 'Article inconnu';
                final qty = item['quantity'] ?? 0;
                final weight = item['weight'] ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Text('• $qty x $name', style: TextStyle(color: Colors.grey[800], fontSize: 13)),
                      const Spacer(),
                      Text('${weight}kg', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    // Address isn't in OrderEntity. Using instructions or placeholders?
                    // Ideally pass address in OrderEntity.
                    // For now, show coordinates if available or instructions.
                    order.pickupLatitude != null 
                        ? 'GPS: ${order.pickupLatitude}, ${order.pickupLongitude}' 
                        : (order.instructions.isNotEmpty ? order.instructions : 'Adresse non spécifiée'),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
             if (order.weight != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.scale, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Poids: ${order.weight} kg',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.payments, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '${order.amount.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (order.status == OrderStatus.assigned) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAccept,
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Accepter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Refuser'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      );
    } else if (order.status == OrderStatus.processing || order.status == OrderStatus.assigned || order.status == OrderStatus.pending) { 
      // Allow completion if processing or if stuck in pending/assigned for demo
       return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onComplete,
          icon: const Icon(Icons.local_shipping, size: 18),
          label: const Text('Terminer & Peser'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String text;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange;
        text = 'En attente';
        break;
      case OrderStatus.assigned:
        backgroundColor = Colors.blue;
        text = 'Assignée';
        break;
      case OrderStatus.processing:
        backgroundColor = Colors.blueAccent;
        text = 'En traitement';
        break;
      case OrderStatus.completed:
        backgroundColor = Colors.green;
        text = 'Terminée';
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red;
        text = 'Annulée';
        break;
      default:
        backgroundColor = Colors.grey;
        text = status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// page clients
class _PresserClientsPage extends StatelessWidget {
  const _PresserClientsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Données mockées
    final clients = [
      Client(
        id: '1',
        name: 'Amadou Diallo',
        address: 'Ouaga 2000, Secteur 15',
        phone: '+226 70 12 34 56',
        ordersCount: 12,
        rating: 4.8,
      ),
      Client(
        id: '2',
        name: 'Fatima Ouédraogo',
        address: 'Zone du Bois, Secteur 10',
        phone: '+226 75 98 76 54',
        ordersCount: 8,
        rating: 4.5,
      ),
      Client(
        id: '3',
        name: 'Ibrahim Kaboré',
        address: 'Gounghin, Secteur 5',
        phone: '+226 71 23 45 67',
        ordersCount: 15,
        rating: 4.9,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.orange.shade100,
              child: Text(
                client.name[0],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
            title: Text(
              client.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        client.address,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      client.phone,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${client.ordersCount} commandes',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      client.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward_ios, color: Colors.orange.shade700),
              onPressed: () {
                // Navigation vers les commandes du client
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Voir commandes de ${client.name}')),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// page statistiques 
class _PresserStatsPage extends StatelessWidget {
  const _PresserStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue d\'ensemble',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.receipt_long,
                  title: 'Total commandes',
                  value: '47',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle,
                  title: 'Livrées',
                  value: '35',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.hourglass_empty,
                  title: 'En cours',
                  value: '8',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.payments,
                  title: 'Revenus',
                  value: '187k',
                  subtitle: 'FCFA',
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Note moyenne',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        '4.7',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '/ 5',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Basé sur 35 avis clients',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Activité mensuelle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _MonthlyStatRow(month: 'Octobre', orders: 15, revenue: 67500),
                  const Divider(),
                  _MonthlyStatRow(month: 'Septembre', orders: 18, revenue: 81000),
                  const Divider(),
                  _MonthlyStatRow(month: 'Août', orders: 14, revenue: 63000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final Color color;

  const _StatCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyStatRow extends StatelessWidget {
  final String month;
  final int orders;
  final double revenue;

  const _MonthlyStatRow({
    Key? key,
    required this.month,
    required this.orders,
    required this.revenue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            month,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$orders commandes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${revenue.toStringAsFixed(0)} FCFA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// page profil
class _PresserProfilePage extends StatefulWidget {
  const _PresserProfilePage({Key? key}) : super(key: key);

  @override
  State<_PresserProfilePage> createState() => _PresserProfilePageState();
}

class _PresserProfilePageState extends State<_PresserProfilePage> {
  String _coveredZones = 'Ouaga 2000, Zone du Bois, Gounghin'; // Valeur par défaut

  @override
  void initState() {
    super.initState();
    _loadCoveredZones();
  }

  Future<void> _loadCoveredZones() async {
    final prefs = await SharedPreferences.getInstance();
    final zonesJson = prefs.getString('zones') ?? '[{"id": "1", "name": "Ouaga 2000", "status": "active"}, {"id": "2", "name": "Zone du Bois", "status": "active"}, {"id": "3", "name": "Gounghin", "status": "active"}]';
    try {
      final List<dynamic> zonesList = json.decode(zonesJson);
      final activeZones = zonesList.where((zone) => zone["status"] == "active").toList();
      final zoneNames = activeZones.map((zone) => zone["name"].toString()).toList();
      
      if (mounted) {
        setState(() {
          _coveredZones = zoneNames.join(', ');
        });
      }
    } catch (e) {
      // En cas d'erreur, garder la valeur par défaut
      print('Erreur lors du chargement des zones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.orange.shade100,
            child: Icon(
              Icons.local_laundry_service,
              size: 60,
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pressing Excellence',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  'Presseur vérifié',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _ProfileInfoCard(
            icon: Icons.phone,
            title: 'Téléphone',
            value: '+226 70 12 34 56',
          ),
          const SizedBox(height: 12),
          _ProfileInfoCard(
            icon: Icons.location_on,
            title: 'Zone couverte',
            value: _coveredZones.isNotEmpty ? _coveredZones : 'Non définie',
          ),
          const SizedBox(height: 12),
          _ProfileInfoCard(
            icon: Icons.access_time,
            title: 'Horaires',
            value: 'Lun-Sam: 8h - 19h',
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Modification du profil')),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Modifier mes informations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Déconnexion réussie')),
                          );
                        },
                        child: const Text(
                          'Déconnexion',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Se déconnecter'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.orange.shade700),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PresseurProfilePage extends StatefulWidget {
  const PresseurProfilePage({Key? key}) : super(key: key);

  @override
  State<PresseurProfilePage> createState() => _PresseurProfilePageState();
}

class _PresseurProfilePageState extends State<PresseurProfilePage> {
  Uint8List? _photoBytes;
  final String _prefsKey = 'presseur_photo';

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString(_prefsKey);
    if (b64 != null) {
      setState(() => _photoBytes = base64Decode(b64));
    }
  }

  Future<void> _showPhotoOptions() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (_photoBytes != null)
                ListTile(
                  leading: const Icon(Icons.visibility, color: Colors.blue),
                  title: const Text('Voir la photo'),
                  onTap: () => Navigator.of(ctx).pop('view'),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.orange),
                title: Text(_photoBytes == null ? 'Ajouter une photo' : 'Modifier la photo'),
                onTap: () => Navigator.of(ctx).pop('change'),
              ),
              if (_photoBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Supprimer la photo'),
                  onTap: () => Navigator.of(ctx).pop('delete'),
                ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text('Annuler'),
                onTap: () => Navigator.of(ctx).pop('cancel'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (choice == null || choice == 'cancel') return;

    if (choice == 'view') {
      _viewPhoto();
    } else if (choice == 'change') {
      _pickPhoto();
    } else if (choice == 'delete') {
      _deletePhoto();
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final b64 = base64Encode(bytes);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, b64);

      setState(() => _photoBytes = bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du choix de la photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la photo'),
        content: const Text('Voulez-vous vraiment supprimer votre photo de profil ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);

    setState(() => _photoBytes = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo de profil supprimée'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewPhoto() {
    if (_photoBytes == null) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: PhotoView(
          imageProvider: MemoryImage(_photoBytes!),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Presseur'),
        backgroundColor: Colors.orange.shade700,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _showPhotoOptions,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.orange.shade100,
                backgroundImage: _photoBytes != null ? MemoryImage(_photoBytes!) : null,
                child: _photoBytes == null ? const Icon(Icons.person, size: 60, color: Colors.white70) : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pressing Excellence',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}