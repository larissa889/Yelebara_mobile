enum PersonType {
  homme,
  femme,
  enfant,
}

enum ClothingType {
  // Homme
  chemise,
  pantalon,
  veste,
  pull,
  short,
  calecon,
  
  // Femme
  robe,
  jupe,
  top,
  tunique,
  legging,
  soutien,
  
  // Enfant
  tshirt,
  combinaison,
  pyjama,
  body,
}

extension ClothingTypeExtension on ClothingType {
  String get displayName {
    switch (this) {
      // Homme
      case ClothingType.chemise: return 'Chemise';
      case ClothingType.pantalon: return 'Pantalon';
      case ClothingType.veste: return 'Veste';
      case ClothingType.pull: return 'Pull';
      case ClothingType.short: return 'Short';
      case ClothingType.calecon: return 'Caleçon';
      
      // Femme
      case ClothingType.robe: return 'Robe';
      case ClothingType.jupe: return 'Jupe';
      case ClothingType.top: return 'Top';
      case ClothingType.tunique: return 'Tunique';
      case ClothingType.legging: return 'Legging';
      case ClothingType.soutien: return 'Soutien-gorge';
      
      // Enfant
      case ClothingType.tshirt: return 'T-shirt';
      case ClothingType.combinaison: return 'Combinaison';
      case ClothingType.pyjama: return 'Pyjama';
      case ClothingType.body: return 'Body';
    }
  }
  
  PersonType get personType {
    switch (this) {
      // Homme
      case ClothingType.chemise:
      case ClothingType.pantalon:
      case ClothingType.veste:
      case ClothingType.pull:
      case ClothingType.short:
      case ClothingType.calecon:
        return PersonType.homme;
      
      // Femme
      case ClothingType.robe:
      case ClothingType.jupe:
      case ClothingType.top:
      case ClothingType.tunique:
      case ClothingType.legging:
      case ClothingType.soutien:
        return PersonType.femme;
      
      // Enfant
      case ClothingType.tshirt:
      case ClothingType.combinaison:
      case ClothingType.pyjama:
      case ClothingType.body:
        return PersonType.enfant;
    }
  }
  
  // Poids en grammes (min, max)
  (double min, double max) get weightRange {
    switch (this) {
      // Homme
      case ClothingType.chemise: return (150, 250);
      case ClothingType.pantalon: return (300, 500);
      case ClothingType.veste: return (400, 800);
      case ClothingType.pull: return (350, 600);
      case ClothingType.short: return (150, 300);
      case ClothingType.calecon: return (50, 100);
      
      // Femme
      case ClothingType.robe: return (250, 600);
      case ClothingType.jupe: return (150, 400);
      case ClothingType.top: return (100, 250);
      case ClothingType.tunique: return (200, 400);
      case ClothingType.legging: return (200, 350);
      case ClothingType.soutien: return (50, 150);
      
      // Enfant
      case ClothingType.tshirt: return (80, 200);
      case ClothingType.combinaison: return (150, 400);
      case ClothingType.pyjama: return (120, 300);
      case ClothingType.body: return (60, 150);
    }
  }
  
  // Poids moyen pour le calcul
  double get averageWeight {
    final range = weightRange;
    return (range.$1 + range.$2) / 2;
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
