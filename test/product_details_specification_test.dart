import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/products/models/product_details.dart';

void main() {
  group('ProductDetails.specificationsForVariant', () {
    test('prepends the selected variant SKU to parsed specifications', () {
      final specifications = _product.specificationsForVariant(
        _variant(sku: 'RB005-HCS'),
      );

      expect(specifications.first.label, 'SKU');
      expect(specifications.first.value, 'RB005-HCS');
      expect(specifications[1].label, 'Material');
      expect(specifications[1].value, 'Bagasse');
    });

    test('uses the selected variant SKU and removes parsed SKU duplicates', () {
      final product = _productWithParsedSku;

      final firstSpecifications = product.specificationsForVariant(
        _variant(id: 'variant-a', sku: 'RB005-A'),
      );
      final secondSpecifications = product.specificationsForVariant(
        _variant(id: 'variant-b', sku: 'RB005-B'),
      );

      expect(firstSpecifications.first.value, 'RB005-A');
      expect(secondSpecifications.first.value, 'RB005-B');
      expect(
        firstSpecifications.where(
          (specification) => specification.label == 'SKU',
        ),
        hasLength(1),
      );
    });

    test('hides SKU when the selected variant SKU is missing', () {
      final specifications = _productWithParsedSku.specificationsForVariant(
        _variant(sku: '   '),
      );

      expect(specifications.map((specification) => specification.label), [
        'Material',
      ]);
    });
  });
}

const _product = ProductDetails(
  id: 'product-id',
  handle: 'product-handle',
  title: 'Product',
  images: [],
  currency: 'GBP',
  selectedVariantId: 'variant-id',
  variants: [_baseVariant],
  sizes: [],
  lidOptions: [],
  quantityRule: ProductQuantityRule(minimum: 1, increment: 1),
  description: [],
  features: [],
  specifications: [ProductSpecification(label: 'Material', value: 'Bagasse')],
);

const _productWithParsedSku = ProductDetails(
  id: 'product-id',
  handle: 'product-handle',
  title: 'Product',
  images: [],
  currency: 'GBP',
  selectedVariantId: 'variant-id',
  variants: [_baseVariant],
  sizes: [],
  lidOptions: [],
  quantityRule: ProductQuantityRule(minimum: 1, increment: 1),
  description: [],
  features: [],
  specifications: [
    ProductSpecification(label: 'SKU', value: 'Parsed-SKU'),
    ProductSpecification(label: 'Material', value: 'Bagasse'),
  ],
);

const _baseVariant = ProductVariant(
  id: 'variant-id',
  size: '',
  lid: '',
  price: 10,
  availableForSale: true,
  sku: 'RB005-HCS',
);

ProductVariant _variant({String id = 'variant-id', String? sku}) {
  return ProductVariant(
    id: id,
    size: '',
    lid: '',
    price: 10,
    availableForSale: true,
    sku: sku,
  );
}
