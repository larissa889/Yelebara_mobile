enum PersonType {
  homme,
  femme,
  enfant,
}

enum ClothingType {
  // Homme
  chemise,
  debardeur,
  jean,
  survetement,
  pantalonTissu,
  boubouTissu,
  boubouBasin,
  veste,
  pull,
  short,
  
  // Femme
  jeanFemme,
  jupe,
  top,
  tunique,
  robeCourte,
  robeLongue,
  robeDentelle,
  robeBasin,
  completPagneDame,
  completDentelle,
  completDamePagneTisse,
  pantalonTissuFemme,
  debardeurFemme,
  chemiseFemme,
  survetementFemme,
  completBoubou,
  foulard,
  voile,
  
  // Enfant
  tshirt,
  chemiseEnfant,
  debardeurEnfant,
  pullEnfant,
  gilet,
  vesteEnfant,
  manteau,
  robeLegere,
  jogging,
  robeEpaisse,
  salopette,
  ensemble,
  grenouillere,
  ensembleBebe,
  chaussettes,
  bonnet,
  gants,
  combinaison,
  pyjama,
  body,
}

extension ClothingTypeExtension on ClothingType {
  String get displayName {
    switch (this) {
      // Homme
      case ClothingType.chemise: return 'Chemise';
      case ClothingType.debardeur: return 'Débardeur';
      case ClothingType.jean: return 'Jean';
      case ClothingType.survetement: return 'Survêtement';
      case ClothingType.pantalonTissu: return 'Pantalon tissu';
      case ClothingType.boubouTissu: return 'Boubou tissu';
      case ClothingType.boubouBasin: return 'Boubou basin';
      case ClothingType.veste: return 'Veste';
      case ClothingType.pull: return 'Pull';
      case ClothingType.short: return 'Short';
      
      // Femme
      case ClothingType.jeanFemme: return 'Jean femme';
      case ClothingType.jupe: return 'Jupe';
      case ClothingType.top: return 'Top';
      case ClothingType.tunique: return 'Tunique';
      case ClothingType.robeCourte: return 'Robe courte';
      case ClothingType.robeLongue: return 'Robe longue';
      case ClothingType.robeDentelle: return 'Robe dentelle';
      case ClothingType.robeBasin: return 'Robe basin';
      case ClothingType.completPagneDame: return 'Complet pagne dame';
      case ClothingType.completDentelle: return 'Complet dentelle';
      case ClothingType.completDamePagneTisse: return 'Complet dame pagne tissé';
      case ClothingType.pantalonTissuFemme: return 'Pantalon tissu';
      case ClothingType.debardeurFemme: return 'Débardeur femme';
      case ClothingType.chemiseFemme: return 'Chemise femme';
      case ClothingType.survetementFemme: return 'Survêtement femme';
      case ClothingType.completBoubou: return 'Complet boubou';
      case ClothingType.foulard: return 'Foulard';
      case ClothingType.voile: return 'Voile';
      
      // Enfant
      case ClothingType.tshirt: return 'T-shirt';
      case ClothingType.chemiseEnfant: return 'Chemise enfant';
      case ClothingType.debardeurEnfant: return 'Débardeur enfant';
      case ClothingType.pullEnfant: return 'Pull enfant';
      case ClothingType.gilet: return 'Gilet';
      case ClothingType.vesteEnfant: return 'Veste enfant';
      case ClothingType.manteau: return 'Manteau';
      case ClothingType.robeLegere: return 'Robe légère';
      case ClothingType.jogging: return 'Jogging';
      case ClothingType.robeEpaisse: return 'Robe épaisse';
      case ClothingType.salopette: return 'Salopette';
      case ClothingType.ensemble: return 'Ensemble';
      case ClothingType.grenouillere: return 'Grenouillère';
      case ClothingType.ensembleBebe: return 'Ensemble bébé';
      case ClothingType.chaussettes: return 'Chaussettes';
      case ClothingType.bonnet: return 'Bonnet';
      case ClothingType.gants: return 'Gants';
      case ClothingType.combinaison: return 'Combinaison';
      case ClothingType.pyjama: return 'Pyjama';
      case ClothingType.body: return 'Body';
    }
  }
  
  PersonType get personType {
    switch (this) {
      // Homme
      case ClothingType.chemise:
      case ClothingType.debardeur:
      case ClothingType.jean:
      case ClothingType.survetement:
      case ClothingType.pantalonTissu:
      case ClothingType.boubouTissu:
      case ClothingType.boubouBasin:
      case ClothingType.veste:
      case ClothingType.pull:
      case ClothingType.short:
        return PersonType.homme;
      
      // Femme
      case ClothingType.jeanFemme:
      case ClothingType.jupe:
      case ClothingType.top:
      case ClothingType.tunique:
      case ClothingType.robeCourte:
      case ClothingType.robeLongue:
      case ClothingType.robeDentelle:
      case ClothingType.robeBasin:
      case ClothingType.completPagneDame:
      case ClothingType.completDentelle:
      case ClothingType.completDamePagneTisse:
      case ClothingType.pantalonTissuFemme:
      case ClothingType.debardeurFemme:
      case ClothingType.chemiseFemme:
      case ClothingType.survetementFemme:
      case ClothingType.completBoubou:
      case ClothingType.foulard:
      case ClothingType.voile:
        return PersonType.femme;
      
      // Enfant
      case ClothingType.tshirt:
      case ClothingType.chemiseEnfant:
      case ClothingType.debardeurEnfant:
      case ClothingType.pullEnfant:
      case ClothingType.gilet:
      case ClothingType.vesteEnfant:
      case ClothingType.manteau:
      case ClothingType.robeLegere:
      case ClothingType.jogging:
      case ClothingType.robeEpaisse:
      case ClothingType.salopette:
      case ClothingType.ensemble:
      case ClothingType.grenouillere:
      case ClothingType.ensembleBebe:
      case ClothingType.chaussettes:
      case ClothingType.bonnet:
      case ClothingType.gants:
      case ClothingType.combinaison:
      case ClothingType.pyjama:
      case ClothingType.body:
        return PersonType.enfant;
    }
  }
  
  // Poids en grammes (min, max) - Basé sur mesures réelles
  (double min, double max) get weightRange {
    switch (this) {
      // Homme - Poids réels mesurés
      case ClothingType.chemise: return (570, 900);
      case ClothingType.debardeur: return (25, 30);
      case ClothingType.jean: return (855, 1000);
      case ClothingType.survetement: return (900, 1000);
      case ClothingType.pantalonTissu: return (480, 900);
      case ClothingType.boubouTissu: return (1000, 1800);
      case ClothingType.boubouBasin: return (1000, 1800);
      case ClothingType.veste: return (580, 620);
      case ClothingType.pull: return (480, 520);
      case ClothingType.short: return (180, 220);
      
      // Femme - Poids réels mesurés
      case ClothingType.jeanFemme: return (855, 1000);
      case ClothingType.jupe: return (180, 220);
      case ClothingType.top: return (120, 180);
      case ClothingType.tunique: return (220, 280);
      case ClothingType.robeCourte: return (575, 1000);
      case ClothingType.robeLongue: return (845, 1000);
      case ClothingType.robeDentelle: return (945, 1000);
      case ClothingType.robeBasin: return (835, 900);
      case ClothingType.completPagneDame: return (900, 1000);
      case ClothingType.completDentelle: return (900, 1000);
      case ClothingType.completDamePagneTisse: return (1800, 1900);
      case ClothingType.pantalonTissuFemme: return (48, 90);
      case ClothingType.debardeurFemme: return (25, 30);
      case ClothingType.chemiseFemme: return (570, 900);
      case ClothingType.survetementFemme: return (900, 1000);
      case ClothingType.completBoubou: return (1000, 1800);
      case ClothingType.foulard: return (100, 250);
      case ClothingType.voile: return (100, 200);
      
      // Enfant - Poids réels mesurés
      case ClothingType.tshirt: return (100, 140);
      case ClothingType.chemiseEnfant: return (150, 300);
      case ClothingType.debardeurEnfant: return (20, 25);
      case ClothingType.pullEnfant: return (300, 600);
      case ClothingType.gilet: return (250, 500);
      case ClothingType.vesteEnfant: return (400, 800);
      case ClothingType.manteau: return (800, 1500);
      case ClothingType.robeLegere: return (250, 500);
      case ClothingType.jogging: return (600, 900);
      case ClothingType.robeEpaisse: return (500, 1000);
      case ClothingType.salopette: return (400, 800);
      case ClothingType.ensemble: return (400, 800);
      case ClothingType.grenouillere: return (200, 400);
      case ClothingType.ensembleBebe: return (250, 500);
      case ClothingType.chaussettes: return (50, 100);
      case ClothingType.bonnet: return (50, 100);
      case ClothingType.gants: return (50, 100);
      case ClothingType.combinaison: return (180, 220);
      case ClothingType.pyjama: return (140, 180);
      case ClothingType.body: return (80, 120);
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
