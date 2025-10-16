import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  final String? confirmationMessage;

  const AdminHomePage({
    Key? key,
    this.confirmationMessage,
  }) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Simulation des données (à remplacer par ton API Laravel)
  List<Map<String, dynamic>> demandes = [
    {'id': 1, 'nom': 'Ouédraogo Salif', 'email': 'salif@mail.com', 'statut': 'en_attente'},
    {'id': 2, 'nom': 'Zongo Awa', 'email': 'awa@mail.com', 'statut': 'en_attente'},
  ];

  List<Map<String, dynamic>> messagesMaintenance = [
    {'id': 1, 'nom': 'Sawadogo Idrissa', 'message': 'Ma machine ne démarre plus.'},
    {'id': 2, 'nom': 'Kaboré Mariam', 'message': 'Besoin de mise à jour du logiciel.'},
  ];

  @override
  void initState() {
    super.initState();
    // Afficher le message de confirmation si présent
    if (widget.confirmationMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.confirmationMessage!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      });
    }
  }

  void _confirmerDemande(int id) {
    setState(() {
      demandes.removeWhere((d) => d['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Demande confirmée avec succès"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejeterDemande(int id) {
    setState(() {
      demandes.removeWhere((d) => d['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Demande rejetée"),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de bord Admin"),
        backgroundColor: Colors.green.shade700,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Demandes
            Row(
              children: [
                Icon(Icons.people, color: Colors.green.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  "Demandes de bénéficiaires en attente",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Liste des demandes
            if (demandes.isEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "Aucune demande en attente",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            else
              ...demandes.map((demande) => Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(
                      Icons.person,
                      color: Colors.green.shade700,
                    ),
                  ),
                  title: Text(
                    demande['nom'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(demande['email']),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        tooltip: 'Confirmer',
                        onPressed: () => _confirmerDemande(demande['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Rejeter',
                        onPressed: () => _rejeterDemande(demande['id']),
                      ),
                    ],
                  ),
                ),
              )),

            const SizedBox(height: 30),
            const Divider(thickness: 2),
            const SizedBox(height: 20),

            // Section Messages de maintenance
            Row(
              children: [
                Icon(Icons.build, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 8),
                const Text(
                  "Messages de maintenance",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Liste des messages
            if (messagesMaintenance.isEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "Aucun message de maintenance",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              )
            else
              ...messagesMaintenance.map((msg) => Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Icon(
                      Icons.build,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  title: Text(
                    msg['nom'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(msg['message']),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: () {
                      // Action pour voir les détails du message
                    },
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}