import 'package:flutter/material.dart';

class BeneficiaryHomePage extends StatefulWidget {
  const BeneficiaryHomePage({Key? key, required String confirmationMessage}) : super(key: key);

  @override
  State<BeneficiaryHomePage> createState() => _BeneficiaryHomePageState();
}

class _BeneficiaryHomePageState extends State<BeneficiaryHomePage> {
  bool isKitAvailable = true;
  String beneficiaryName = "Awa";

  // Données simulées
  final List<Map<String, dynamic>> orders = [
    {
      'id': '001',
      'clientName': 'M. Traoré',
      'items': 5,
      'type': 'Chemises',
      'service': 'Complet',
      'price': 2500,
      'status': 'En cours',
      'icon': Icons.checkroom,
    },
    {
      'id': '002',
      'clientName': 'Mme Zongo',
      'items': 3,
      'type': 'Robes',
      'service': 'Lavage seul',
      'price': 3000,
      'status': 'Terminée',
      'icon': Icons.woman,
    },
    {
      'id': '003',
      'clientName': 'M. Sawadogo',
      'items': 2,
      'type': 'Pantalons',
      'service': 'Repassage',
      'price': 1500,
      'status': 'En attente',
      'icon': Icons.iron,
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En cours':
        return Colors.orange;
      case 'Terminée':
        return Colors.green;
      case 'En attente':
        return Colors.blue;
      case 'Livré':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => OrderDetailsSheet(
        order: order,
        onStatusUpdate: (newStatus) {
          setState(() {
            order['status'] = newStatus;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec photo de profil et message d'accueil
                Row(
                  children: [
                    Container(
                      width: isSmallScreen ? 50 : 60,
                      height: isSmallScreen ? 50 : 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.shade100,
                        border: Border.all(
                          color: Colors.orange.shade600,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/YELEBARA_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bonjour $beneficiaryName 👋',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Prête pour une nouvelle journée avec Yelébara ?',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 13 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Indicateur de statut du kit
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isKitAvailable
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isKitAvailable
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isKitAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isKitAvailable
                              ? 'Kit disponible et opérationnel'
                              : 'Kit en maintenance',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 15,
                            fontWeight: FontWeight.w600,
                            color: isKitAvailable
                                ? Colors.green.shade900
                                : Colors.red.shade900,
                          ),
                        ),
                      ),
                      Switch(
                        value: isKitAvailable,
                        onChanged: (value) {
                          setState(() {
                            isKitAvailable = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Titre du tableau de bord
                Text(
                  '📊 Tableau de bord',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // Indicateurs clés (grille)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildDashboardCard(
                      icon: '💧',
                      title: 'Commandes du jour',
                      value: '8',
                      color: Colors.blue,
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildDashboardCard(
                      icon: '💵',
                      title: 'Revenu du jour',
                      value: '12 500',
                      subtitle: 'FCFA',
                      color: Colors.green,
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildDashboardCard(
                      icon: '👗',
                      title: 'Articles lavés',
                      value: '42',
                      subtitle: 'vêtements',
                      color: Colors.purple,
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildDashboardCard(
                      icon: '⭐',
                      title: 'Satisfaction',
                      value: '4.8',
                      subtitle: '/ 5',
                      color: Colors.orange,
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Section Mes Commandes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📦 Mes Commandes',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Voir toutes les commandes
                      },
                      child: Text(
                        'Voir tout',
                        style: TextStyle(
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Liste des commandes
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return _buildOrderCard(order, isSmallScreen);
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String icon,
    required String title,
    required String value,
    String? subtitle,
    required Color color,
    required bool isSmallScreen,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: isSmallScreen ? 20 : 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: color,
                  size: isSmallScreen ? 14 : 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 11 : 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showOrderDetails(order),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Row(
              children: [
                // Icône
                Container(
                  width: isSmallScreen ? 45 : 50,
                  height: isSmallScreen ? 45 : 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    order['icon'],
                    color: Colors.orange.shade600,
                    size: isSmallScreen ? 24 : 28,
                  ),
                ),
                const SizedBox(width: 12),
                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['clientName'],
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order['items']} ${order['type']} – ${order['service']}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order['status'],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order['status']),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Sheet pour les détails de la commande
class OrderDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> order;
  final Function(String) onStatusUpdate;

  const OrderDetailsSheet({
    Key? key,
    required this.order,
    required this.onStatusUpdate,
  }) : super(key: key);

  @override
  State<OrderDetailsSheet> createState() => _OrderDetailsSheetState();
}

class _OrderDetailsSheetState extends State<OrderDetailsSheet> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order['status'];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Barre de titre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Titre
              Text(
                'Détails de la commande',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Informations de la commande
              _buildDetailRow(
                'Numéro de commande',
                '#${widget.order['id']}',
                isSmallScreen,
              ),
              _buildDetailRow(
                'Client',
                widget.order['clientName'],
                isSmallScreen,
              ),
              _buildDetailRow(
                'Articles',
                '${widget.order['items']} ${widget.order['type']}',
                isSmallScreen,
              ),
              _buildDetailRow(
                'Type de service',
                widget.order['service'],
                isSmallScreen,
              ),
              _buildDetailRow(
                'Prix total',
                '${widget.order['price']} FCFA',
                isSmallScreen,
              ),
              _buildDetailRow(
                'Statut actuel',
                currentStatus,
                isSmallScreen,
                isStatus: true,
              ),

              const SizedBox(height: 24),

              // Boutons de mise à jour du statut
              Text(
                'Mettre à jour le statut',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildStatusButton('En attente', isSmallScreen),
                  _buildStatusButton('En cours', isSmallScreen),
                  _buildStatusButton('Terminée', isSmallScreen),
                  _buildStatusButton('Livré', isSmallScreen),
                ],
              ),

              const SizedBox(height: 20),

              // Bouton de fermeture
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 50 : 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onStatusUpdate(currentStatus);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Confirmer',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    bool isSmallScreen, {
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 15,
              color: Colors.grey[600],
            ),
          ),
          isStatus
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(value).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(value),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String status, bool isSmallScreen) {
    final isSelected = currentStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          currentStatus = status;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 14 : 16,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _getStatusColor(status)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(status),
            width: 2,
          ),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _getStatusColor(status),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En cours':
        return Colors.orange;
      case 'Terminée':
        return Colors.green;
      case 'En attente':
        return Colors.blue;
      case 'Livré':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}