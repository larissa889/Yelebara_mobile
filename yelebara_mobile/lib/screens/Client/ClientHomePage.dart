import 'package:flutter/material.dart';
import 'package:yelebara_mobile/screens/Client/HomeTab.dart';
import 'package:yelebara_mobile/screens/Client/OrderTab.dart';
import 'package:yelebara_mobile/screens/Client/PaymentTab.dart';
import 'package:yelebara_mobile/screens/Client/ReviewTab.dart';
import 'package:yelebara_mobile/screens/Client/SearchTab.dart';
import 'package:yelebara_mobile/screens/Client/TrackingTab.dart';

class ClientHomePage extends StatefulWidget {
  final String? confirmationMessage;

  const ClientHomePage({
    Key? key,
    this.confirmationMessage,
  }) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeTab(),
      const SearchTab(),
      const OrderTab(),
      const TrackingTab(),
      const PaymentTab(),
      const ReviewTab(),
    ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange.shade600,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service),
            label: 'Commande',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Suivi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: 'Paiements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_rate),
            label: 'Avis',
          ),
        ],
      ),
    );
  }
}