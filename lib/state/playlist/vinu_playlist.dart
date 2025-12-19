class VinuPlaylist {
  String id;
  String name;
  List<int> songIds;

  VinuPlaylist({
    required this.id,
    required this.name,
    required this.songIds,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "songIds": songIds,
      };

  factory VinuPlaylist.fromJson(Map<String, dynamic> json) {
    return VinuPlaylist(
      id: json["id"] as String,
      name: json["name"] as String,
      songIds: List<int>.from(json["songIds"] ?? <int>[]),
    );
  }
}
