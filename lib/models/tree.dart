class Tree {
  final String treeId;
  final String latitude;
  final String longitude;
  final String landmark;
  final String height;
  final String date;
  final String diameter;
  final String health;
  final String harmPrac;
  final String ownerType;
  final String botanical;
  final String local;

  Tree(
      {required this.treeId,
      required this.height,
      required this.longitude,
      required this.latitude,
      required this.landmark,
      required this.date,
      required this.diameter,
      required this.harmPrac,
      required this.ownerType,
      required this.health,
      required this.botanical,
      required this.local});

  factory Tree.fromMap(Map<String, dynamic> data) {
    return Tree(
      height: data['height'],
      longitude: data['longitude'],
      landmark: data['landmark'],
      latitude: data['latitude'],
      treeId: data['treeId'],
      health: data['health'],
      ownerType: data['ownerType'],
      date: data['date'],
      diameter: data['diameter'],
      harmPrac: data['harmPrac'],
      botanical: data['botanical'],
      local: data['local'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'height': height,
      'treeId': treeId,
      'health': health,
      'ownerType': ownerType,
      'date': date,
      'diameter': diameter,
      'harmPrac': harmPrac,
      'local': local,
      'botanical': botanical,
    };
  }
}
