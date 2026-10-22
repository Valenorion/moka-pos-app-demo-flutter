// lib/menu_data.dart

class Product {
  final int id;
  final String name, detail, image, category, tag;
  final double price;

  Product(
    this.id,
    this.name,
    this.detail,
    this.price,
    this.category,
    this.tag,
    this.image,
  );
}

final List<Product> products = [
  Product(
    1,
    "Moka Cloud",
    "Mocha · sea salt cream",
    58000,
    "Signature",
    "BEST",
    "assets/images/menu/moka_cloud.jpg",
  ),
  Product(
    2,
    "Pink Latte",
    "Strawberry · oat milk",
    62000,
    "Signature",
    "NEW",
    "assets/images/menu/pink_latte.jpg",
  ),
  Product(
    3,
    "Iced Latte",
    "Espresso · fresh milk",
    49000,
    "Coffee",
    "",
    "assets/images/menu/iced_latte.jpg",
  ),
  Product(
    4,
    "Mochaccino",
    "Cocoa · double shot",
    54000,
    "Coffee",
    "",
    "assets/images/menu/mochaccino.jpg",
  ),
  Product(
    5,
    "Matcha Float",
    "Pure matcha · vanilla",
    55000,
    "Non-coffee",
    "NEW",
    "assets/images/menu/matcha_float.jpg",
  ),
  Product(
    6,
    "Caramel Macchiato",
    "Espresso · caramel drip",
    52000,
    "Coffee",
    "POPULAR",
    "assets/images/menu/caramel_macchiato.png",
  ),
  Product(
    7,
    "Velvet Shake",
    "Red velvet · cream cheese",
    58000,
    "Non-coffee",
    "",
    "assets/images/menu/velvet_shake.png",
  ),
  Product(
    8,
    "Espresso Single",
    "Pure dark arabica blend",
    35000,
    "Coffee",
    "",
    "assets/images/menu/espresso.png",
  ),
  Product(
    9,
    "Moka Toast Nutella",
    "Crispy toast · hazelnut",
    42000,
    "Signature",
    "SNACK",
    "assets/images/menu/moka_toast_nutella.png",
  ),
  Product(
    10,
    "Peach Cold Brew",
    "Cold brew · peach tea",
    48000,
    "Coffee",
    "FRESH",
    "assets/images/menu/peach_cold_brew.png",
  ),
  Product(
    11,
    "Es Teh Ajib",
    "Es Teh · JUMBO",
    5000,
    "Non-coffee",
    "JUMBO",
    "assets/images/menu/esteh_ajib.png",
  ),
];
