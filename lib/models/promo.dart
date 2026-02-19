class PromotionModel {
  final String? id;
  final String nama;
  final int min;
  final double nominal; 
  final bool isTypeFood;

  PromotionModel({
    this.id,
    required this.nama,
    required this.min,
    required this.nominal,
    required this.isTypeFood,
  });


  Map<String, dynamic> toMap() {
    return {
      "nama": nama,
      "min": min,
      "nominal": nominal,
      "isTypeFood": isTypeFood,
    };
  }

  factory PromotionModel.fromMap(Map<String, dynamic> data, [String? id]) {
    return PromotionModel(
      id: id,
      nama: data['nama'],
      min: data['min'],
      nominal: data['nominal'],
      isTypeFood: data['isTypeFood'],
    );
  }
}