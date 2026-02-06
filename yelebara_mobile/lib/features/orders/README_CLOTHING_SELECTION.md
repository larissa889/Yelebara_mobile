# Documentation - Sélection des Vêtements

## 📋 Vue d'ensemble

Cette fonctionnalité permet aux clients de sélectionner leurs vêtements pour un service de lavage, avec un calcul automatique du prix basé sur le poids estimé des articles.

## 🏗️ Architecture

### 1. Modèle de données (`clothing_model.dart`)
- **PersonType**: Enum pour Homme/Femme/Enfant
- **ClothingType**: Enum pour tous les types de vêtements
- **Extensions**: Méthodes utilitaires pour les poids et affichages

### 2. Calculateur (`clothing_calculator.dart`)
- **ClothingCalculator**: Logique de calcul du prix
- **CalculationResult**: Résultat formaté pour l'affichage

### 3. Interface utilisateur (`clothing_selection_page.dart`)
- **ClothingSelectionProvider**: State management avec Riverpod
- **ClothingSelectionPage**: Interface complète de sélection

## 🎯 Flux utilisateur

1. **Page create-order** → Sélection date/heure → Bouton "Continuer"
2. **Page clothing-selection** → Sélection types/personnes → Sélection vêtements → Calcul auto → Bouton "Valider"
3. **Page payment** → Paiement avec prix calculé

## 💡 Règles métier implémentées

### Poids des vêtements (interne)
```dart
// Exemples de poids en grammes
Chemise: (150, 250)      // moyenne: 200g
Pantalon: (300, 500)     // moyenne: 400g
Robe: (250, 600)         // moyenne: 425g
```

### Calcul du prix
```dart
poids_total = somme(poids_moyens × quantités)
prix_brut = (poids_total / 1000) × 500 FCFA
prix_final = arrondi_supérieur(prix_brut, 500)
```

## 🚀 Intégration

### Dans home_page.dart
```dart
context.push('/create-order', extra: {
  'serviceTitle': title,
  'serviceIcon': icon,
  'serviceColor': colorScheme.primary,
});
```

### Dans create_order_page.dart
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ClothingSelectionPage(
      serviceTitle: widget.serviceTitle,
      serviceIcon: widget.serviceIcon,
      serviceColor: widget.serviceColor,
      selectedDate: _selectedDate!,
      selectedTime: _selectedTime!,
      pickupAtHome: _pickupAtHome,
      instructions: _instructionsController.text.trim(),
    ),
  ),
);
```

## 🎨 Personnalisation

### Ajouter un nouveau vêtement
```dart
enum ClothingType {
  // ... existants
  nouvelle_veste, // Ajouter ici
  
  // Ajouter dans l'extension:
  case ClothingType.nouvelle_veste: 
    return 'Nouvelle veste';
  
  // Ajouter le poids:
  case ClothingType.nouvelle_veste: 
    return (400, 700); // poids min, max en grammes
  
  // Ajouter le type de personne:
  // Défini automatiquement par la propriété personType
}
```

### Modifier le tarif
```dart
class ClothingCalculator {
  static const int pricePerKg = 600; // Changer ici
  static const int priceMultiple = 100; // Changer ici
}
```

## 🔧 Maintenance

### Code modulaire
- **Séparation des responsabilités**: Modèle, Calcul, UI
- **Extensions Dart**: Code lisible et maintenable
- **State management**: Riverpod pour la réactivité

### Tests recommandés
```dart
// Tests unitaires pour le calculateur
test('Calcul prix avec 2 chemises', () {
  final selection = {ClothingType.chemise: 2};
  final result = ClothingCalculator.calculatePrice(selection);
  expect(result.finalPrice, 500); // 2 × 200g = 400g → 0.4kg → 200 FCFA → 500 FCFA
});
```

## 📱 UX Optimizations

### Temps réel
- Calcul instantané lors de la sélection
- Mise à jour du prix en bas de page
- Feedback visuel immédiat

### Accessibilité
- FilterChip pour sélection multiple
- Boutons +/ - pour quantités
- Résumé clair avant validation

### Performance
- State management optimisé
- Calculs légers
- Navigation fluide

## 🔄 Évolutions possibles

1. **Personnalisation des poids**: Par utilisateur ou type de tissu
2. **Promotions**: Réductions par quantité
3. **Historique**: Mémoriser les sélections fréquentes
4. **Photos**: Ajout d'images pour chaque vêtement
5. **Categories**: Sous-catégories (ex: Chemises habillées/casuelles)

---

*Cette documentation est vivante et doit être mise à jour avec chaque évolution de la fonctionnalité.*
