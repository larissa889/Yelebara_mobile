import '../models/clothing_model.dart';

class ClothingCalculator {
  static const int pricePerKg = 500; // FCFA par kg
  static const int priceMultiple = 500; // Multiple pour l'arrondi
  
  /// Calcule le prix total basé sur les vêtements sélectionnés
  static CalculationResult calculatePrice(Map<ClothingType, int> selectedClothes) {
    double totalWeight = 0;
    int totalItems = 0;
    
    // Calcul du poids total
    for (final entry in selectedClothes.entries) {
      final clothingType = entry.key;
      final quantity = entry.value;
      
      if (quantity > 0) {
        totalWeight += clothingType.averageWeight * quantity;
        totalItems += quantity;
      }
    }
    
    // Conversion en kg
    final weightInKg = totalWeight / 1000;
    
    // Calcul du prix brut
    final rawPrice = weightInKg * pricePerKg;
    
    // Arrondi au multiple de 500 supérieur
    final finalPrice = (rawPrice / priceMultiple).ceil() * priceMultiple;
    
    return CalculationResult(
      totalWeight: totalWeight,
      weightInKg: weightInKg,
      totalItems: totalItems,
      rawPrice: rawPrice,
      finalPrice: finalPrice,
      selectedClothes: selectedClothes,
    );
  }
}

class CalculationResult {
  final double totalWeight; // en grammes
  final double weightInKg;  // en kg
  final int totalItems;
  final double rawPrice;
  final int finalPrice;
  final Map<ClothingType, int> selectedClothes;
  
  CalculationResult({
    required this.totalWeight,
    required this.weightInKg,
    required this.totalItems,
    required this.rawPrice,
    required this.finalPrice,
    required this.selectedClothes,
  });
  
  /// Formate le prix pour l'affichage
  String get formattedPrice => '${finalPrice.toString()} FCFA';
  
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
