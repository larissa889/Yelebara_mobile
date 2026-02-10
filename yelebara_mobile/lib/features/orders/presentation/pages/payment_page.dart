import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

class PaymentPage extends ConsumerStatefulWidget {
  final String serviceTitle;
  final IconData serviceIcon;
  final Color serviceColor;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final bool pickupAtHome;
  final String instructions;
  final Map<String, dynamic> clothingSelection;
  final int totalItems;
  final int finalPrice;
  final String formattedPrice;
  final String deliveryAddress;
  final File? housePhoto;
  final bool useCurrentLocation;

  const PaymentPage({
    Key? key,
    required this.serviceTitle,
    required this.serviceIcon,
    required this.serviceColor,
    required this.selectedDate,
    required this.selectedTime,
    required this.pickupAtHome,
    required this.instructions,
    required this.clothingSelection,
    required this.totalItems,
    required this.finalPrice,
    required this.formattedPrice,
    required this.deliveryAddress,
    this.housePhoto,
    required this.useCurrentLocation,
  }) : super(key: key);

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

enum PaymentMethod {
  orangeMoney,
  moovMoney,
  wave,
  cash,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.moovMoney:
        return 'Moov Money';
      case PaymentMethod.wave:
        return 'Wave';
      case PaymentMethod.cash:
        return 'Espèces';
    }
  }

  String get logoName {
    switch (this) {
      case PaymentMethod.orangeMoney:
        return 'orange';
      case PaymentMethod.moovMoney:
        return 'moov';
      case PaymentMethod.wave:
        return 'wave';
      case PaymentMethod.cash:
        return 'cash';
    }
  }

  Color get brandColor {
    switch (this) {
      case PaymentMethod.orangeMoney:
        return Colors.orange;
      case PaymentMethod.moovMoney:
        return const Color(0xFF00BFA5);
      case PaymentMethod.wave:
        return const Color(0xFF00D4AA);
      case PaymentMethod.cash:
        return Colors.green;
    }
  }
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  PaymentMethod _selectedMethod = PaymentMethod.orangeMoney;
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simuler le traitement du paiement
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      // Afficher le succès
      _showPaymentSuccessDialog();

    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du paiement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              const Text('Paiement réussi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Votre commande a été enregistrée avec succès !',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                'Numéro de commande: #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: widget.serviceColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Le livreur passera à l\'adresse indiquée le ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year} à ${widget.selectedTime.hour}:${widget.selectedTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Mode de paiement: ${_selectedMethod.displayName}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Retour à l'accueil
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: widget.serviceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode de paiement'),
        backgroundColor: widget.serviceColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 32),
            // _buildPaymentForm(), // Formulaire de paiement supprimé
            // _buildPayButton(), // Bouton Payer supprimé
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.serviceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.serviceIcon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.serviceTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year} à ${widget.selectedTime.hour}:${widget.selectedTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.totalItems} articles',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  widget.formattedPrice,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.serviceColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.deliveryAddress,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.housePhoto != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.photo, color: Colors.grey.shade600, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Photo de la maison ajoutée',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
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
          'Choisissez un mode de paiement',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Mobile Money
        const Text(
          'Mobile Money',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildPaymentMethodCard(PaymentMethod.orangeMoney),
            _buildPaymentMethodCard(PaymentMethod.moovMoney),
            _buildPaymentMethodCard(PaymentMethod.wave),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
        
        // Naviguer vers la page de paiement dédiée
        switch (method) {
          case PaymentMethod.orangeMoney:
            context.push('/payment/orange-money');
            break;
          case PaymentMethod.moovMoney:
            context.push('/payment/moov-money');
            break;
          case PaymentMethod.wave:
            context.push('/payment/wave');
            break;
          case PaymentMethod.cash:
            // Ne rien faire pour l'espèce (si activé)
            break;
        }
      },
      child: Container(
        width: method == PaymentMethod.cash ? double.infinity : 120,
        height: method == PaymentMethod.cash ? 80 : 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? method.brandColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? method.brandColor.withOpacity(0.1) : Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? method.brandColor : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _getPaymentImage(method),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              method.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? method.brandColor : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPaymentImage(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return Image.asset(
          'assets/images/orange_money.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        );
      case PaymentMethod.moovMoney:
        return Image.asset(
          'assets/images/moov.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        );
      case PaymentMethod.wave:
        return Image.asset(
          'assets/images/wave_burkina.png',
          width: 24,
          height: 24,
          fit: BoxFit.contain,
        );
      case PaymentMethod.cash:
        return Icon(
          Icons.money,
          color: Colors.white,
          size: 24,
        );
    }
  }

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.orangeMoney:
        return Icons.smartphone;
      case PaymentMethod.moovMoney:
        return Icons.smartphone;
      case PaymentMethod.wave:
        return Icons.wifi;
      case PaymentMethod.cash:
        return Icons.money;
    }
  }

  Widget _buildPaymentForm() {
    if (_selectedMethod == PaymentMethod.orangeMoney || 
        _selectedMethod == PaymentMethod.moovMoney || 
        _selectedMethod == PaymentMethod.wave) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedMethod.brandColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPaymentIcon(_selectedMethod),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Numéro ${_selectedMethod.displayName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Entrez votre numéro pour le paiement',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: 'Ex: +226 XX XX XX XX',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _selectedMethod.brandColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedMethod.brandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: _selectedMethod.brandColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vous recevrez une demande de confirmation sur votre téléphone ${_selectedMethod.displayName} pour valider le paiement de ${widget.formattedPrice}',
                        style: TextStyle(
                          color: _selectedMethod.brandColor.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_selectedMethod == PaymentMethod.cash) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.money, color: Colors.green.shade600, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paiement à la livraison',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Payez directement au livreur lors de la remise de votre linge',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Montant à préparer: ${widget.formattedPrice}',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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
    
    return const SizedBox.shrink();
  }

  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.serviceColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Traitement en cours...'),
                ],
              )
            : const Text(
                'Payer maintenant',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
