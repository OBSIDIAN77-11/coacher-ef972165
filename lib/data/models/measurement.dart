/// De 17 meetwaardes, met exact dezelfde measure_key-strings als de
/// React-app en de database (progress_measurements.measure_key).
class MeasureMeta {
  const MeasureMeta(this.key, this.label, this.unit);

  final String key;
  final String label;
  final String unit;
}

const measures = [
  MeasureMeta('gewicht', 'Gewicht', 'kg'),
  MeasureMeta('bmi', 'BMI', ''),
  MeasureMeta('vetpercentage', 'Vetpercentage', '%'),
  MeasureMeta('vetvrije_massa', 'Vetvrije massa', 'kg'),
  MeasureMeta('spiermassa', 'Spiermassa', 'kg'),
  MeasureMeta('botmassa', 'Botmassa percentage', '%'),
  MeasureMeta('visceraal_vet', 'Visceraal vet', ''),
  MeasureMeta('schouder', 'Schouderomtrek', 'cm'),
  MeasureMeta('borst', 'Borstomtrek', 'cm'),
  MeasureMeta('taille', 'Tailleomtrek', 'cm'),
  MeasureMeta('buik', 'Buikomtrek', 'cm'),
  MeasureMeta('heup', 'Heupomtrek', 'cm'),
  MeasureMeta('bil', 'Bilomtrek', 'cm'),
  MeasureMeta('rechterarm', 'Rechterarmomtrek', 'cm'),
  MeasureMeta('rechteronderarm', 'Rechteronderarmomtrek', 'cm'),
  MeasureMeta('rechterbovenbeen', 'Rechterbovenbeenomtrek', 'cm'),
  MeasureMeta('rechterkuit', 'Rechterkuitomtrek', 'cm'),
];

class MeasurePoint {
  const MeasurePoint(this.date, this.value);

  final DateTime date;
  final double value;
}

/// Fotocategorieën (progress_photos.photo_key).
const photoCategories = [
  ('voor', 'Vooraanzicht'),
  ('zij', 'Zijaanzicht'),
  ('achter', 'Achteraanzicht'),
  ('extra', "Extra foto's"),
];

class PhotoItem {
  const PhotoItem({required this.id, required this.path, required this.url});

  final String id;
  final String path;
  final String url;
}
