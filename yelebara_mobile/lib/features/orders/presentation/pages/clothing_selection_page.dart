import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/clothing_model.dart';
import '../../data/services/clothing_calculator.dart';
import 'location_selection_page.dart';

class ClothingSelectionProvider extends StateNotifier<Map<ClothingType, int>> {
  ClothingSelectionProvider() : super({});

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

  CalculationResult get calculationResult => ClothingCalculator.calculatePrice(state);
}

final clothingSelectionProvider = StateNotifierProvider<ClothingSelectionProvider, Map<ClothingType, int>>((ref) {
  return ClothingSelectionProvider();
});

class ClothingSelectionPage extends ConsumerStatefulWidget {
  final String serviceTitle;
  final IconData serviceIcon;
  final Color serviceColor;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final bool pickupAtHome;
  final String instructions;

  const ClothingSelectionPage({
    Key? key,
    required this.serviceTitle,
    required this.serviceIcon,
    required this.serviceColor,
    required this.selectedDate,
    required this.selectedTime,
    required this.pickupAtHome,
    required this.instructions,
  }) : super(key: key);

  @override
  ConsumerState<ClothingSelectionPage> createState() => _ClothingSelectionPageState();
}

class _ClothingSelectionPageState extends ConsumerState<ClothingSelectionPage> {
  Set<PersonType> selectedPersonTypes = <PersonType>{};
  
  @override
  Widget build(BuildContext context) {
    final calculationResult = ref.watch(clothingSelectionProvider.notifier).calculationResult;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du lavage'),
        backgroundColor: widget.serviceColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
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
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
          
          // Footer avec résumé et bouton
          _buildBottomSummary(calculationResult),
        ],
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.serviceColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: widget.serviceColor.withOpacity(0.3))),
      ),
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
              label: Text(personType.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedPersonTypes.add(personType);
                  } else {
                    selectedPersonTypes.remove(personType);
                    // Supprimer les vêtements de ce type
                    final currentSelection = ref.read(clothingSelectionProvider);
                    final newSelection = Map<ClothingType, int>.from(currentSelection);
                    newSelection.removeWhere((key, value) => key.personType == personType);
                    ref.read(clothingSelectionProvider.notifier).state = newSelection;
                  }
                });
              },
              backgroundColor: Colors.grey.shade200,
              selectedColor: widget.serviceColor.withOpacity(0.2),
              checkmarkColor: widget.serviceColor,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClothingSelection() {
    final availableClothingTypes = selectedPersonTypes
        .expand((personType) => personType.availableClothingTypes)
        .toSet()
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sélectionnez les vêtements',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...availableClothingTypes.map((clothingType) {
          return _buildClothingItem(clothingType);
        }),
      ],
    );
  }

  Widget _buildClothingItem(ClothingType clothingType) {
    final currentSelection = ref.watch(clothingSelectionProvider);
    final quantity = currentSelection[clothingType] ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: quantity > 0,
              onChanged: (value) {
                if (value == true) {
                  ref.read(clothingSelectionProvider.notifier).toggleClothing(clothingType, 1);
                } else {
                  ref.read(clothingSelectionProvider.notifier).toggleClothing(clothingType, 0);
                }
              },
              activeColor: widget.serviceColor,
            ),
            
            // Nom du vêtement
            Expanded(
              child: Text(
                clothingType.displayName,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            // Sélecteur de quantité
            if (quantity > 0) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: widget.serviceColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () {
                        if (quantity > 1) {
                          ref.read(clothingSelectionProvider.notifier).toggleClothing(clothingType, quantity - 1);
                        } else {
                          ref.read(clothingSelectionProvider.notifier).toggleClothing(clothingType, 0);
                        }
                      },
                      color: widget.serviceColor,
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.serviceColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        ref.read(clothingSelectionProvider.notifier).toggleClothing(clothingType, quantity + 1);
                      },
                      color: widget.serviceColor,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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
          
          const SizedBox(height: 16),
          
          // Bouton de validation
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: result.totalItems > 0 ? () => _validateOrder(result) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.serviceColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Valider le lavage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateOrder(CalculationResult result) {
    // Convertir Map<ClothingType, int> en Map<String, dynamic>
    final clothingSelectionMap = <String, dynamic>{};
    for (final entry in result.selectedClothes.entries) {
      clothingSelectionMap[entry.key.name] = entry.value;
    }
    
    // Navigation vers la page de localisation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationSelectionPage(
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
        ),
      ),
    );
  }
}
