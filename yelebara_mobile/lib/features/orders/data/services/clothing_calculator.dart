import '../models/clothing_model.dart';

class ClothingCalculator {
  static const int pricePerKg = 500; // FCFA par kg
  static const int priceMultiple = 500; // Multiple pour l'arrondi
  static const int deliveryFee = 1000; // Frais de livraison en FCFA
  static const int ironingPricePerItem = 50; // FCFA par vêtement pour le repassage
  
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
    // Si pickupAtHome = true (livreur vient chercher), frais de livraison applicables
    // Si pickupAtHome = false (pas de livraison), pas de frais
    final deliveryCharges = pickupAtHome ? deliveryFee.toDouble() : 0.0;
    
    // Prix brut (lavage + livraison)
    final rawPrice = washingPrice + deliveryCharges;
    
    // Pas d'arrondi - calcul exact
    final finalPrice = rawPrice.round().toInt();
    
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
  
  /// Calcule le prix pour le repassage (50F par vêtement, livraison obligatoire)
  static CalculationResult calculateIroningPrice(
    Map<ClothingType, int> selectedClothes, {
    bool pickupAtHome = true, // Forcé à true pour le repassage
  }) {
    int totalItems = 0;
    
    // Calcul du nombre total d'articles
    for (final entry in selectedClothes.entries) {
      totalItems += entry.value;
    }
    
    // Calcul du prix du repassage (50F par article)
    final ironingPrice = (totalItems * ironingPricePerItem).toDouble();
    
    // Pour le repassage, la livraison est obligatoire
    final deliveryCharges = deliveryFee.toDouble();
    
    // Prix brut (repassage + livraison)
    final rawPrice = ironingPrice + deliveryCharges;
    
    // Pas d'arrondi - calcul exact
    final finalPrice = rawPrice.round().toInt();
    
    return CalculationResult(
      totalWeight: 0, // Pas de poids pour le repassage
      weightInKg: 0,
      totalItems: totalItems,
      washingPrice: ironingPrice, // Utilisé comme prix du repassage
      deliveryCharges: deliveryCharges,
      rawPrice: rawPrice,
      finalPrice: finalPrice,
      selectedClothes: selectedClothes,
      pickupAtHome: true, // Forcé à true pour le repassage
      calculationMethod: 'Repassage',
    );
  }
  
  /// Calcule le prix pour le pressing complet (lavage + repassage, livraison obligatoire)
  static CalculationResult calculateFullPressingPrice(
    Map<ClothingType, int> selectedClothes, {
    bool pickupAtHome = true, // Forcé à true pour le pressing complet
  }) {
    double totalWeight = 0;
    int totalItems = 0;
    
    // Calcul du poids total pour le lavage
    for (final entry in selectedClothes.entries) {
      final clothingType = entry.key;
      final quantity = entry.value;
      
      if (quantity > 0) {
        totalWeight += clothingType.averageWeight * quantity;
        totalItems += quantity;
      }
    }
    
    // Conversion en kg pour le lavage
    final weightInKg = totalWeight / 1000;
    
    // Calcul du prix du lavage
    final washingPrice = weightInKg * pricePerKg;
    
    // Calcul du prix du repassage (50F par article)
    final ironingPrice = (totalItems * ironingPricePerItem).toDouble();
    
    // Pour le pressing complet, la livraison est obligatoire
    final deliveryCharges = deliveryFee.toDouble();
    
    // Prix brut (lavage + repassage + livraison)
    final rawPrice = washingPrice + ironingPrice + deliveryCharges;
    
    // Pas d'arrondi - calcul exact
    final finalPrice = rawPrice.round().toInt();
    
    return CalculationResult(
      totalWeight: totalWeight,
      weightInKg: weightInKg,
      totalItems: totalItems,
      washingPrice: washingPrice + ironingPrice, // Lavage + repassage
      deliveryCharges: deliveryCharges,
      rawPrice: rawPrice,
      finalPrice: finalPrice,
      selectedClothes: selectedClothes,
      pickupAtHome: true, // Forcé à true pour le pressing complet
      calculationMethod: 'Pressing complet',
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
