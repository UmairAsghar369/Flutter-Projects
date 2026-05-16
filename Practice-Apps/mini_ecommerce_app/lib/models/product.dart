/// Product model — represents a single product in the store.
class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.category,
  });
}
