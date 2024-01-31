class InfoPlant {
  final int plantID;
  final String common_name;
  final String scientific_name;
  final String sun;
  final String soil;
  final String water;
  final String soilph;
  final String fertilizer;
  final String growth;

  InfoPlant(
      {required this.plantID,
      required this.common_name,
      required this.scientific_name,
      required this.sun,
      required this.soil,
      required this.water,
      required this.soilph,
      required this.fertilizer,
      required this.growth});
}

List<InfoPlant> infoPlants = [
  InfoPlant(
    plantID: 1,
    common_name: 'Hibiscus',
    scientific_name: 'Hibiscus rosa-sinensis',
    sun: 'Full sun, Partial shade',
    soil: '	Moist, Well-drained',
    water: 'Daily',
    soilph: 'Neutral to acidic',
    fertilizer: 'High potassium and high nitrogen fertilizer',
    growth: 'Height: 1.2 m to 3 m, Spread: 1.2 m to 1.8 m',
  ),
  InfoPlant(
      plantID: 2,
      common_name: 'Bougainvillea',
      scientific_name: 'Bougainvillea glabra',
      soil: 'Well-drained',
      sun: 'Full sun',
      water: 'Deep watering every 3-4 weeks',
      soilph: 'Acidic',
      fertilizer: 'General-purpose balanced fertilizer (10-10-10)',
      growth: 'Height: 3 m to 7 m, Spread: 3 m to 12 m'),
  InfoPlant(
    plantID: 3,
    common_name: 'Franggipani',
    scientific_name: 'Plumeria alba',
    soil: 'Loamy, Sandy, Well-drained',
    sun: 'Full sun, partial shade',
    water: 'Daily',
    soilph: 'Neutral to acidic',
    fertilizer:
        'High phosphorus and low in nitrogen fertilizer, with added iron and magnesium (10-15-10 or 10-30-10)',
    growth: 'Height: Up to 8 m, Spread: Up to 4 m',
  ),
  InfoPlant(
      plantID: 4,
      common_name: 'Mango',
      scientific_name: 'Mangifera indica',
      soil: 'Any soil, Free-draining',
      sun: 'Full sun',
      water:
          'Start by watering it every other day before gradually increasing the time between irrigation to once or twice a week for the first year.',
      soilph: '-',
      fertilizer: 'High potassium fertilizer',
      growth: 'Height: 30 m to 35 m, Spread: Up to 10 m'),
  InfoPlant(
    plantID: 5,
    common_name: 'Pomergranate',
    scientific_name: 'Punica granatum',
    soil: 'Well-Drained',
    sun: 'Full Sun',
    water:
        'Even and regular schedule every 2-4 weeks when establishing new tree',
    soilph: '-',
    fertilizer:
        'Organic fruit tree fertilizer to support their relatively fast growth.',
    growth: 'Height: 1.8 m to 6 m, Spread: 1.2 m to 4.5 m',
  ),
  InfoPlant(
    plantID: 6,
    common_name: 'Guava',
    scientific_name: "Psidium guajava",
    soil: 'Well-draining, sandy loam to clay loam',
    sun: 'Full Sun',
    water:
        'Every other day for a week and then once or twice a week through the growing season',
    soilph: '6.5-7.5 pH.',
    fertilizer:
        'Nitrogen, phosphoric acid, and potash, with added magnesium (6-6-6-2) for maximum fruit production',
    growth: 'Height: 3 to 10 m',
  ),
];
