class Livestock {
  final int? id;
  final String tagId;
  final String breed;
  final String species;
  final String herd;
  final String status;
  final DateTime dateRegistered;
  final double? temperature;
  final double? activityLevel;
  final double? latitude;
  final double? longitude;

  Livestock({
    this.id,
    required this.tagId,
    required this.breed,
    required this.species,
    required this.herd,
    this.status = 'active',
    required this.dateRegistered,
    this.temperature,
    this.activityLevel,
    this.latitude,
    this.longitude,
  });

  factory Livestock.fromMap(Map<String, dynamic> map) {
    return Livestock(
      id: map['id'] as int?,
      tagId: map['tagId'] ?? '',
      breed: map['breed'] ?? '',
      species: map['species'] ?? '',
      herd: map['herd'] ?? '',
      status: map['status'] ?? 'active',
      dateRegistered: map['dateRegistered'] != null 
          ? DateTime.parse(map['dateRegistered']) 
          : DateTime.now(),
      temperature: map['temperature'] != null ? (map['temperature'] as num).toDouble() : null,
      activityLevel: map['activityLevel'] != null ? (map['activityLevel'] as num).toDouble() : null,
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
    );
  }
}
