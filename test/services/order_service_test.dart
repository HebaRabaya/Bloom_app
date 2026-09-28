import 'package:bloom_app/models/order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_backend.dart';

void main() {
  late FakeBackend backend;

  setUp(() async {
    backend = FakeBackend();
    await backend.seedUser();
  });

  test('checkout rejects an empty address', () async {
    await backend.seedProduct(id: 'p1');
    await backend.seedCartItem(productId: 'p1');

    expect(
      () => backend.orders.checkout(address: '   '),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Please enter your delivery address.'),
        ),
      ),
    );
  });

  test('checkout rejects an empty cart', () async {
    expect(
      () => backend.orders.checkout(address: 'Ramallah'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Your cart is empty.'),
        ),
      ),
    );
  });

  test('checkout creates a pending order, reduces stock, and clears the cart', () async {
    await backend.seedProduct(id: 'p1', quantity: 5, price: 40);
    await backend.seedCartItem(productId: 'p1', quantity: 2, productPrice: 40);

    final orderId = await backend.orders.checkout(address: ' Ramallah ');
    final order = await backend.order(orderId);
    final product = await backend.product('p1');

    expect(orderId, isNotEmpty);
    expect(order?['userId'], FakeBackend.uid);
    expect(order?['userName'], 'Bloom User');
    expect(order?['userPhone'], '0590000000');
    expect(order?['address'], 'Ramallah');
    expect(order?['status'], 'Pending');
    expect(order?['totalAmount'], 80);
    expect(order?['items'], hasLength(1));
    expect(product?['quantity'], 3);
    expect(await backend.cartCount(), 0);
  });

  test('checkout stores gift delivery details on the order', () async {
    await backend.seedProduct(id: 'p1', quantity: 5, price: 40);
    await backend.seedCartItem(productId: 'p1', quantity: 1, productPrice: 40);

    final orderId = await backend.orders.checkout(
      address: 'Al Manara',
      recipientName: 'Sara',
      recipientPhone: '0591111111',
      city: 'Ramallah',
      deliveryDate: '2026-09-30',
      deliveryNotes: 'Leave with the doorman',
      giftMessage: 'Happy birthday, Sara.',
      occasion: 'Birthday',
    );
    final order = await backend.order(orderId);

    expect(order?['recipientName'], 'Sara');
    expect(order?['recipientPhone'], '0591111111');
    expect(order?['city'], 'Ramallah');
    expect(order?['deliveryDate'], '2026-09-30');
    expect(order?['deliveryNotes'], 'Leave with the doorman');
    expect(order?['giftMessage'], 'Happy birthday, Sara.');
    expect(order?['occasion'], 'Birthday');
  });

  test('checkout refuses when stock is lower than the cart quantity', () async {
    await backend.seedProduct(id: 'p1', quantity: 1);
    await backend.seedCartItem(productId: 'p1', quantity: 2);

    expect(
      () => backend.orders.checkout(address: 'Ramallah'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Not enough stock for Rose Bouquet. Available: 1'),
        ),
      ),
    );
  });

  test('cancelOrder restocks the product and deletes the order', () async {
    await backend.seedProduct(id: 'p1', quantity: 3);
    final order = await _seedOrder(backend, quantity: 2);

    await backend.orders.cancelOrder(order: order);

    expect(await backend.order(order.id), isNull);
    expect((await backend.product('p1'))?['quantity'], 5);
  });

  test('cancelOrder refuses an order that belongs to someone else', () async {
    await backend.seedProduct(id: 'p1', quantity: 3);
    final order = await _seedOrder(backend, userId: 'other-user');

    expect(
      () => backend.orders.cancelOrder(order: order),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('You cannot cancel this order.'),
        ),
      ),
    );

    expect(await backend.order(order.id), isNotNull);
    expect((await backend.product('p1'))?['quantity'], 3);
  });

  test('cancelOrderByAdmin restocks even when the signed-in user is not the owner', () async {
    await backend.seedProduct(id: 'p1', quantity: 1);
    final order = await _seedOrder(backend, userId: 'other-user', quantity: 4);

    await backend.orders.cancelOrderByAdmin(order: order);

    expect(await backend.order(order.id), isNull);
    expect((await backend.product('p1'))?['quantity'], 5);
  });
}

Future<OrderModel> _seedOrder(
  FakeBackend backend, {
  String userId = FakeBackend.uid,
  int quantity = 1,
}) async {
  final reference = backend.firestore.collection('orders').doc();

  await reference.set({
    'userId': userId,
    'userName': 'Bloom User',
    'userPhone': '0590000000',
    'address': 'Ramallah',
    'items': [
      {
        'productId': 'p1',
        'productName': 'Rose Bouquet',
        'productImage': 'https://example.com/rose.png',
        'productPrice': 40,
        'quantity': quantity,
      },
    ],
    'totalAmount': 40.0 * quantity,
    'status': 'Pending',
    'createdAt': Timestamp.now(),
  });

  final snapshot = await reference.get();
  return OrderModel.fromMap(snapshot.id, snapshot.data()!);
}
