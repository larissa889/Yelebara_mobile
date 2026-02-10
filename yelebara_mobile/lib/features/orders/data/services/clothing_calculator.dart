import '../models/clothing_model.dart';

class ClothingCalculator {
  static const int pricePerKg = 500; // FCFA par kg
  static const int priceMultiple = 500; // Multiple pour l'arrondi
  static const int deliveryFee = 1000; // Frais de livraison en FCFA
  
  /// Calcule le prix total basé sur les vêtements sélectionnés
  static CalculationResult calculatePrice(
    Map<ClothingType, int> selectedClothes, {
    bool useAverageWeight = true,
    bool useMaxWeight = false,
    bool pickupAtHome = true,
  }) {
    double totalWeight = 0;
    int totalItems = 0;
    
    // Calcul du poids total
    for (final entry in selectedClothes.entries) {
      final clothingType = entry.key;
      final quantity = entry.value;
      
      if (quantity > 0) {
        double weight;
        if (useMaxWeight) {
          weight = clothingType.weightRange.$2; // Poids maximum
        } else if (useAverageWeight) {
          weight = clothingType.averageWeight; // Poids moyen
        } else {
          weight = clothingType.weightRange.$1; // Poids minimum
        }
        
        totalWeight += weight * quantity;
        totalItems += quantity;
      }
    }
    
    // Conversion en kg
    final weightInKg = totalWeight / 1000;
    
    // Calcul du prix du lavage
    final washingPrice = weightInKg * pricePerKg;
    
    // Ajout des frais de livraison si nécessaire
    final deliveryCharges = pickupAtHome ? 0.0 : deliveryFee.toDouble();
    
    // Prix brut (lavage + livraison)
    final rawPrice = washingPrice + deliveryCharges;
    
    // Arrondi au multiple de 500 supérieur
    final finalPrice = (rawPrice / priceMultiple).ceil() * priceMultiple;
    
    return CalculationResult(
      totalWeight: totalWeight,
      weightInKg: weightInKg,
      totalItems: totalItems,
      washingPrice: washingPrice,
      deliveryCharges: deliveryCharges,
      rawPrice: rawPrice,
      finalPrice: finalPrice,
      selectedClothes: selectedClothes,
      pickupAtHome: pickupAtHome,
      calculationMethod: useMaxWeight ? 'Maximum' : 
                      useAverageWeight ? 'Moyen' : 'Minimum',
    );
  }
}

class CalculationResult {
  final double totalWeight; // en grammes
  final double weightInKg;  // en kg
  final int totalItems;
  final double washingPrice;
  final double deliveryCharges;
  final double rawPrice;
  final int finalPrice;
  final Map<ClothingType, int> selectedClothes;
  final bool pickupAtHome;
  final String calculationMethod;
  
  CalculationResult({
    required this.totalWeight,
    required this.weightInKg,
    required this.totalItems,
    required this.washingPrice,
    required this.deliveryCharges,
    required this.rawPrice,
    required this.finalPrice,
    required this.selectedClothes,
    required this.pickupAtHome,
    required this.calculationMethod,
  });
  
  /// Formate le prix pour l'affichage
  String get formattedPrice => '${finalPrice.toString()} FCFA';
  
  /// Formate le prix du lavage pour l'affichage
  String get formattedWashingPrice => '${washingPrice.toStringAsFixed(0)} FCFA';
  
  /// Formate les frais de livraison pour l'affichage
  String get formattedDeliveryCharges => '${deliveryCharges.toStringAsFixed(0)} FCFA';
  
  /// Formate le poids pour l'affichage interne
  String get formattedWeight => '${weightInKg.toStringAsFixed(1)} kg';
  
  /// Retourne le détail des vêtements sélectionnés pour affichage
  List<String> get selectedItemsSummary {
    final summary = <String>[];
    for (final entry in selectedClothes.entries) {
      if (entry.value > 0) {
        summary.add('${entry.value} ${entry.key.displayName}');
      }
    }
    return summary;
  }
}
