
class CartItem {
  final String id;
  final String name;
  final int price;
  int qty;
  final String imageURL;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    required this.imageURL,
  });

  int get totalPrice => price * qty;
}