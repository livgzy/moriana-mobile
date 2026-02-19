class MenuModel {
  final String id;    
  final String nmMenu;
  final int harga;
  final List<String> isian;
  final String ukuran;
  final String imageURL;

  MenuModel({
    required this.id,
    required this.nmMenu,
    required this.harga,
    required this.isian,
    required this.ukuran,
    required this.imageURL,
  });

  Map<String, dynamic> toMap() {
    return { 
      'nm_menu': nmMenu,
      'harga': harga,
      'isian': isian,
      'ukuran': ukuran,
      'imageURL': imageURL,
    };
  }

  factory MenuModel.fromMap(String id, Map<String, dynamic> map) {
    return MenuModel(
      id: id,
      nmMenu: map['nm_menu'],
      harga: map['harga'],
      isian: (map['isian'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ukuran: map['ukuran'],
      imageURL: map['imageURL'],
    );
  }
}