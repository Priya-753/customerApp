class Location {
  final int id;
  final String name;

  Location({required this.id, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(id: json['id'] as int, name: json['name'] as String);
  }

  static Location? getLocation(List<Location> locations, int id) {
    Location? location;
    List.generate(locations.length, (i) {
      if (locations[i].id == id) {
        location = locations[i];
      }
    });
    return location;
  }
}
