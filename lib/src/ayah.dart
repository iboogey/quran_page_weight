/// A single ayah, identified by sura number (1–114) and ayah number
/// within the sura (1-based).
class Ayah {
  final int sura;
  final int aya;

  const Ayah(this.sura, this.aya);

  @override
  bool operator ==(Object other) =>
      other is Ayah && other.sura == sura && other.aya == aya;

  @override
  int get hashCode => Object.hash(sura, aya);

  @override
  String toString() => 'Ayah($sura, $aya)';
}
