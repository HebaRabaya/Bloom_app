import 'package:bloom_app/services/gift_message_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('writes a birthday message that includes the recipient name', () {
    final writer = GiftMessageService();

    final message = writer.write(
      occasion: 'Birthday',
      tone: 'Warm',
      recipientName: 'Sara',
    );

    expect(message, contains('Sara'));
    expect(message.toLowerCase(), contains('birthday'));
  });

  test('regenerate returns a different variant', () {
    final writer = GiftMessageService();

    final first = writer.write(occasion: 'Graduation', tone: 'Elegant');
    final second = writer.write(occasion: 'Graduation', tone: 'Elegant');

    expect(first, isNot(second));
  });

  test('works without a recipient name', () {
    final writer = GiftMessageService();

    final message = writer.write(
      occasion: 'Thank You',
      tone: 'Warm',
    );

    expect(message, isNotEmpty);
    expect(message, isNot(contains('null')));
  });
}
