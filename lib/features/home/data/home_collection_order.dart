import '../models/collection_item.dart';

/// Business-defined order used by the website's homepage collection grid.
const websiteHomeCollectionHandles = <String>[
  'kraft-round-bowls',
  'white-round-bowls',
  'round-bowl-lids',
  'kraft-rectangular-bowls',
  'rectangular-bowl-lids',
  'kraft-square-bowls',
  'square-bowl-lids',
  'napkins',
  'kraft-soup-containers',
  'soup-container-lids',
  'paper-carrier-bags',
  'kraft-portion-pots',
  'portion-pot-lids',
  'kraft-boat-trays',
  'paper-souffle-pots',
  'kraft-deli-boxes',
  'paper-coffee-cups',
  'coffee-cup-lids',
  'bagasse-clamshell-boxes',
  'plastic-smoothie-cups',
  'paper-straws',
  'bagasse-buddha-bowls',
  'paper-snack-bags',
  'greaseproof-sheets',
  'wooden-cutlery-utensils',
  'blue-roll',
  'cup-holders',
];

List<CollectionItem> orderHomeCollections(List<CollectionItem> collections) {
  final configuredPositions = <String, int>{
    for (var index = 0; index < websiteHomeCollectionHandles.length; index++)
      websiteHomeCollectionHandles[index]: index,
  };
  final indexedCollections = collections.indexed.toList();

  indexedCollections.sort((left, right) {
    final leftPosition = configuredPositions[left.$2.handle];
    final rightPosition = configuredPositions[right.$2.handle];

    if (leftPosition != null && rightPosition != null) {
      return leftPosition.compareTo(rightPosition);
    }
    if (leftPosition != null) return -1;
    if (rightPosition != null) return 1;

    return left.$1.compareTo(right.$1);
  });

  return List.unmodifiable(indexedCollections.map((entry) => entry.$2));
}
