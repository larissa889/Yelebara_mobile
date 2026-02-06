# Documentation - Page de Paiement

## 💳 Vue d'ensemble

Cette page permet aux clients de choisir leur mode de paiement parmi les options disponibles au Burkina Faso : Orange Money, Moov Money, Wave et Espèces.

## 🏗️ Modes de paiement disponibles

### 1. Mobile Money
- **Orange Money** : Paiement via le service Orange
- **Moov Money** : Paiement via le service Moov
- **Wave** : Paiement via l'application Wave

### 2. Espèces
- **Paiement à la livraison** : Paiement directement au livreur

## 🎨 Fonctionnalités

### Interface utilisateur
- **Sélection visuelle** : Cartes de paiement avec couleurs de marque
- **Formulaire dynamique** : Champs adaptés selon le mode choisi
- **Messages d'aide** : Instructions claires pour chaque méthode
- **Résumé de commande** : Affiche tous les détails de la commande

### Traitement du paiement
- **Validation** : Vérification des champs requis
- **Simulation** : Processus de paiement de 3 secondes
- **Feedback** : Indicateur de chargement et messages
- **Succès** : Dialog de confirmation avec numéro de commande

## 🎯 Flux utilisateur

1. **Sélection du mode** : Clic sur la carte de paiement souhaitée
2. **Saisie des informations** : Numéro de téléphone pour Mobile Money
3. **Validation** : Clic sur "Payer maintenant"
4. **Traitement** : Simulation du processus de paiement
5. **Confirmation** : Dialog de succès et retour à l'accueil

## 📱 Composants principaux

### PaymentMethod Enum
```dart
enum PaymentMethod {
  orangeMoney,    // Couleur orange
  moovMoney,      // Couleur turquoise
  wave,           // Couleur vert clair
  cash,           // Couleur verte
}
```

### Extensions
```dart
extension PaymentMethodExtension on PaymentMethod {
  String get displayName;  // Nom affiché
  String get logoName;     // Nom du logo
  Color get brandColor;    // Couleur de marque
}
```

## 🎨 Design et UX

### Couleurs de marque
- **Orange Money** : `Colors.orange`
- **Moov Money** : `Color(0xFF00BFA5)` (Turquoise)
- **Wave** : `Color(0xFF00D4AA)` (Vert clair)
- **Espèces** : `Colors.green`

### Composants UI
- **Cartes de paiement** : 120x80px avec icône et nom
- **Formulaires** : Champs stylisés avec couleurs de marque
- **Messages d'aide** : Bulles d'information colorées
- **Bouton de paiement** : Pleine largeur avec couleur du service

### États visuels
- **Non sélectionné** : Bordure grise, fond blanc
- **Sélectionné** : Bordure couleur marque, fond transparent
- **Loading** : Spinner circulaire blanc
- **Succès** : Icône verte avec message

## 🔄 Navigation

### Depuis location_selection_page.dart
```dart
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
      clothingSelection: widget.clothingSelection,
      totalItems: widget.totalItems,
      finalPrice: widget.finalPrice,
      formattedPrice: widget.formattedPrice,
      deliveryAddress: address,
      housePhoto: _housePhoto,
      useCurrentLocation: _useCurrentLocation,
    ),
  ),
);
```

### Après paiement réussi
```dart
Navigator.of(context).popUntil((route) => route.isFirst);
```

## 📋 Validation des données

### Mobile Money (Orange/Moov/Wave)
- Numéro de téléphone requis
- Format : +226 XX XX XX XX
- Longueur minimale : 8 caractères

### Espèces
- Aucune validation requise
- Affichage du montant à préparer

## 🚀 Optimisations

### Performance
- **Widgets const** : Optimisation du rendu
- **Lazy loading** : Chargement à la demande
- **State management** : Local et optimisé

### Expérience utilisateur
- **Feedback immédiat** : Sélection visuelle instantanée
- **Messages clairs** : Instructions spécifiques par méthode
- **Gestion d'erreurs** : Messages d'erreur informatifs

## 📊 Cas d'utilisation

### Cas 1 : Orange Money
1. Client sélectionne "Orange Money"
2. Saisit son numéro Orange
3. Reçoit confirmation USSD
4. Paiement validé

### Cas 2 : Moov Money
1. Client sélectionne "Moov Money"
2. Saisit son numéro Moov
3. Reçoit confirmation SMS
4. Paiement validé

### Cas 3 : Wave
1. Client sélectionne "Wave"
2. Saisit son numéro Wave
3. Reçoit notification push
4. Paiement validé

### Cas 4 : Espèces
1. Client sélectionne "Espèces"
2. Prépare le montant exact
3. Paiement au livreur
4. Remise du linge

## 🔮 Évolutions possibles

1. **Intégration réelle** : Connexion aux APIs des opérateurs
2. **Historique** : Sauvegarde des paiements
3. **Portefeuille** : Solde et transactions
4. **Promotions** : Codes de réduction
5. **Abonnements** : Forfaits mensuels

---

*Cette documentation complète la fonctionnalité de paiement dans le processus de commande de Yélébara Mobile.*
