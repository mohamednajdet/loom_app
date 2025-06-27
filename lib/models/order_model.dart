class OrderModel {
  final String id;
  final int orderNumber;
  final String status;
  final String address;
  final int totalPrice;
  final int deliveryFee;
  final DateTime createdAt;
  final List<OrderProduct> products;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.address,
    required this.totalPrice,
    required this.deliveryFee,
    required this.createdAt,
    required this.products,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      orderNumber: json['orderNumber'] ?? 0,
      status: json['status'],
      address: json['address'],
      totalPrice: json['totalPrice'],
      deliveryFee: json['deliveryFee'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      products: (json['products'] as List)
          .map((p) => OrderProduct.fromJson(p))
          .toList(),
    );
  }
}

class OrderProduct {
  final String id;
  final String name;
  final String image;
  final int quantity;
  final int priceAtOrder;         // السعر لحظة الطلب
  final int? originalPrice;       // السعر الأصلي (بدون خصم)
  final int? discountedPrice;     // السعر بعد الخصم (قد يكون null لو ماكو خصم)
  final int? discount;            // نسبة الخصم
  final String color;
  final String size;

  OrderProduct({
    required this.id,
    required this.name,
    required this.image,
    required this.quantity,
    required this.priceAtOrder,
    this.originalPrice,
    this.discountedPrice,
    this.discount,
    required this.color,
    required this.size,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    final product = json['productId'];
    return OrderProduct(
      id: product['_id'],
      name: product['name'],
      image: product['images'] != null && (product['images'] as List).isNotEmpty
          ? product['images'][0]
          : '',
      quantity: json['quantity'],
      priceAtOrder: json['priceAtOrder'],
      originalPrice: product['price'],                // السعر الأصلي
      discountedPrice: product['discountedPrice'],    // السعر المخفض (إذا موجود)
      discount: product['discount'],                  // نسبة الخصم
      color: json['color'] ?? '',
      size: json['size'] ?? '',
    );
  }
}
