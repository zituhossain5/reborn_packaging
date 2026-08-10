import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/products/data/mock_product_details.dart';
import 'package:reborn_packaging/features/products/models/product_details.dart';
import 'package:reborn_packaging/features/products/state/product_selection_controller.dart';

void main() {
  group('ProductSelectionController', () {
    test('starts with the selected variant and base totals', () {
      final controller = ProductSelectionController(mockKraftRoundBowlsProduct);

      expect(controller.selectedVariant.size, '500ml');
      expect(controller.selectedVariant.lid, 'Without Lid');
      expect(controller.selectedVariant.price, 54.95);
      expect(controller.selectedVariant.piecesPerPack, 600);
      expect(controller.includeVat, isFalse);
      expect(controller.unitPrice, closeTo(54.95 / 600, 0.000001));
      expect(controller.displayedVariantPrice, 54.95);
      expect(controller.displayedUnitPrice, closeTo(54.95 / 600, 0.000001));
      expect(controller.quantity, 1);
      expect(controller.totalUnits, 600);
      expect(controller.totalPrice, 54.95);
    });

    test('applies VAT only to displayed prices and totals', () {
      final controller = ProductSelectionController(mockKraftRoundBowlsProduct);

      controller.toggleIncludeVat();

      expect(controller.includeVat, isTrue);
      expect(controller.selectedVariant.priceExVat, 54.95);
      expect(controller.displayedVariantPrice, closeTo(65.94, 0.000001));
      expect(controller.displayedUnitPrice, closeTo(65.94 / 600, 0.000001));
      expect(controller.totalPrice, closeTo(65.94, 0.000001));

      controller.increaseQuantity();

      expect(controller.quantity, 2);
      expect(controller.totalUnits, 1200);
      expect(controller.totalPrice, closeTo(131.88, 0.000001));
    });

    test('resolves size and lid combinations with dynamic values', () {
      final controller = ProductSelectionController(mockKraftRoundBowlsProduct);

      expect(controller.isLidAvailable('With PET Lid'), isFalse);

      controller.selectLid('With PP Lid');
      expect(controller.selectedVariant.price, 59.95);

      controller.selectSize('650ml');
      expect(controller.selectedVariant.lid, 'With PP Lid');
      expect(controller.selectedVariant.price, 65.95);
      expect(controller.selectedVariant.piecesPerPack, 500);

      controller.selectLid('With PET Lid');
      expect(controller.selectedVariant.price, 63.95);

      controller.selectSize('500ml');
      expect(controller.selectedVariant.lid, 'Without Lid');
      expect(controller.selectedVariant.price, 54.95);
      expect(controller.isLidAvailable('With PET Lid'), isFalse);
    });

    test('calculates quantity, units, and total price', () {
      final controller = ProductSelectionController(mockKraftRoundBowlsProduct);

      controller.increaseQuantity();
      expect(controller.quantity, 2);
      expect(controller.totalUnits, 1200);
      expect(controller.totalPrice, closeTo(109.90, 0.000001));

      controller.decreaseQuantity();
      controller.decreaseQuantity();
      expect(controller.quantity, 1);
      expect(controller.canDecrease, isFalse);
      expect(controller.totalPrice, 54.95);
    });

    test('resolves generic options and enforces variant quantity rules', () {
      final controller = ProductSelectionController(_shopifyStyleProduct);

      expect(controller.quantity, 2);
      expect(controller.canDecrease, isFalse);
      expect(controller.isOptionValueAvailable('Size', '750ml'), isTrue);
      expect(controller.isOptionValueAvailable('Lid', 'PET Lid'), isFalse);

      controller.selectOption('Size', '750ml');
      expect(controller.selectedVariant.id, 'variant-750-no-lid');
      expect(controller.displayedVariantPrice, 44.95);
      expect(controller.quantity, 5);

      controller.increaseQuantity();
      expect(controller.quantity, 10);
      expect(controller.canIncrease, isFalse);
      controller.increaseQuantity();
      expect(controller.quantity, 10);
    });
  });
}

const _shopifyStyleProduct = ProductDetails(
  id: 'product-real-options',
  handle: 'real-options',
  title: 'Real Options Product',
  images: [],
  currency: 'GBP',
  selectedVariantId: 'variant-500-no-lid',
  variants: [
    ProductVariant(
      id: 'variant-500-no-lid',
      size: '500ml',
      lid: 'Without Lid',
      price: 41.95,
      availableForSale: true,
      selectedOptions: [
        ProductSelectedOption(name: 'Size', value: '500ml'),
        ProductSelectedOption(name: 'Lid', value: 'Without Lid'),
      ],
      quantityRule: ProductQuantityRule(minimum: 2, maximum: 6, increment: 2),
    ),
    ProductVariant(
      id: 'variant-500-pet-lid',
      size: '500ml',
      lid: 'PET Lid',
      price: 60,
      availableForSale: false,
      selectedOptions: [
        ProductSelectedOption(name: 'Size', value: '500ml'),
        ProductSelectedOption(name: 'Lid', value: 'PET Lid'),
      ],
    ),
    ProductVariant(
      id: 'variant-750-no-lid',
      size: '750ml',
      lid: 'Without Lid',
      price: 44.95,
      availableForSale: true,
      selectedOptions: [
        ProductSelectedOption(name: 'Size', value: '750ml'),
        ProductSelectedOption(name: 'Lid', value: 'Without Lid'),
      ],
      quantityRule: ProductQuantityRule(minimum: 5, maximum: 10, increment: 5),
    ),
  ],
  sizes: ['500ml', '750ml'],
  lidOptions: ['Without Lid', 'PET Lid'],
  quantityRule: ProductQuantityRule(minimum: 2, increment: 2),
  description: [],
  features: [],
  specifications: [],
  options: [
    ProductOption(id: 'size', name: 'Size', values: ['500ml', '750ml']),
    ProductOption(id: 'lid', name: 'Lid', values: ['Without Lid', 'PET Lid']),
  ],
);
