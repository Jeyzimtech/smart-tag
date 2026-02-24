class Livestock {
  final String id;
  final String tagId;
  final String name;
  final String species;
  final String status; // Normal, Warning, Critical
  final double temperature;
  final double activityLevel;
  final double latitude;
  final double longitude;
  final DateTime lastSync;
  final String imageUrl;

  Livestock({
    required this.id,
    required this.tagId,
    required this.name,
    required this.species,
    required this.status,
    required this.temperature,
    required this.activityLevel,
    required this.latitude,
    required this.longitude,
    required this.lastSync,
    this.imageUrl = '',
  });

  // Factory constructor for creating a new Livestock instance from a map.
  factory Livestock.fromMap(Map<String, dynamic> map, String id) {
    return Livestock(
      id: id,
      tagId: map['tagId'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      status: map['status'] ?? 'Normal',
      temperature: (map['temperature'] ?? 0.0).toDouble(),
      activityLevel: (map['activityLevel'] ?? 0.0).toDouble(),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      lastSync: map['lastSync'] != null 
          ? DateTime.parse(map['lastSync']) 
          : DateTime.now(),
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
