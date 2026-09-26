import 'package:bloom_app/models/cart_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_backend.dart';

void main() {
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend();
  });

  test('addToCart stores one unit of an in-stock product', () async {
    await backend.seedProduct(id: 'p1', quantity: 3);

    await backend.cart.addToCart(productId: 'p1');

    final item = await backend.cartItem('p1');
    expect(item?['productId'], 'p1');
    expect(item?['productName'], 'Rose Bouquet');
    expect(item?['productPrice'], 40);
    expect(item?['quantity'], 1);
    expect(item?['availableQuantity'], 3);
  });

  test('addToCart increments quantity on a second add', () async {
    await backend.seedProduct(id: 'p1', quantity: 3);

    await backend.cart.addToCart(productId: 'p1');
    await backend.cart.addToCart(productId: 'p1');

    expect((await backend.cartItem('p1'))?['quantity'], 2);
  });

  test('addToCart rejects a missing product', () async {
    expect(
      () => backend.cart.addToCart(productId: 'missing'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Product not found.'),
        ),
      ),
    );
  });

  test('addToCart rejects an out-of-stock product', () async {
    await backend.seedProduct(id: 'p1', quantity: 0);

    expect(
      () => backend.cart.addToCart(productId: 'p1'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Out of stock.'),
        ),
      ),
    );
  });

  test('addToCart refuses to exceed available stock', () async {
    await backend.seedProduct(id: 'p1', quantity: 1);
    await backend.seedCartItem(productId: 'p1', quantity: 1, availableQuantity: 1);

    expect(
      () => backend.cart.addToCart(productId: 'p1'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('Maximum available quantity reached.'),
        ),
      ),
    );
  });

  test('increaseQuantity adds one unit when stock allows it', () async {
    await backend.seedProduct(id: 'p1', quantity: 4);
    await backend.seedCartItem(productId: 'p1', quantity: 1, availableQuantity: 4);

    await backend.cart.increaseQuantity(
      CartModel(
        productId: 'p1',
        productName: 'Rose Bouquet',
        productPrice: 40,
        productImage: '',
        quantity: 1,
        availableQuantity: 4,
      ),
    );

    expect((await backend.cartItem('p1'))?['quantity'], 2);
  });

  test('decreaseQuantity removes the line when quantity is 1', () async {
    await backend.seedCartItem(productId: 'p1', quantity: 1);

    await backend.cart.decreaseQuantity(
      CartModel(
        productId: 'p1',
        productName: 'Rose Bouquet',
        productPrice: 40,
        productImage: '',
        quantity: 1,
        availableQuantity: 5,
      ),
    );

    expect(await backend.cartItem('p1'), isNull);
  });

  test('removeFromCart deletes the cart line', () async {
    await backend.seedCartItem(productId: 'p1');

    await backend.cart.removeFromCart('p1');

    expect(await backend.cartCount(), 0);
  });

  test('cart actions fail when nobody is signed in', () {
    final guest = FakeBackend(signedIn: false);

    expect(
      () => guest.cart.addToCart(productId: 'p1'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'message',
          contains('User is not logged in.'),
        ),
      ),
    );
  });
}
