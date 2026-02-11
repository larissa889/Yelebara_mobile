enum PersonType {
  homme,
  femme,
  enfant,
}

enum ClothingType {
  // Homme
  haut,
  bas,
  pull,
  complet,
  debardeur,
  
  // Femme
  hautFemme,
  basFemme,
  pullFemme,
  completFemme,
  robe,
  debardeurFemme,
  
  // Enfant
  hautEnfant,
  basEnfant,
  pullEnfant,
}

extension ClothingTypeExtension on ClothingType {
  String get displayName {
    switch (this) {
      // Homme
      case ClothingType.haut: return 'Haut';
      case ClothingType.bas: return 'Bas';
      case ClothingType.pull: return 'Pull';
      case ClothingType.complet: return 'Complet';
      case ClothingType.debardeur: return 'Debardeur';
      
      // Femme
      case ClothingType.hautFemme: return 'Haut';
      case ClothingType.basFemme: return 'Bas';
      case ClothingType.pullFemme: return 'Pull';
      case ClothingType.completFemme: return 'Complet';
      case ClothingType.robe: return 'Robe';
      case ClothingType.debardeurFemme: return 'Debardeur';
      
      // Enfant
      case ClothingType.hautEnfant: return 'Haut';
      case ClothingType.basEnfant: return 'Bas';
      case ClothingType.pullEnfant: return 'Pull';
    }
  }
  
  PersonType get personType {
    switch (this) {
      // Homme
      case ClothingType.haut:
      case ClothingType.bas:
      case ClothingType.pull:
      case ClothingType.complet:
      case ClothingType.debardeur:
        return PersonType.homme;
      
      // Femme
      case ClothingType.hautFemme:
      case ClothingType.basFemme:
      case ClothingType.pullFemme:
      case ClothingType.completFemme:
      case ClothingType.robe:
      case ClothingType.debardeurFemme:
        return PersonType.femme;
      
      // Enfant
      case ClothingType.hautEnfant:
      case ClothingType.basEnfant:
      case ClothingType.pullEnfant:
        return PersonType.enfant;
    }
  }
  
  // Poids fixe en grammes - Plus d'intervalles
  double get fixedWeight {
    switch (this) {
      // Homme - Poids fixes
      case ClothingType.haut: return 300; // 0,3KG
      case ClothingType.bas: return 500; // 0,5KG
      case ClothingType.pull: return 600; // 0,6KG
      case ClothingType.complet: return 1000; // 1KG
      case ClothingType.debardeur: return 25; // 0,025KG
      
      // Femme - Poids fixes
      case ClothingType.hautFemme: return 300; // 0,3KG
      case ClothingType.basFemme: return 500; // 0,5KG
      case ClothingType.pullFemme: return 600; // 0,6KG
      case ClothingType.completFemme: return 1000; // 1KG
      case ClothingType.robe: return 1000; // 1KG
      case ClothingType.debardeurFemme: return 25; // 0,025KG
      
      // Enfant - Poids fixes
      case ClothingType.hautEnfant: return 150; // 0,15KG
      case ClothingType.basEnfant: return 400; // 0,4KG
      case ClothingType.pullEnfant: return 300; // 0,3KG
    }
  }

  // Prix par kilogramme en Francs
  double get pricePerKg {
    switch (this) {
      // Homme et Femme - 500F/kg
      case ClothingType.haut:
      case ClothingType.bas:
      case ClothingType.pull:
      case ClothingType.complet:
      case ClothingType.debardeur:
      case ClothingType.hautFemme:
      case ClothingType.basFemme:
      case ClothingType.pullFemme:
      case ClothingType.completFemme:
      case ClothingType.robe:
      case ClothingType.debardeurFemme:
        return 500;
      
      // Enfant - Prix variables
      case ClothingType.hautEnfant: return 400; // 400F/kg
      case ClothingType.basEnfant: return 250; // 250F/kg
      case ClothingType.pullEnfant: return 400; // 400F/kg
    }
  }
  
  // Poids fixe pour le calcul
  double get averageWeight {
    return fixedWeight;
  }
}

extension PersonTypeExtension on PersonType {
  String get displayName {
    switch (this) {
      case PersonType.homme: return 'Homme';
      case PersonType.femme: return 'Femme';
      case PersonType.enfant: return 'Enfant';
    }
  }
  
  List<ClothingType> get availableClothingTypes {
    return ClothingType.values.where((type) => type.personType == this).toList();
  }
}
