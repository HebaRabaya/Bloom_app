class GiftMessageService {
  GiftMessageService();

  static const occasions = <String>[
    'Birthday',
    'Graduation',
    'Anniversary',
    'Just Because',
    'Thank You',
  ];

  static const tones = <String>['Warm', 'Elegant', 'Playful'];

  int _index = 0;

  String write({
    required String occasion,
    required String tone,
    String recipientName = '',
  }) {
    final name = recipientName.trim();
    final variants = _variants(
      occasion: occasion,
      tone: tone,
      named: name.isEmpty ? '' : name,
    );
    final message = variants[_index % variants.length];
    _index += 1;
    return message;
  }

  List<String> _variants({
    required String occasion,
    required String tone,
    required String named,
  }) {
    final who = named.isEmpty ? '' : ', $named';

    switch (_key(occasion)) {
      case 'graduation':
        return _byTone(tone, [
          'Congratulations on your achievement$who. Wishing you a beautiful new beginning.',
          'You did it$who. May the next chapter be as bright as this bouquet.',
          'Proud of you$who. Here is to the future you have already earned.',
        ], [
          'With admiration$who. May this milestone open every door you hope for.',
          'A quiet celebration of your success$who, and all that follows.',
          'Elegance for an elegant achievement. Congratulations$who.',
        ], [
          'Caps off$who. The world better be ready for you.',
          'You graduated. Flowers are the least we could do$who.',
          'Class dismissed, legend$who. Go bloom.',
        ]);
      case 'anniversary':
        return _byTone(tone, [
          'Happy anniversary$who. Still choosing you, still meaning it.',
          'Another year of us$who. These flowers are only a small thank-you.',
          'To more slow mornings and more reasons to celebrate$who.',
        ], [
          'For the love that keeps unfolding$who. Happy anniversary.',
          'A year more beautiful with you$who. With all my heart.',
          'In bloom, as we are$who. Happy anniversary.',
        ], [
          'Still stuck on you$who. Happy anniversary.',
          'Another lap around the sun together$who. Let us keep going.',
          'Same love, fresher flowers$who.',
        ]);
      case 'thank you':
        return _byTone(tone, [
          'Thank you$who. This is a small way of saying it properly.',
          'Grateful for you$who, more than these petals can hold.',
          'You made a difference$who. Thank you, truly.',
        ], [
          'With sincere thanks$who, and a little beauty for your table.',
          'A quiet thank-you$who, offered in bloom.',
          'For your kindness$who. With gratitude.',
        ], [
          'You are the best$who. Flowers felt like the right volume of thanks.',
          'Consider this a very pretty thank-you note$who.',
          'Thanks a bunch$who. Literally.',
        ]);
      case 'just because':
        return _byTone(tone, [
          'No big occasion. Just you$who, and a reason to smile.',
          named.isEmpty
              ? 'Because you deserved flowers today.'
              : 'Because $named deserved flowers today.',
          'A little brightness for your day$who, from me.',
        ], [
          'Simply because you make ordinary days feel softer$who.',
          'No occasion required$who. Only you.',
          'For the quiet joy of thinking of you$who.',
        ], [
          'Surprise$who. These are for absolutely no reason.',
          'Plot twist: flowers, just because$who.',
          'Caught you being wonderful$who. That is the whole message.',
        ]);
      case 'birthday':
      default:
        return _byTone(tone, [
          'Happy birthday$who. Wishing you a day as lovely as these flowers.',
          'Another year of you$who, and the world is luckier for it. Happy birthday.',
          'May this year be gentle, bright, and full of people who love you$who.',
        ], [
          'With love on your birthday$who. May every petal remind you how cherished you are.',
          'A blooming birthday$who, and a year that unfolds beautifully.',
          'Celebrating you$who, quietly and completely. Happy birthday.',
        ], [
          'Make a wish$who. Then blow out the candles and keep the flowers.',
          'Happy birthday$who. Age is just a number. This bouquet is a whole mood.',
          'It is your day$who. Flowers first, cake second, glory all day.',
        ]);
    }
  }

  List<String> _byTone(
    String tone,
    List<String> warm,
    List<String> elegant,
    List<String> playful,
  ) {
    switch (_key(tone)) {
      case 'elegant':
        return elegant;
      case 'playful':
        return playful;
      default:
        return warm;
    }
  }

  String _key(String value) => value.trim().toLowerCase();
}
