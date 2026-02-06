# Documentation - Sélection de Localisation

## 📍 Vue d'ensemble

Cette page permet aux clients de choisir leur adresse de livraison et d'ajouter une photo de leur maison pour faciliter le repérage par le livreur.

## 🏗️ Fonctionnalités

### 1. Choix de l'adresse
- **Adresse actuelle** : Utilise l'adresse par défaut du profil
- **Nouvelle adresse** : Permet de saisir une adresse différente

### 2. Photo de la maison
- **Source** : Appareil photo ou galerie
- **Optimisation** : Redimensionnement automatique (800x600 max)
- **Qualité** : Compression à 80% pour optimiser la taille
- **Aperçu** : Affichage immédiat avec option de suppression

### 3. Interface utilisateur
- **Résumé de la commande** : Affiche les détails de la commande en cours
- **Indicateur "Recommandé"** : Met en évidence l'ajout de photo
- **Messages d'aide** : Guide l'utilisateur sur les meilleures pratiques
- **Validation** : Vérifie que l'adresse est renseignée si nécessaire

## 🎯 Flux utilisateur

1. **Page clothing-selection** → "Valider le lavage"
2. **Page location-selection** → Choix adresse + photo
3. **Page payment** → Paiement final

## 📱 Composants principaux

### LocationSelectionPage
```dart
class LocationSelectionPage extends ConsumerStatefulWidget {
  // Paramètres de la commande
  final String serviceTitle;
  final IconData serviceIcon;
  final Color serviceColor;
  // ... autres paramètres
}
```

### État local
```dart
bool _useCurrentLocation = true;        // Choix de l'adresse
String? _newAddress;                     // Nouvelle adresse
File? _housePhoto;                       // Photo de la maison
ImagePicker _imagePicker;                // Gestionnaire de photos
```

## 🔧 Fonctionnalités techniques

### Gestion des photos
```dart
Future<void> _pickImage() async {
  final XFile? image = await _imagePicker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 800,
    maxHeight: 600,
    imageQuality: 80,
  );
}
```

### Validation
```dart
void _validateOrder() {
  if (!_useCurrentLocation && _addressController.text.trim().isEmpty) {
    // Afficher erreur
    return;
  }
  // Naviguer vers paiement
}
```

## 🎨 Design et UX

### Couleurs et thèmes
- **Couleur principale** : Héritée du service
- **Couleurs secondaires** : Vert pour "Recommandé", Bleu pour infos
- **Contraste** : Assuré pour l'accessibilité

### Composants UI
- **RadioListTile** : Pour le choix d'adresse
- **Card** : Pour regrouper les options
- **Container** : Pour la zone de photo
- **OutlinedButton** : Pour les actions secondaires

### Messages d'aide
- **Bulle info** : Explique l'utilité de la photo
- **Placeholder** : Guide dans la zone de photo vide
- **Validation** : Messages d'erreur clairs

## 📋 Permissions requises

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Cette app a besoin d'accéder à la caméra pour prendre des photos de votre maison</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Cette app a besoin d'accéder à vos photos pour choisir une image de votre maison</string>
```

## 🔄 Navigation

### Depuis clothing_selection_page.dart
```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => LocationSelectionPage(
      // ... paramètres
    ),
  ),
);
```

### Vers payment
```dart
Navigator.of(context).pushNamed(
  '/payment',
  arguments: {
    // ... tous les paramètres précédents
    'deliveryAddress': address,
    'housePhoto': _housePhoto,
    'useCurrentLocation': _useCurrentLocation,
  },
);
```

## 🚀 Optimisations

### Performance
- **Redimensionnement** des images à la source
- **Compression** pour réduire la taille
- **Lazy loading** des composants

### Expérience utilisateur
- **Feedback immédiat** lors de la sélection
- **Annulation possible** de la photo
- **Sauvegarde** automatique de la saisie

## 📊 Cas d'utilisation

### Cas 1 : Adresse actuelle + photo
1. Client sélectionne "Utiliser mon adresse actuelle"
2. Client ajoute une photo de sa maison
3. Validation et navigation vers paiement

### Cas 2 : Nouvelle adresse + photo
1. Client sélectionne "Changer d'adresse"
2. Client saisit sa nouvelle adresse
3. Client ajoute une photo
4. Validation et navigation vers paiement

### Cas 3 : Adresse sans photo
1. Client choisit une adresse (actuelle ou nouvelle)
2. Client saute l'étape photo
3. Validation avec avertissement mais navigation autorisée

## 🔮 Évolutions possibles

1. **Géolocalisation automatique** : GPS pour détecter l'adresse
2. **Carte interactive** : Sélection sur carte
3. **Photos multiples** : Plusieurs angles de la maison
4. **Historique** : Mémoriser les adresses précédentes
5. **Partage de position** : Envoyer la position en temps réel

---

*Cette documentation complète la fonctionnalité de sélection de localisation dans le processus de commande.*
