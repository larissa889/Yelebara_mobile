import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/clothing_model.dart';
import '../../data/services/clothing_calculator.dart';
import 'dart:io';
import 'location_selection_page.dart';
import 'payment_page.dart';
import 'package:yelebara_mobile/features/orders/presentation/widgets/order_step_footer.dart';

class ClothingSelectionProvider extends StateNotifier<Map<ClothingType, int>> {
  ClothingSelectionProvider({required this.pickupAtHome, required this.serviceType}) : super({});

  final bool pickupAtHome;
  final String serviceType;

  void toggleClothing(ClothingType type, int quantity) {
    final newState = Map<ClothingType, int>.from(state);
    
    if (quantity <= 0) {
      newState.remove(type);
    } else {
      newState[type] = quantity;
    }
    
    state = newState;
  }

  void clearSelection() {
    state = {};
  }

  CalculationResult get calculationResult {
    // Utiliser la méthode de calcul appropriée selon le service
    if (serviceType.toLowerCase().contains('pressing complet')) {
      return ClothingCalculator.calculateFullPressingPrice(
        state,
        pickupAtHome: true, // Livraison obligatoire pour le pressing complet
      );
    } else if (serviceType.toLowerCase().contains('repassage')) {
      return ClothingCalculator.calculateIroningPrice(
        state,
        pickupAtHome: true, // Livraison obligatoire pour le repassage
      );
    } else {
      return ClothingCalculator.calculatePrice(
        state,
        pickupAtHome: pickupAtHome,
      );
    }
  }
}

final clothingSelectionProvider = StateNotifierProvider.family<ClothingSelectionProvider, Map<ClothingType, int>, ({bool pickupAtHome, String serviceType})>((ref, params) {
  return ClothingSelectionProvider(pickupAtHome: params.pickupAtHome, serviceType: params.serviceType);
});

class ClothingSelectionPage extends ConsumerStatefulWidget {
  final String serviceTitle;
  final IconData serviceIcon;
  final Color serviceColor;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final bool pickupAtHome;
  final String instructions;
  final String? deliveryAddress;
  final File? housePhoto;
  final bool useCurrentLocation;

  const ClothingSelectionPage({
    Key? key,
    required this.serviceTitle,
    required this.serviceIcon,
    required this.serviceColor,
    required this.selectedDate,
    required this.selectedTime,
    required this.pickupAtHome,
    required this.instructions,
    this.deliveryAddress,
    this.housePhoto,
    this.useCurrentLocation = false,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  final double? latitude;
  final double? longitude;

  @override
  ConsumerState<ClothingSelectionPage> createState() => _ClothingSelectionPageState();
}

class _ClothingSelectionPageState extends ConsumerState<ClothingSelectionPage> {
  Set<PersonType> selectedPersonTypes = <PersonType>{};
  
  // Stocker les sélections par catégorie pour ne pas les perdre
  final Map<PersonType, Map<ClothingType, int>> _storedSelections = {};
  
  // Obtenir TOUTES les sélections stockées
  Map<ClothingType, int> _getAllStoredSelections() {
    final allSelections = <ClothingType, int>{};
    
    // Fusionner toutes les sélections stockées
    for (final storedSelection in _storedSelections.values) {
      for (final entry in storedSelection.entries) {
        if (entry.value > 0) {
          allSelections[entry.key] = (allSelections[entry.key] ?? 0) + entry.value;
        }
      }
    }
    
    // Ajouter aussi la sélection actuelle si elle n'est pas encore stockée
    if (selectedPersonTypes.isNotEmpty) {
      final currentSelection = ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)));
      for (final entry in currentSelection.entries) {
        if (entry.value > 0) {
          allSelections[entry.key] = (allSelections[entry.key] ?? 0) + entry.value;
        }
      }
    }
    
    return allSelections;
  }
  
  // Calculer le total à partir de toutes les sélections
  CalculationResult _calculateTotalFromAllSelections(Map<ClothingType, int> allSelections) {
    // Utiliser la méthode de calcul appropriée selon le service
    if (widget.serviceTitle.toLowerCase().contains('pressing complet')) {
      return ClothingCalculator.calculateFullPressingPrice(
        allSelections,
        pickupAtHome: true, // Livraison obligatoire pour le pressing complet
      );
    } else if (widget.serviceTitle.toLowerCase().contains('repassage')) {
      return ClothingCalculator.calculateIroningPrice(
        allSelections,
        pickupAtHome: true, // Livraison obligatoire pour le repassage
      );
    } else {
      return ClothingCalculator.calculatePrice(
        allSelections,
        pickupAtHome: widget.pickupAtHome,
      );
    }
  }
  
  // Vérifier le poids et afficher une notification si nécessaire
  void _checkWeightAndShowNotification(double totalWeight) {
    if (totalWeight < 6000) { // 6kg = 6000g
      _showWeightNotification();
    }
  }
  
  // Afficher la notification de poids minimum
  void _showWeightNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nous ne nous déplaçons pas pour un poids inférieur à 6KG',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Calculer le total de TOUTES les sélections stockées
    final allSelections = _getAllStoredSelections();
    final calculationResult = _calculateTotalFromAllSelections(allSelections);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Détails du lavage', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec informations du service
            _buildServiceHeader(),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Sélection des types de personne
                  _buildPersonTypeSelection(),
                  
                  const SizedBox(height: 24),
                  
                  // Sélection des vêtements
                  if (selectedPersonTypes.isNotEmpty) ...[
                    _buildClothingSelection(),
                    const SizedBox(height: 100), // Space for footer
                  ],
                ],
              ),
            ),
            
            // Footer avec résumé et bouton
            _buildBottomSummary(calculationResult),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.serviceColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.serviceIcon, color: widget.serviceColor, size: 24),
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
                      '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year} · ${widget.selectedTime.format(context)}',
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
        ],
      ),
    );
  }

  Widget _buildPersonTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de vêtements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: PersonType.values.map((personType) {
            final isSelected = selectedPersonTypes.contains(personType);
            return FilterChip(
              label: Text(
                personType.displayName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                // ... same logic
                setState(() {
                  if (selected) {
                    final currentSelection = ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)));
                    if (selectedPersonTypes.isNotEmpty) {
                      final currentPersonType = selectedPersonTypes.first;
                      _storedSelections[currentPersonType] = Map.from(currentSelection);
                    }
                    selectedPersonTypes.clear();
                    selectedPersonTypes.add(personType);
                    final storedSelection = _storedSelections[personType] ?? {};
                    ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)).notifier).state = storedSelection;
                  } else {
                    final currentSelection = ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)));
                    _storedSelections[personType] = Map.from(currentSelection);
                    selectedPersonTypes.remove(personType);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: widget.serviceColor,
              checkmarkColor: Colors.white,
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? widget.serviceColor : Colors.grey.shade300,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClothingSelection() {
    // SYSTÈME DE FILTRAGE STRICT : Une seule catégorie à la fois
    if (selectedPersonTypes.isEmpty) {
      return Container(); // Ne rien afficher si aucune catégorie sélectionnée
    }
    
    // Afficher SEULEMENT les vêtements de la catégorie sélectionnée
    final selectedPersonType = selectedPersonTypes.first; // On prend le premier (et seul) type
    final availableClothingTypes = selectedPersonType.availableClothingTypes.toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vêtements ${selectedPersonType.displayName}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...availableClothingTypes.map((clothingType) {
          return _buildClothingItem(clothingType);
        }).toList(),
      ],
    );
  }

  Widget _buildClothingItem(ClothingType clothingType) {
    final currentSelection = ref.watch(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)));
    final quantity = currentSelection[clothingType] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox (Custom)
          InkWell(
            onTap: () {
               if (quantity > 0) {
                  ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)).notifier).toggleClothing(clothingType, 0);
               } else {
                  ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)).notifier).toggleClothing(clothingType, 1);
               }
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: quantity > 0 ? widget.serviceColor : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: quantity > 0 ? widget.serviceColor : Colors.grey.shade400,
                ),
              ),
              child: quantity > 0
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Nom du vêtement
          Expanded(
            child: Text(
              clothingType.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: quantity > 0 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          
          // Sélecteur de quantité
          if (quantity > 0) ...[
            Container(
              decoration: BoxDecoration(
                color: widget.serviceColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 20, color: widget.serviceColor),
                    onPressed: () {
                      if (quantity > 1) {
                        ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)).notifier).toggleClothing(clothingType, quantity - 1);
                      } else {
                        ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)).notifier).toggleClothing(clothingType, 0);
                      }
                    },
                  ),
                  Container(
                    width: 30,
                    alignment: Alignment.center,
                    child: Text(
                      quantity.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.serviceColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 20, color: widget.serviceColor),
                    onPressed: () {
                      ref.read(clothingSelectionProvider((pickupAtHome: widget.pickupAtHome, serviceType: widget.serviceTitle)).notifier).toggleClothing(clothingType, quantity + 1);
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSummary(CalculationResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Résumé
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total vêtements',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${result.totalItems} articles',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Prix total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                result.formattedPrice,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.serviceColor,
                ),
              ),
            ],
          ),
            
            // Afficher les frais de livraison si applicable
            if (result.deliveryCharges > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.serviceTitle.toLowerCase().contains('pressing complet') 
                              ? 'Pressing complet' 
                              : widget.serviceTitle.toLowerCase().contains('repassage') 
                                  ? 'Repassage' 
                                  : 'Lavage',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          result.formattedWashingPrice,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Livraison',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          result.formattedDeliveryCharges,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    if (widget.serviceTitle.toLowerCase().contains('repassage') || widget.serviceTitle.toLowerCase().contains('pressing complet')) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'La livraison est obligatoire pour ce service',
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
                  ],
                ),
              ),
            ],
          
          const SizedBox(height: 16),
          
          // Bouton de validation (Replaced by OrderStepFooter)
          OrderStepFooter(
            currentStep: 3,
            totalSteps: 3,
            onPressed: result.totalItems > 0 ? () => _validateOrder(result) : () {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez sélectionner au moins un vêtement'),
                    backgroundColor: Colors.red,
                  ),
               );
            },
            buttonText: 'Valider le lavage',
            isEnabled: result.totalItems > 0,
          ),
        ],
      ),
    );
  }

  void _validateOrder(CalculationResult result) {
    // Vérifier si le poids est inférieur à 6kg
    if (result.totalWeight < 6000) { // 6kg = 6000g
      _showWeightNotification();
      return; // Arrêter la validation
    }
    
    // Convertir Map<ClothingType, int> en Map<String, dynamic>
    final clothingSelectionMap = <String, dynamic>{};
    for (final entry in result.selectedClothes.entries) {
      clothingSelectionMap[entry.key.name] = entry.value;
    }
    
    // Navigation vers la page de paiement
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          serviceTitle: widget.serviceTitle,
          serviceIcon: widget.serviceIcon,
          serviceColor: widget.serviceColor,
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          pickupAtHome: widget.pickupAtHome,
          instructions: widget.instructions,
          clothingSelection: clothingSelectionMap,
          totalItems: result.totalItems,
          finalPrice: result.finalPrice,
          formattedPrice: result.formattedPrice,
          deliveryAddress: widget.deliveryAddress ?? "Adresse actuelle (tanghin, Ouagadougou)",
          housePhoto: widget.housePhoto,
          useCurrentLocation: widget.useCurrentLocation ?? true,
          latitude: widget.latitude,
          longitude: widget.longitude,
        ),
      ),
    );
  }
}
