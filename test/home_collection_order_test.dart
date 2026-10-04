import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/home/data/home_collection_order.dart';
import 'package:reborn_packaging/features/home/models/collection_item.dart';

void main() {
  test('uses website order and keeps unmatched collections at the end', () {
    const collections = <CollectionItem>[
      CollectionItem(title: 'Napkins', handle: 'napkins'),
      CollectionItem(
        title: 'Hinged Lid Sauce Pots',
        handle: 'hinged-lid-sauce-pots',
      ),
      CollectionItem(title: 'Blue Roll', handle: 'blue-roll'),
      CollectionItem(
        title: 'Future Collection',
        handle: 'future-collection',
      ),
      CollectionItem(
        title: 'White Round Bowls',
        handle: 'white-round-bowls',
      ),
      CollectionItem(
        title: 'Kraft Round Bowls',
        handle: 'kraft-round-bowls',
      ),
      CollectionItem(title: 'Round Bowl Lids', handle: 'round-bowl-lids'),
      CollectionItem(
        title: 'Kraft Rectangular Bowls',
        handle: 'kraft-rectangular-bowls',
      ),
    ];

    final ordered = orderHomeCollections(collections);

    expect(
      ordered.map((collection) => collection.handle),
      <String>[
        'kraft-round-bowls',
        'white-round-bowls',
        'round-bowl-lids',
        'kraft-rectangular-bowls',
        'napkins',
        'blue-roll',
        'hinged-lid-sauce-pots',
        'future-collection',
      ],
    );
  });
}
