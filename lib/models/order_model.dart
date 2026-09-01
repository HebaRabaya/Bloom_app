
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================
// Order Item Model
// ============================================================
//
// هذا الموديل يمثل منتج واحد داخل الطلب.
//
// الـ Order ممكن يحتوي على أكثر من Product،
// لذلك كل Product داخل الـ Order بنخزنه كـ OrderItemModel.
// ============================================================

class OrderItemModel {
final String productId;
final String productName;
final String productImage;
final double productPrice;
final int quantity;

OrderItemModel({
required this.productId,
required this.productName,
required this.productImage,
required this.productPrice,
required this.quantity,
});

// ============================================================
// Firestore → OrderItemModel
// ============================================================

factory OrderItemModel.fromMap(
Map<String, dynamic> map,
) {
return OrderItemModel(
productId:
map['productId']?.toString() ?? '',

productName:
map['productName']?.toString() ?? '',

productImage:
map['productImage']?.toString() ?? '',

productPrice:
_toDouble(map['productPrice']),

quantity:
_toInt(map['quantity']),
);
}

// ============================================================
// OrderItemModel → Firestore
// ============================================================

Map<String, dynamic> toMap() {
return {
'productId': productId,
'productName': productName,
'productImage': productImage,
'productPrice': productPrice,
'quantity': quantity,
};
}

// ============================================================
// Convert To Double
// ============================================================

static double _toDouble(dynamic value) {
if (value is num) {
return value.toDouble();
}

return double.tryParse(
value?.toString() ?? '',
) ??
0.0;
}

// ============================================================
// Convert To Int
// ============================================================

static int _toInt(dynamic value) {
if (value is num) {
return value.toInt();
}

return int.tryParse(
value?.toString() ?? '',
) ??
0;
}
}

// ============================================================
// Order Model
// ============================================================
//
// يمثل الطلب الكامل للمستخدم.
//
// الطلب الجديد يحتوي على:
// - User information
// - Address
// - List of products
// - Total amount
// - Status
// - Created date
//
// وفيه دعم للـ Orders القديمة اللي كانت تحتوي Product واحد.
// ============================================================

class OrderModel {
final String id;

final String userId;
final String userName;
final String userPhone;

final String address;

final List<OrderItemModel> items;

final double totalAmount;

final String status;

final DateTime? createdAt;

OrderModel({
required this.id,
required this.userId,
required this.userName,
required this.userPhone,
required this.address,
required this.items,
required this.totalAmount,
required this.status,
required this.createdAt,
});

// ============================================================
// Firestore → OrderModel
// ============================================================

factory OrderModel.fromMap(
String id,
Map<String, dynamic> map,
) {
// ==========================================================
// Read New Orders
// ==========================================================
//
// الـ Order الجديد بخزن المنتجات داخل:
//
// items: [
//   {
//     productId,
//     productName,
//     productImage,
//     productPrice,
//     quantity
//   }
// ]
// ==========================================================

final List<OrderItemModel> orderItems = [];

final rawItems = map['items'];

if (rawItems is List) {
for (final item in rawItems) {
if (item is Map) {
orderItems.add(
OrderItemModel.fromMap(
Map<String, dynamic>.from(item),
),
);
}
}
}

// ==========================================================
// Support Old Orders
// ==========================================================
//
// قبل ما نعمل Cart، كان الـ Order يحتوي Product واحد
// مباشرة داخل document.
//
// إذا لقينا البيانات القديمة، بنحوّلها تلقائيًا
// إلى OrderItemModel واحد.
// ==========================================================

if (orderItems.isEmpty &&
map['productId'] != null) {
orderItems.add(
OrderItemModel(
productId:
map['productId']?.toString() ?? '',

productName:
map['productName']?.toString() ?? '',

productImage:
map['productImage']?.toString() ?? '',

productPrice:
_toDouble(map['productPrice']),

quantity:
_toInt(map['quantity']) == 0
? 1
    : _toInt(map['quantity']),
),
);
}

// ==========================================================
// Created At
// ==========================================================

DateTime? createdDate;

final timestamp = map['createdAt'];

if (timestamp is Timestamp) {
createdDate = timestamp.toDate();
} else if (timestamp is DateTime) {
createdDate = timestamp;
}

// ==========================================================
// Total Amount
// ==========================================================

double total = _toDouble(
map['totalAmount'],
);

// إذا الـ Order قديم وما عنده totalAmount،
// بنحسبه من المنتجات.

if (total == 0 && orderItems.isNotEmpty) {
for (final item in orderItems) {
total +=
item.productPrice * item.quantity;
}
}

return OrderModel(
id: id,

userId:
map['userId']?.toString() ?? '',

userName:
map['userName']?.toString() ?? '',

userPhone:
map['userPhone']?.toString() ?? '',

address:
map['address']?.toString() ?? '',

items: orderItems,

totalAmount: total,

status:
map['status']?.toString() ?? 'Pending',

createdAt: createdDate,
);
}

// ============================================================
// Compatibility Getters
// ============================================================
//
// هدول موجودين حتى أي شاشة قديمة بتستخدم:
//
// order.productName
// order.productImage
// order.productPrice
//
// ما تعطي Errors.
//
// إذا الطلب فيه أكثر من منتج، هدول بيرجعوا بيانات
// أول Product فقط.
//
// الشاشة الجديدة رح تعرض كل الـ items.
// ============================================================

String get productName {
if (items.isEmpty) {
return '';
}

return items.first.productName;
}

String get productImage {
if (items.isEmpty) {
return '';
}

return items.first.productImage;
}

double get productPrice {
if (items.isEmpty) {
return 0.0;
}

return items.first.productPrice;
}

// ============================================================
// Total Items Quantity
// ============================================================

int get totalQuantity {
int total = 0;

for (final item in items) {
total += item.quantity;
}

return total;
}

// ============================================================
// Convert To Double
// ============================================================

static double _toDouble(dynamic value) {
if (value is num) {
return value.toDouble();
}

return double.tryParse(
value?.toString() ?? '',
) ??
0.0;
}

// ============================================================
// Convert To Int
// ============================================================

static int _toInt(dynamic value) {
if (value is num) {
return value.toInt();
}

return int.tryParse(
value?.toString() ?? '',
) ??
0;
}
}

