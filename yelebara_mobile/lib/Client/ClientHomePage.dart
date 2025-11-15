import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:yelebara_mobile/Screens/LoginPage.dart';
import 'package:collection/collection.dart';
import 'dart:async';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({Key? key}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  bool _showLocationDialog = false;
  String _selectedPrecision = 'exacte'; // 'exacte' ou 'approximative'
  bool _gpsDisabled = false;
  StreamSubscription<ServiceStatus>? _serviceStatusSub;
  String? _headerName;
  String? _headerPhone;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _listenGpsServiceStatus();
    _loadHeaderInfo();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownLocationDialog =
        prefs.getBool('hasShownLocationDialog') ?? false;

    if (!hasShownLocationDialog) {
      // Petite pause pour laisser la page se charger
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _showLocationDialog = true;
      });
    }
  }

  Future<void> _loadHeaderInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey == null) return;
    setState(() {
      _headerName = prefs.getString('profile:' + emailKey + ':name');
      _headerPhone = prefs.getString('profile:' + emailKey + ':phone');
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _listenGpsServiceStatus() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _gpsDisabled = !enabled;
    });
    _serviceStatusSub = Geolocator.getServiceStatusStream().listen((status) {
      setState(() {
        _gpsDisabled = status == ServiceStatus.disabled;
      });
    });
  }

  @override
  void dispose() {
    _serviceStatusSub?.cancel();
    super.dispose();
  }

  Future<void> _handleLocationPermission(String choice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownLocationDialog', true);

    if (choice == 'allow_while_using' || choice == 'allow_once') {
      // Vérifie si la localisation est activée sur l'appareil
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Veuillez activer la localisation sur votre appareil.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Vérifie et demande la permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission de localisation refusée.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Les permissions de localisation sont bloquées. Activez-les dans les paramètres.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Récupération de la position selon la précision sélectionnée
      LocationAccuracy accuracy = _selectedPrecision == 'exacte'
          ? LocationAccuracy.best
          : LocationAccuracy.low;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );

      print('Position obtenue: ${position.latitude}, ${position.longitude}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Localisation activée (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    setState(() {
      _showLocationDialog = false;
    });

    if (choice == 'deny') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vous pourrez activer la localisation plus tard dans les paramètres.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          // Contenu principal
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.orange.shade600,
                floating: true,
                pinned: true,
                elevation: 2,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'YELEBARA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bannière principale
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Icon(
                          Icons.local_laundry_service,
                          size: 150,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Bienvenue chez Yélébara',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Votre pressing mobile',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Section "Nos services"
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Nos services',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Grille des services
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildServiceCard(
                      'Lavage simple',
                      Icons.local_laundry_service,
                      Colors.blue,
                      price: 'à partir de 500 F',
                    ),
                    _buildServiceCard(
                      'Repassage',
                      Icons.iron,
                      Colors.purple,
                      price: 'à partir de 300 F',
                    ),
                    _buildServiceCard(
                      'Pressing complet',
                      Icons.dry_cleaning,
                      Colors.green,
                      price: 'à partir de 1000 F',
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // Popup de permission de localisation
          if (_showLocationDialog)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icône de localisation
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Titre
                      const Text(
                        'Autoriser Yelebara Pressing à accéder à la position de cet appareil ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options de précision
                      Row(
                        children: [
                          Expanded(
                            child: _buildPrecisionOption(
                              'Exacte',
                              Icons.my_location,
                              'exacte',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildPrecisionOption(
                              'Approximative',
                              Icons.location_searching,
                              'approximative',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Boutons d'action
                      _buildActionButton(
                        "Lorsque vous utilisez l'appli",
                        () => _handleLocationPermission('allow_while_using'),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Uniquement cette fois-ci',
                        () => _handleLocationPermission('allow_once'),
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        'Ne pas autoriser',
                        () => _handleLocationPermission('deny'),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Popup GPS désactivé
          if (_gpsDisabled)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Localisation',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Votre position GPS est désactivée.\nVeuillez l\'activer dans les paramètres.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _gpsDisabled = false;
                              });
                            },
                            child: const Text('J\'ai compris'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              await Geolocator.openLocationSettings();
                            },
                            child: const Text('Activer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, 
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) return; // Rester sur Accueil
          Widget page;
          switch (index) {
            case 1:
              page = const _ClientPressingPage();
              break;
            case 2:
              page = const ClientOrdersPage();
              break;
            case 3:
              page = const _ClientProfilePage();
              break;
            default:
              return;
          }
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service),
            label: 'Pressing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildPrecisionOption(String label, IconData icon, String value) {
    final isSelected = _selectedPrecision == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPrecision = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.shade400.withOpacity(0.2)
              : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade400 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade400 : Colors.grey.shade700,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDestructive ? Colors.red.shade400 : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    IconData icon,
    Color color, {
    String? price,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CreateOrderPage(
                  serviceTitle: title,
                  servicePrice: price ?? '',
                  serviceIcon: icon,
                  serviceColor: color,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône en haut
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),

                // Texte et prix
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    if (price != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        price,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),

                // Bouton commander en bas
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateOrderPage(
                            serviceTitle:
                                title, // passez le même titre que la carte
                            servicePrice:
                                price ??
                                '', // passez le prix avec une valeur par défaut si null
                            serviceIcon: icon, // passez la même icône
                            serviceColor: color, // passez la même couleur
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Commander',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
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

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 44, color: Colors.orange),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          _headerName ?? 'Invité',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Flexible(
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          _headerPhone ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_laundry_service),
              title: const Text('Nos services'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Commande'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClientOrdersPage()),
                );
              },
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Communication',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone_in_talk, color: Colors.green),
              title: const Text('Contactez-nous'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.star_rate_rounded,
                color: Colors.orange,
              ),
              title: const Text('Notez-nous'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.lightBlue),
              title: const Text('Partagez cette application'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// Pages accessibles via la barre de navigation inférieure

class _ClientPressingPage extends StatelessWidget {
  const _ClientPressingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange.shade700,
        title: Text(
          'Pressing à proximité',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: Text('Carte des pressings (à intégrer avec Google Maps API)'),
      ),
      bottomNavigationBar: const _ClientBottomNav(activeIndex: 1),
    );
  }
}

class _BeneficiaryDirectoryPage extends StatefulWidget {
  const _BeneficiaryDirectoryPage({Key? key}) : super(key: key);

  @override
  State<_BeneficiaryDirectoryPage> createState() =>
      _BeneficiaryDirectoryPageState();
}

class _BeneficiaryDirectoryPageState extends State<_BeneficiaryDirectoryPage> {
  List<_Beneficiary> _all = [];
  String _query = '';
  String _selectedQuartier = 'Tous';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getStringList('beneficiaries_index') ?? <String>[];
    final List<_Beneficiary> users = [];
    for (final email in index) {
      final name = prefs.getString('profile:' + email + ':name') ?? '';
      final phone = prefs.getString('profile:' + email + ':phone') ?? '';
      final addr = prefs.getString('profile:' + email + ':address1') ?? '';
      users.add(
        _Beneficiary(name: name, email: email, phone: phone, quartier: addr),
      );
    }
    setState(() {
      _all = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quartiers = [
      'Tous',
      ..._all
          .map((e) => e.quartier.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList(),
    ];
    final filtered = _all.where((b) {
      final matchQuery =
          _query.isEmpty ||
          b.name.toLowerCase().contains(_query.toLowerCase()) ||
          b.phone.contains(_query) ||
          b.email.contains(_query);
      final matchQuartier =
          _selectedQuartier == 'Tous' || b.quartier.trim() == _selectedQuartier;
      return matchQuery && matchQuartier;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange.shade700,
        title: Text(
          'Pressing',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final isNarrow = constraints.maxWidth < 360;
                return isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            onChanged: (v) => setState(() => _query = v),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Rechercher un bénéficiaire...',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedQuartier,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                            ),
                            items: quartiers
                                .map(
                                  (q) => DropdownMenuItem(
                                    value: q,
                                    child: Text(q),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedQuartier = v ?? 'Tous'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: 'Rechercher un presseur...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 160,
                            child: DropdownButtonFormField<String>(
                              value: _selectedQuartier,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                              ),
                              items: quartiers
                                  .map(
                                    (q) => DropdownMenuItem(
                                      value: q,
                                      child: Text(
                                        q,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(
                                () => _selectedQuartier = v ?? 'Tous',
                              ),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final b = filtered[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(b.initials)),
                  title: Text(
                    b.name.isEmpty ? b.email : b.name,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    b.quartier.isEmpty ? '—' : b.quartier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 110,
                    child: Text(
                      b.phone,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _ClientBottomNav(activeIndex: 1),
    );
  }
}

class _Beneficiary {
  final String name;
  final String email;
  final String phone;
  final String quartier;
  _Beneficiary({
    required this.name,
    required this.email,
    required this.phone,
    required this.quartier,
  });
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}

class _GpsDisabledLayer extends StatefulWidget {
  const _GpsDisabledLayer({Key? key}) : super(key: key);

  @override
  State<_GpsDisabledLayer> createState() => _GpsDisabledLayerState();
}

class _GpsDisabledLayerState extends State<_GpsDisabledLayer> {
  bool _gpsDisabled = false;
  bool _hiddenOnce = false;
  StreamSubscription<ServiceStatus>? _sub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    setState(() {
      _gpsDisabled = !enabled;
      _hiddenOnce = false;
    });
    _sub = Geolocator.getServiceStatusStream().listen((status) {
      setState(() {
        _gpsDisabled = status == ServiceStatus.disabled;
        if (!_gpsDisabled) _hiddenOnce = false; // reset hide when re-enabled
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_gpsDisabled || _hiddenOnce) return const SizedBox.shrink();
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Localisation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Votre position GPS est désactivée.\nVeuillez l\'activer dans les paramètres.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _hiddenOnce = true;
                      });
                    },
                    child: const Text('J\'ai compris'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      await Geolocator.openLocationSettings();
                    },
                    child: const Text('Activer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== MODÈLES ====================

enum OrderStatus {
  pending,      // En attente de paiement
  paid,         // Payée
  processing,   // En cours de traitement
  completed,    // Terminée
  cancelled     // Annulée
}

enum PaymentMethod {
  mobileTransfer,  // Orange Money, Moov Money, etc.
  creditCard,
  cash
}

class Order {
  final String id;
  final String serviceTitle;
  final String servicePrice;
  final double amount;
  final DateTime date;
  final TimeOfDay time;
  final bool pickupAtHome;
  final String instructions;
  final IconData serviceIcon;
  final Color serviceColor;
  final OrderStatus status;
  final PaymentMethod? paymentMethod;
  final String? transactionId;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.serviceTitle,
    required this.servicePrice,
    required this.amount,
    required this.date,
    required this.time,
    required this.pickupAtHome,
    required this.instructions,
    required this.serviceIcon,
    required this.serviceColor,
    this.status = OrderStatus.pending,
    this.paymentMethod,
    this.transactionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceTitle': serviceTitle,
      'servicePrice': servicePrice,
      'amount': amount,
      'date': date.toIso8601String(),
      'time': '${time.hour}:${time.minute}',
      'pickupAtHome': pickupAtHome,
      'instructions': instructions,
      'serviceIcon': serviceIcon.codePoint,
      'serviceColor': serviceColor.value,
      'status': status.index,
      'paymentMethod': paymentMethod?.index,
      'transactionId': transactionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

    // Mise à jour de la méthode fromMap
    factory Order.fromMap(Map<String, dynamic> map) {
      return Order(
        id: map['id'],
        serviceTitle: map['serviceTitle'],
        servicePrice: map['servicePrice'],
        amount: map['amount'] != null
            ? double.tryParse(map['amount'].toString()) ?? 0.0
            : 0.0,
        date: DateTime.parse(map['date']),
        time: TimeOfDay(
          hour: int.parse(map['time'].toString().split(':')[0]),
          minute: int.parse(map['time'].toString().split(':')[1]),
        ),
        pickupAtHome: map['pickupAtHome'] ?? false,
        instructions: map['instructions'] ?? '',
        serviceIcon: IconData(map['serviceIcon'], fontFamily: 'MaterialIcons'),
        serviceColor: Color(map['serviceColor']),
        status: OrderStatus.values[(map['status'] ?? 0) as int],
        paymentMethod: map['paymentMethod'] != null
            ? PaymentMethod.values[(map['paymentMethod']) as int]
            : null,
        transactionId: map['transactionId'],
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'])
            : null,
      );
    }

  Order copyWith({
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    String? transactionId,
  }) {
    return Order(
      id: this.id,
      serviceTitle: this.serviceTitle,
      servicePrice: this.servicePrice,
      amount: this.amount,
      date: this.date,
      time: this.time,
      pickupAtHome: this.pickupAtHome,
      instructions: this.instructions,
      serviceIcon: this.serviceIcon,
      serviceColor: this.serviceColor,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      createdAt: this.createdAt,
    );
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'En attente de paiement';
      case OrderStatus.paid:
        return 'Payée';
      case OrderStatus.processing:
        return 'En cours';
      case OrderStatus.completed:
        return 'Terminée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paid:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

//  SERVICE DE PAIEMENT 

class PaymentService {
  /// Simule un paiement en ligne
  static Future<PaymentResult> processPayment({
    required Order order,
    required PaymentMethod method,
    required String phoneNumber,
  }) async {
    // Simulation d'un délai réseau
    await Future.delayed(const Duration(seconds: 2));

    // Simulation de succès (90% de chance)
    final success = Random().nextDouble() > 0.1;

    if (success) {
      final transactionId = _generateTransactionId();
      return PaymentResult(
        success: true,
        transactionId: transactionId,
        message: 'Paiement effectué avec succès',
      );
    } else {
      return PaymentResult(
        success: false,
        message: 'Échec du paiement. Veuillez réessayer.',
      );
    }
  }

  static String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'TXN${timestamp}_$random';
  }

  static String getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mobileTransfer:
        return 'Mobile Money';
      case PaymentMethod.creditCard:
        return 'Carte bancaire';
      case PaymentMethod.cash:
        return 'Espèces';
    }
  }

  static IconData getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.mobileTransfer:
        return Icons.phone_android;
      case PaymentMethod.creditCard:
        return Icons.credit_card;
      case PaymentMethod.cash:
        return Icons.money;
    }
  }
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String message;

  PaymentResult({
    required this.success,
    this.transactionId,
    required this.message,
  });
}

// ==================== GESTIONNAIRE DE COMMANDES ====================

class OrderManager {
  static Future<List<Order>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey == null) return [];

    final ordersJson = prefs.getString('orders:$emailKey');
    if (ordersJson != null) {
      final List<dynamic> decoded = json.decode(ordersJson);
      return decoded.map((e) => Order.fromMap(e)).toList();
    }
    return [];
  }

  static Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey != null) {
      await prefs.setString(
        'orders:$emailKey',
        json.encode(orders.map((e) => e.toMap()).toList()),
      );
    }
  }

  static Future<void> addOrder(Order order) async {
    final orders = await loadOrders();
    orders.add(order);
    await saveOrders(orders);
  }

  static Future<void> updateOrder(Order order) async {
    final orders = await loadOrders();
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      orders[index] = order;
      await saveOrders(orders);
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    final orders = await loadOrders();
    orders.removeWhere((o) => o.id == orderId);
    await saveOrders(orders);
  }
}

// page liste des commandes 

class ClientOrdersPage extends StatefulWidget {
  const ClientOrdersPage({Key? key}) : super(key: key);

  @override
  State<ClientOrdersPage> createState() => _ClientOrdersPageState();
}

class _ClientOrdersPageState extends State<ClientOrdersPage> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await OrderManager.loadOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.orange.shade700,
        title: Row(
          children: [
            Text(
              'Mes Commandes',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_orders.length}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _navigateToCreateOrder(),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Nouvelle commande',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return OrderCard(
                        order: order,
                        onTap: () => _viewOrderDetails(order),  // ✅ CORRECTION: Cette ligne existe déjà
                        onPay: order.status == OrderStatus.pending
                            ? () => _navigateToPayment(order)
                            : null,
                        onDelete: () => _deleteOrder(order),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune commande',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez par créer une nouvelle commande',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToCreateOrder(),
            icon: const Icon(Icons.add),
            label: const Text('Créer une commande'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToCreateOrder() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOrderPage(
          serviceTitle: 'Nouvelle commande',
          servicePrice: '5000 FCFA',
          serviceIcon: Icons.local_laundry_service,
          serviceColor: Colors.orange.shade700,
        ),
      ),
    );
    if (result == true) await _loadOrders();
  }

  Future<void> _viewOrderDetails(Order order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsPage(order: order),
      ),
    );
    await _loadOrders();
  }

  Future<void> _navigateToPayment(Order order) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(order: order),
      ),
    );
    if (result == true) await _loadOrders();
  }

  Future<void> _deleteOrder(Order order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la commande'),
        content: Text(
          order.status == OrderStatus.paid
              ? 'Cette commande a déjà été payée. Voulez-vous vraiment la supprimer ?'
              : 'Voulez-vous vraiment supprimer cette commande ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await OrderManager.deleteOrder(order.id);
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commande supprimée')),
        );
      }
    }
  }
}

// carte de commande 

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onPay;
  final VoidCallback? onDelete;

  const OrderCard({
    Key? key,
    required this.order,
    this.onTap,
    this.onPay,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: order.serviceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      order.serviceIcon,
                      color: order.serviceColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.serviceTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${order.amount.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: order.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        color: order.statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(order.date),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    order.time.format(context),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              if (order.pickupAtHome) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.home, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Ramassage à domicile',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ],
              if (onPay != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPay,
                    icon: const Icon(Icons.payment, size: 18),
                    label: const Text('Payer maintenant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// page de creation/modification 

class CreateOrderPage extends StatefulWidget {
  final String serviceTitle;
  final String servicePrice;
  final IconData serviceIcon;
  final Color serviceColor;
  final Order? existingOrder;

  const CreateOrderPage({
    Key? key,
    required this.serviceTitle,
    required this.servicePrice,
    required this.serviceIcon,
    required this.serviceColor,
    this.existingOrder,
  }) : super(key: key);

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _instructionsController = TextEditingController();
  final _amountController = TextEditingController();
  
  bool _pickupAtHome = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final e = widget.existingOrder;
    if (e != null) {
      _selectedDate = e.date;
      _selectedTime = e.time;
      _pickupAtHome = e.pickupAtHome;
      _instructionsController.text = e.instructions;
      _amountController.text = e.amount.toStringAsFixed(0);
    } else {
      // Extraire le montant du servicePrice (ex: "5000 FCFA" -> 5000)
      final priceMatch = RegExp(r'\d+').firstMatch(widget.servicePrice);
      if (priceMatch != null) {
        _amountController.text = priceMatch.group(0)!;
      }
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingOrder == null 
          ? 'Nouvelle commande' 
          : 'Modifier la commande'
        ),
        backgroundColor: widget.serviceColor,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildServiceCard(),
            const SizedBox(height: 20),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildPickupSwitch(),
            const SizedBox(height: 16),
            _buildDateTimePickers(),
            const SizedBox(height: 16),
            _buildInstructionsField(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.serviceColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(widget.serviceIcon, color: widget.serviceColor),
        ),
        title: Text(
          widget.serviceTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(widget.servicePrice),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Montant (FCFA)',
        prefixIcon: const Icon(Icons.attach_money),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer le montant';
        }
        if (double.tryParse(value) == null) {
          return 'Montant invalide';
        }
        return null;
      },
    );
  }

  Widget _buildPickupSwitch() {
    return Card(
      elevation: 1,
      child: SwitchListTile(
        title: const Text('Ramassage à domicile'),
        subtitle: const Text('Un livreur viendra chercher votre linge'),
        value: _pickupAtHome,
        onChanged: (value) => setState(() => _pickupAtHome = value),
        secondary: const Icon(Icons.home),
      ),
    );
  }

  Widget _buildDateTimePickers() {
  return Column(
    children: [
      Card(
        elevation: 1,
        child: ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Date'),
          subtitle: Text(
            _selectedDate == null
                ? 'Sélectionner une date'
                : DateFormat('dd/MM/yyyy').format(_selectedDate!), // ✅ Format simple
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _selectDate,
        ),
      ),
      const SizedBox(height: 8),
      Card(
        elevation: 1,
        child: ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text('Heure'),
          subtitle: Text(
            _selectedTime == null
                ? 'Sélectionner une heure'
                : _selectedTime!.format(context),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: _selectTime,
        ),
      ),
    ],
  );
}

  Widget _buildInstructionsField() {
    return TextFormField(
      controller: _instructionsController,
      decoration: InputDecoration(
        labelText: 'Instructions particulières',
        hintText: 'Ex: Taches difficiles, repassage soigné...',
        prefixIcon: const Icon(Icons.note),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      maxLines: 4,
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.serviceColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        widget.existingOrder == null 
          ? 'Créer la commande' 
          : 'Enregistrer les modifications',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  
  Future<void> _selectDate() async {
  final date = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 30)),
    // ❌ RETIREZ CETTE LIGNE: locale: const Locale('fr', 'FR'),
    builder: (ctx, child) {
      return Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: widget.serviceColor, 
            onPrimary: Colors.white,       
            surface: Colors.white,         
            onSurface: Colors.black,       
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: widget.serviceColor),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
  if (date != null && mounted) {
    setState(() => _selectedDate = date);
  }
}


  Future<void> _selectTime() async {
  final time = await showTimePicker(
    context: context,  // ✅ Utiliser le context local
    initialTime: _selectedTime ?? TimeOfDay.now(),
    builder: (ctx, child) {
      return Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: widget.serviceColor,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          dialogBackgroundColor: Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: widget.serviceColor),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
  if (time != null) setState(() => _selectedTime = time);
}


  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs requis'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner la date et l\'heure'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final amount = double.parse(_amountController.text);

    if (widget.existingOrder != null) {
      // Modification
      final updatedOrder = Order(
        id: widget.existingOrder!.id,
        serviceTitle: widget.serviceTitle,
        servicePrice: widget.servicePrice,
        amount: amount,
        date: _selectedDate!,
        time: _selectedTime!,
        pickupAtHome: _pickupAtHome,
        instructions: _instructionsController.text.trim(),
        serviceIcon: widget.serviceIcon,
        serviceColor: widget.serviceColor,
        status: widget.existingOrder!.status,
        paymentMethod: widget.existingOrder!.paymentMethod,
        transactionId: widget.existingOrder!.transactionId,
        createdAt: widget.existingOrder!.createdAt,
      );
      await OrderManager.updateOrder(updatedOrder);
    } else {
      // Création
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        serviceTitle: widget.serviceTitle,
        servicePrice: widget.servicePrice,
        amount: amount,
        date: _selectedDate!,
        time: _selectedTime!,
        pickupAtHome: _pickupAtHome,
        instructions: _instructionsController.text.trim(),
        serviceIcon: widget.serviceIcon,
        serviceColor: widget.serviceColor,
      );
      await OrderManager.addOrder(order);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingOrder != null
              ? 'Commande modifiée avec succès'
              : 'Commande créée avec succès',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop(true);
  }
}

// page de paiement 

class PaymentPage extends StatefulWidget {
  final Order order;

  const PaymentPage({Key? key, required this.order}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  PaymentMethod _selectedMethod = PaymentMethod.mobileTransfer;
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildPaymentForm(),
            const SizedBox(height: 32),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif de la commande',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(widget.order.serviceIcon, color: widget.order.serviceColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.order.serviceTitle,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy à HH:mm').format(
                          DateTime(
                            widget.order.date.year,
                            widget.order.date.month,
                            widget.order.date.day,
                            widget.order.time.hour,
                            widget.order.time.minute,
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Montant total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${widget.order.amount.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Méthode de paiement',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildPaymentMethodOption(
          PaymentMethod.mobileTransfer,
          'Orange Money / Moov Money',
          'Paiement rapide et sécurisé',
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodOption(
          PaymentMethod.creditCard,
          'Carte bancaire',
          'Visa, Mastercard acceptées',
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodOption(
          PaymentMethod.cash,
          'Espèces à la livraison',
          'Paiement en main propre',
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    PaymentMethod method,
    String title,
    String subtitle,
  ) {
    final isSelected = _selectedMethod == method;
    return Card(
      elevation: isSelected ? 3 : 1,
      color: isSelected ? Colors.green.shade50 : null,
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = method),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Radio<PaymentMethod>(
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMethod = value);
                  }
                },
                activeColor: Colors.green,
              ),
              Icon(
                PaymentService.getPaymentMethodIcon(method),
                color: isSelected ? Colors.green.shade700 : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.green.shade700 : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    if (_selectedMethod == PaymentMethod.mobileTransfer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Numéro de téléphone',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              hintText: 'Ex: 70 12 34 56',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vous recevrez un message pour confirmer le paiement',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else if (_selectedMethod == PaymentMethod.creditCard) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(Icons.credit_card, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 12),
            Text(
              'Paiement par carte bancaire',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vous serez redirigé vers une page sécurisée',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.money, size: 48, color: Colors.orange.shade700),
            const SizedBox(height: 12),
            Text(
              'Paiement en espèces',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Préparez le montant exact pour le livreur',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _selectedMethod == PaymentMethod.cash
                    ? 'Confirmer la commande'
                    : 'Payer ${widget.order.amount.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == PaymentMethod.mobileTransfer &&
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer votre numéro de téléphone'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      PaymentResult result;

      if (_selectedMethod == PaymentMethod.cash) {
        // Pour le paiement en espèces, on confirme directement
        result = PaymentResult(
          success: true,
          message: 'Commande confirmée. Paiement à la livraison.',
        );
      } else {
        // Simuler le processus de paiement
        result = await PaymentService.processPayment(
          order: widget.order,
          method: _selectedMethod,
          phoneNumber: _phoneController.text,
        );
      }

      if (result.success) {
        // Mettre à jour le statut de la commande
        final updatedOrder = widget.order.copyWith(
          status: _selectedMethod == PaymentMethod.cash
              ? OrderStatus.pending
              : OrderStatus.paid,
          paymentMethod: _selectedMethod,
          transactionId: result.transactionId,
        );
        await OrderManager.updateOrder(updatedOrder);

        if (!mounted) return;

        // Afficher le succès
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 64,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedMethod == PaymentMethod.cash
                      ? 'Commande confirmée !'
                      : 'Paiement réussi !',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  result.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (result.transactionId != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Ref: ${result.transactionId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // Afficher l'erreur
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600),
                const SizedBox(width: 8),
                const Text('Échec du paiement'),
              ],
            ),
            content: Text(result.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

//  page des détails de la commande 

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  String _formatTime(TimeOfDay time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la commande'),
        backgroundColor: order.serviceColor,
        actions: [
          if (order.status == OrderStatus.pending)
            IconButton(
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentPage(order: order),
                  ),
                );
                if (result == true && context.mounted) {
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.payment),
              tooltip: 'Payer',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildServiceInfo(),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.access_time,
              'Heure',
              _formatTime(order.time),  
            ),
            _buildPaymentInfo(),
            if (order.instructions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInstructions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 3,
      color: order.statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: order.statusColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(),
                color: order.statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.statusLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: order.statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Commande #${order.id.substring(0, 8)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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

  Widget _buildServiceInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: order.serviceColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    order.serviceIcon,
                    color: order.serviceColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.serviceTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.amount.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo() {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rendez-vous',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Date',
            DateFormat('dd/MM/yyyy').format(order.date), // ✅ Format simple
          ),
          const Divider(height: 24),
          _buildInfoRow(
            Icons.access_time,
            'Heure',
            _formatTime(order.time), // ✅ Utiliser la méthode helper
          ),
          const Divider(height: 24),
          _buildInfoRow(
            order.pickupAtHome ? Icons.home : Icons.store,
            'Lieu',
            order.pickupAtHome ? 'Ramassage à domicile' : 'Au pressing',
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPaymentInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paiement',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            if (order.paymentMethod != null) ...[
              _buildInfoRow(
                PaymentService.getPaymentMethodIcon(order.paymentMethod!),
                'Méthode',
                PaymentService.getPaymentMethodLabel(order.paymentMethod!),
              ),
              if (order.transactionId != null) ...[
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.receipt,
                  'Référence',
                  order.transactionId!,
                ),
              ],
            ] else ...[
              _buildInfoRow(
                Icons.payment,
                'Statut',
                'En attente de paiement',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, size: 18, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Instructions particulières',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.instructions,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case OrderStatus.pending:
        return Icons.pending_actions;
      case OrderStatus.paid:
        return Icons.check_circle;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

class _ClientProfilePage extends StatefulWidget {
  const _ClientProfilePage({Key? key}) : super(key: key);

  @override
  State<_ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<_ClientProfilePage> {
  String? _name;
  String? _email;
  String? _phone;
  String? _address1;
  String? _address2;
  String? _phone2;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey == null) return;
    final b64 = prefs.getString('profile:' + emailKey + ':photo_b64');
    setState(() {
      _name = prefs.getString('profile:' + emailKey + ':name');
      _email = prefs.getString('profile:' + emailKey + ':email');
      _phone = prefs.getString('profile:' + emailKey + ':phone');
      _address1 = prefs.getString('profile:' + emailKey + ':address1');
      _address2 = prefs.getString('profile:' + emailKey + ':address2');
      _phone2 = prefs.getString('profile:' + emailKey + ':phone2');
      _photoBytes = (b64 != null && b64.isNotEmpty) ? base64Decode(b64) : null;
    });
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
                title: Text(
                  _photoBytes == null
                      ? 'Ajouter une photo'
                      : 'Modifier la photo',
                ),
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
      await _viewPhoto();
    } else if (choice == 'change') {
      await _pickPhoto();
    } else if (choice == 'delete') {
      await _deletePhoto();
    }
  }

  Future<void> _viewPhoto() async {
    if (_photoBytes == null) return;
    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.7,
                  maxWidth: MediaQuery.of(ctx).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_photoBytes!, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (image == null) return;
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey == null) return;
    final bytes = await image.readAsBytes();
    final b64 = base64Encode(bytes);
    await prefs.setString('profile:' + emailKey + ':photo_b64', b64);
    setState(() {
      _photoBytes = bytes;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer la photo'),
          content: const Text(
            'Voulez-vous vraiment supprimer votre photo de profil ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey != null) {
      await prefs.remove('profile:' + emailKey + ':photo_b64');
    }
    setState(() {
      _photoBytes = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil supprimée'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange.shade700,
        title: Text(
          'Mon profil',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showPhotoOptions, 
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.orange.shade100,
                        backgroundImage: (_photoBytes != null) ? MemoryImage(_photoBytes!) : null,
                        child: (_photoBytes == null)
                            ? const Icon(Icons.person, size: 64, color: Colors.white70)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      _name ?? 'Utilisateur',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _ProfileField(
                title: 'Mon numéro de téléphone',
                value: _phone ?? '',
              ),
              _EditableProfileField(
                title: 'Mon 2nd numéro de téléphone',
                value: _phone2 ?? '',
                keyboardType: TextInputType.phone,
                onSaved: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  final emailKey = prefs.getString('current_user_email');
                  if (emailKey != null) {
                    await prefs.setString(
                      'profile:' + emailKey + ':phone2',
                      val,
                    );
                    setState(() => _phone2 = val);
                  }
                },
              ),
              _ProfileField(title: 'Mon email', value: _email ?? ''),
              _ProfileField(title: 'Mon adresse', value: _address1 ?? ''),
              _EditableProfileField(
                title: 'Ma 2nde adresse',
                value: _address2 ?? '',
                keyboardType: TextInputType.streetAddress,
                onSaved: (val) async {
                  final prefs = await SharedPreferences.getInstance();
                  final emailKey = prefs.getString('current_user_email');
                  if (emailKey != null) {
                    await prefs.setString(
                      'profile:' + emailKey + ':address2',
                      val,
                    );
                    setState(() => _address2 = val);
                  }
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Options',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _OptionItem(
                icon: Icons.edit_note,
                iconColor: Colors.orange,
                title: 'Changer mes informations',
                onTap: _editMainInfo,
              ),
              _OptionItem(
                icon: Icons.phone_in_talk,
                iconColor: Colors.green,
                title: 'Contactez-nous',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Contact: support@yelebara.app | +226 xx xx xx xx',
                      ),
                    ),
                  );
                },
              ),
              _OptionItem(
                icon: Icons.star_rate_rounded,
                iconColor: Colors.amber,
                title: 'Notez-nous',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bientôt disponible sur le store.'),
                    ),
                  );
                },
              ),
              _OptionItem(
                icon: Icons.share,
                iconColor: Colors.lightBlue,
                title: 'Partagez cette application',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lien de partage bientôt disponible.'),
                    ),
                  );
                },
              ),
              _OptionItem(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Se déconnecter',
                onTap: _logout,
                trailingColor: Colors.red,
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supprimer mon compte',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Vous pouvez supprimer votre compte à tout moment. Vos informations personnelles seront supprimées de cet appareil.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _confirmDeleteAccount,
                        child: const Text('Supprimer mon compte'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const _GpsDisabledLayer(),
          // Bouton d'action rapide
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateOrderPage(
                      serviceTitle: 'Nouvelle commande',
                      servicePrice: '',
                      serviceIcon: Icons.local_laundry_service,
                      serviceColor: Colors.orange.shade700,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.orange.shade700,
              icon: const Icon(Icons.add),
              label: const Text('Passer une commande'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _ClientBottomNav(activeIndex: 3),
    );
  }

  Future<void> _editMainInfo() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _EditProfilePage(
          initialName: _name ?? '',
          initialPhone: _phone ?? '',
          initialPhone2: _phone2 ?? '',
          initialEmail: _email ?? '',
          initialAddress1: _address1 ?? '',
          initialAddress2: _address2 ?? '',
        ),
      ),
    );
    if (saved == true) {
      await _loadProfile();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_email');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Supprimer mon compte'),
          content: const Text(
            'Cette action supprimera vos données locales sur cet appareil. Continuer ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey != null) {
      await prefs.remove('user_role:' + emailKey);
      await prefs.remove('profile:' + emailKey + ':name');
      await prefs.remove('profile:' + emailKey + ':email');
      await prefs.remove('profile:' + emailKey + ':phone');
      await prefs.remove('profile:' + emailKey + ':phone2');
      await prefs.remove('profile:' + emailKey + ':address1');
      await prefs.remove('profile:' + emailKey + ':address2');
      await prefs.remove('profile:' + emailKey + ':photo_b64');
    }
    await prefs.remove('current_user_email');
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileField({Key? key, required this.title, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _EditableProfileField extends StatelessWidget {
  final String title;
  final String value;
  final TextInputType keyboardType;
  final Future<void> Function(String value) onSaved;

  const _EditableProfileField({
    Key? key,
    required this.title,
    required this.value,
    required this.keyboardType,
    required this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final controller = TextEditingController(text: value);
        final newValue = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (ctx) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Saisir ici...',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.of(ctx).pop(controller.text.trim()),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        if (newValue != null) {
          await onSaved(newValue);
        }
      },
      child: _ProfileField(title: title, value: value),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Color? trailingColor;

  const _OptionItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailingColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: trailingColor ?? Colors.grey.shade600,
        ),
      ),
    );
  }
}

class _EditProfilePage extends StatefulWidget {
  final String initialName;
  final String initialPhone;
  final String initialPhone2;
  final String initialEmail;
  final String initialAddress1;
  final String initialAddress2;

  const _EditProfilePage({
    Key? key,
    required this.initialName,
    required this.initialPhone,
    required this.initialPhone2,
    required this.initialEmail,
    required this.initialAddress1,
    required this.initialAddress2,
  }) : super(key: key);

  @override
  State<_EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<_EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _phone2Ctrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addr1Ctrl;
  late final TextEditingController _addr2Ctrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
    _phone2Ctrl = TextEditingController(text: widget.initialPhone2);
    _emailCtrl = TextEditingController(text: widget.initialEmail);
    _addr1Ctrl = TextEditingController(text: widget.initialAddress1);
    _addr2Ctrl = TextEditingController(text: widget.initialAddress2);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _phone2Ctrl.dispose();
    _emailCtrl.dispose();
    _addr1Ctrl.dispose();
    _addr2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LabeledField(
            label: 'Nom & Prénom',
            icon: Icons.person_outline,
            controller: _nameCtrl,
          ),
          _LabeledField(
            label: 'Numéro de téléphone',
            icon: Icons.phone,
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          _LabeledField(
            label: '2nd numéro de téléphone',
            icon: Icons.phone,
            controller: _phone2Ctrl,
            keyboardType: TextInputType.phone,
          ),
          _LabeledField(
            label: 'Email',
            icon: Icons.mail_outline,
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _LabeledField(
            label: 'Adresse de livraison',
            icon: Icons.home_outlined,
            controller: _addr1Ctrl,
            keyboardType: TextInputType.streetAddress,
            maxLines: 2,
          ),
          _LabeledField(
            label: '2nde Adresse de livraison',
            icon: Icons.home_outlined,
            controller: _addr2Ctrl,
            keyboardType: TextInputType.streetAddress,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey != null) {
      await prefs.setString(
        'profile:' + emailKey + ':name',
        _nameCtrl.text.trim(),
      );
      await prefs.setString(
        'profile:' + emailKey + ':phone',
        _phoneCtrl.text.trim(),
      );
      await prefs.setString(
        'profile:' + emailKey + ':phone2',
        _phone2Ctrl.text.trim(),
      );
      await prefs.setString(
        'profile:' + emailKey + ':email',
        _emailCtrl.text.trim(),
      );
      await prefs.setString(
        'profile:' + emailKey + ':address1',
        _addr1Ctrl.text.trim(),
      );
      await prefs.setString(
        'profile:' + emailKey + ':address2',
        _addr2Ctrl.text.trim(),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  const _LabeledField({
    Key? key,
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                labelText: label,
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(icon, color: Colors.orange.shade400),
        ],
      ),
    );
  }
}



class _ClientBottomNav extends StatefulWidget {
  final int activeIndex;
  const _ClientBottomNav({Key? key, required this.activeIndex})
    : super(key: key);

  @override
  State<_ClientBottomNav> createState() => _ClientBottomNavState();
}

class _ClientBottomNavState extends State<_ClientBottomNav> {
  int _ordersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }
  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final emailKey = prefs.getString('current_user_email');
    if (emailKey == null) return;
    final ordersJson = prefs.getString('orders:$emailKey');
    if (ordersJson == null) {
      setState(() => _ordersCount = 0);
      return;
    }
    final List<dynamic> decoded = json.decode(ordersJson);
    setState(() => _ordersCount = decoded.length);
  }
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.activeIndex,
      selectedItemColor: Colors.orange.shade700,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == widget.activeIndex) return;
        if (index == 0) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const ClientHomePage()),
            (route) => false,
          );
          return;
        }
        Widget page;
        switch (index) {
          case 1:
            page = const _ClientPressingPage();
            break;
          case 2:
          page = const ClientOrdersPage();
            break;
          case 3:
            page = const _ClientProfilePage();
            break;
          default:
            return;
        }
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => page));
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
              if ((_ordersCount) > 0)
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
                        '${_ordersCount}',
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