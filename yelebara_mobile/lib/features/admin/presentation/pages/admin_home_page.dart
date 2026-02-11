import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yelebara_mobile/features/auth/presentation/controllers/auth_provider.dart';

class AdminHomePage extends ConsumerStatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends ConsumerState<AdminHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _AdminDashboardPage(),
    _AdminUsersPage(),
    _AdminValidationsPage(),
    _AdminZonesPage(),
    _AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange.shade700,
        title: Text(
          _titleForIndex(_currentIndex),
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
           IconButton(
            icon: const Icon(Icons.logout),
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
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                      child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Utilisateurs'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_user), label: 'Validations'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Zones'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  String _titleForIndex(int i) {
    switch (i) {
      case 0:
        return 'Tableau de bord';
      case 1:
        return 'Utilisateurs';
      case 2:
        return 'Validations';
      case 3:
        return 'Zones';
      case 4:
        return 'Profil admin';
      default:
        return '';
    }
  }
}

// 🧩 Onglet 1 : Tableau de bord
class _AdminDashboardPage extends StatelessWidget {
  const _AdminDashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Aperçu général", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const [
            _DashboardCard(title: "Clients", value: "120"),
            _DashboardCard(title: "Presseurs", value: "45"),
            _DashboardCard(title: "Commandes", value: "325"),
            _DashboardCard(title: "Zones actives", value: "8"),
          ],
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const _DashboardCard({required this.title, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800)),
          const SizedBox(height: 6),
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// 🧩 Onglet 2 : Utilisateurs
class _AdminUsersPage extends StatelessWidget {
  const _AdminUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Liste des utilisateurs"),
        const SizedBox(height: 12),
        ...List.generate(
          5,
          (i) => Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text('Utilisateur ${i + 1}'),
              subtitle: Text(i % 2 == 0 ? 'Client' : 'Presseur'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// 🧩 Onglet 3 : Validations
class _AdminValidationsPage extends StatelessWidget {
  const _AdminValidationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Presseurs en attente de validation"),
        const SizedBox(height: 12),
        ...List.generate(
          3,
          (i) => Card(
            child: ListTile(
              leading: const Icon(Icons.store, color: Colors.orange),
              title: Text('Presseur ${i + 1}'),
              subtitle: const Text('Zone : Ouagadougou'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 🧩 Onglet 4 : Zones
class _AdminZonesPage extends StatefulWidget {
  const _AdminZonesPage({Key? key}) : super(key: key);

  @override
  State<_AdminZonesPage> createState() => _AdminZonesPageState();
}

class _AdminZonesPageState extends State<_AdminZonesPage> {
  List<Map<String, dynamic>> zones = [];

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    final prefs = await SharedPreferences.getInstance();
    final zonesJson = prefs.getString('zones') ?? '[{"id": "1", "name": "Ouaga 2000", "status": "active"}, {"id": "2", "name": "Zone du Bois", "status": "active"}, {"id": "3", "name": "Gounghin", "status": "active"}]';
    try {
      final List<dynamic> zonesList = json.decode(zonesJson);
      setState(() {
        zones = zonesList.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      // En cas d'erreur, utiliser les zones par défaut
      setState(() {
        zones = [
          {"id": "1", "name": "Ouaga 2000", "status": "active"},
          {"id": "2", "name": "Zone du Bois", "status": "active"},
          {"id": "3", "name": "Gounghin", "status": "active"}
        ];
      });
    }
  }

  Future<void> _saveZones() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zones', json.encode(zones));
  }

  Future<void> _addZone() async {
    final TextEditingController nameController = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle zone'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom de la zone',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, nameController.text.trim()),
            child: const Text('Ajouter', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        zones.add({
          "id": (zones.length + 1).toString(),
          "name": result,
          "status": "active"
        });
      });
      await _saveZones();
    }
  }

  Future<void> _toggleZoneStatus(int index) async {
    setState(() {
      zones[index]["status"] = zones[index]["status"] == "active" ? "inactive" : "active";
    });
    await _saveZones();
  }

  Future<void> _deleteZone(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la zone'),
        content: Text('Voulez-vous vraiment supprimer la zone "${zones[index]["name"]}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        zones.removeAt(index);
      });
      await _saveZones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des zones'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bouton pour ajouter une zone
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _addZone,
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle zone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Liste des zones
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: zones.length,
              itemBuilder: (context, index) {
                final zone = zones[index];
                final isActive = zone["status"] == "active";
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isActive ? Colors.green : Colors.grey,
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      zone["name"],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.black87 : Colors.grey.shade600,
                      ),
                    ),
                    subtitle: Text(
                      'Statut: ${isActive ? "Active" : "Inactive"}',
                      style: TextStyle(
                        color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton pour activer/désactiver
                        IconButton(
                          icon: Icon(
                            isActive ? Icons.toggle_on : Icons.toggle_off,
                            color: isActive ? Colors.green : Colors.grey,
                          ),
                          onPressed: () => _toggleZoneStatus(index),
                          tooltip: isActive ? 'Désactiver' : 'Activer',
                        ),
                        const SizedBox(width: 8),
                        // Bouton pour supprimer
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteZone(index),
                          tooltip: 'Supprimer',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 🧩 Onglet 5 : Profil
class _AdminProfilePage extends ConsumerWidget {
  const _AdminProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text("Admin Yélébara",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("admin@yelebara.com"),
              const SizedBox(height: 24),
              ElevatedButton.icon(
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
                          onPressed: () async {
                            Navigator.pop(context);
                            await ref.read(authProvider.notifier).logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          child: const Text('Confirmer', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Se déconnecter"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
