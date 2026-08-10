import '../models/product_details.dart';
import '../models/product_item.dart';
import 'mock_products.dart';

const _sizes = ['500ml', '650ml', '750ml', '1000ml'];
const _lidOptions = ['Without Lid', 'With PET Lid', 'With PP Lid'];

final mockKraftRoundBowlsProduct = ProductDetails(
  id: 'product-kraft-round-bowls',
  handle: 'kraft-round-bowls',
  title: 'Kraft Round Bowls',
  images: const [
    'assets/images/products/kraft_round_bowl_detail.png',
    'assets/images/products/kraft_round_bowl_detail.png',
    'assets/images/products/kraft_round_bowl_detail.png',
    'assets/images/products/kraft_round_bowl_detail.png',
  ],
  currency: 'GBP',
  selectedVariantId: '500ml-without-lid',
  variants: [
    _MockVariantData.variant(
      size: '500ml',
      lid: 'Without Lid',
      price: 54.95,
      piecesPerPack: 600,
      quantityAvailable: 40,
    ),
    _MockVariantData.variant(
      size: '500ml',
      lid: 'With PET Lid',
      price: 57.95,
      piecesPerPack: 600,
      quantityAvailable: 0,
      availableForSale: false,
    ),
    _MockVariantData.variant(
      size: '500ml',
      lid: 'With PP Lid',
      price: 59.95,
      piecesPerPack: 600,
      quantityAvailable: 22,
    ),
    _MockVariantData.variant(
      size: '650ml',
      lid: 'Without Lid',
      price: 58.95,
      piecesPerPack: 500,
      quantityAvailable: 35,
    ),
    _MockVariantData.variant(
      size: '650ml',
      lid: 'With PET Lid',
      price: 63.95,
      piecesPerPack: 500,
      quantityAvailable: 18,
    ),
    _MockVariantData.variant(
      size: '650ml',
      lid: 'With PP Lid',
      price: 65.95,
      piecesPerPack: 500,
      quantityAvailable: 14,
    ),
    _MockVariantData.variant(
      size: '750ml',
      lid: 'Without Lid',
      price: 62.95,
      piecesPerPack: 400,
      quantityAvailable: 28,
    ),
    _MockVariantData.variant(
      size: '750ml',
      lid: 'With PET Lid',
      price: 67.95,
      piecesPerPack: 400,
      quantityAvailable: 12,
    ),
    _MockVariantData.variant(
      size: '750ml',
      lid: 'With PP Lid',
      price: 69.95,
      piecesPerPack: 400,
      quantityAvailable: 10,
    ),
    _MockVariantData.variant(
      size: '1000ml',
      lid: 'Without Lid',
      price: 68.95,
      piecesPerPack: 300,
      quantityAvailable: 20,
    ),
    _MockVariantData.variant(
      size: '1000ml',
      lid: 'With PET Lid',
      price: 73.95,
      piecesPerPack: 300,
      quantityAvailable: 8,
    ),
    _MockVariantData.variant(
      size: '1000ml',
      lid: 'With PP Lid',
      price: 75.95,
      piecesPerPack: 300,
      quantityAvailable: 7,
    ),
  ],
  sizes: _sizes,
  lidOptions: _lidOptions,
  quantityRule: const ProductQuantityRule(minimum: 1, increment: 1),
  description: const [
    ProductDescriptionParagraph(
      segments: [
        ProductDescriptionSegment('Introducing our '),
        ProductDescriptionSegment(
          '750ml Rectangular Kraft Paper Container (25oz),',
          emphasized: true,
        ),
        ProductDescriptionSegment(
          ' the durable, eco-friendly and versatile packaging solution for modern food service.',
        ),
      ],
    ),
    ProductDescriptionParagraph(
      segments: [
        ProductDescriptionSegment('Crafted from strong '),
        ProductDescriptionSegment(
          'recyclable kraft paperboard',
          emphasized: true,
        ),
        ProductDescriptionSegment(
          ' with a food-grade, grease-resistant lining, these containers are designed to handle both hot and cold dishes without leaking, warping or losing their shape.',
        ),
      ],
    ),
    ProductDescriptionParagraph(
      segments: [
        ProductDescriptionSegment('With a '),
        ProductDescriptionSegment('750ml capacity,', emphasized: true),
        ProductDescriptionSegment(
          ' this container is ideal for larger portions such as pasta, salads, noodle dishes, curries, rice bowls, stir-fries, burrito bowls, desserts and meal-prep servings. Its rectangular design maximises space efficiency in kitchen prep areas and delivery bags, while offering a clean, modern presentation for dine-in or takeaway customers.',
        ),
      ],
    ),
    ProductDescriptionParagraph(
      segments: [
        ProductDescriptionSegment(
          'Lightweight, sturdy and easy to stack, these kraft containers are perfect for restaurants, caf\u00E9s, food trucks, street food vendors, catering companies and meal-prep businesses. Pair with the matching lid (sold separately) for a fully secure, spill-resistant takeaway packaging solution. The natural kraft finish enhances eco-friendly branding and promotes a premium, sustainable image.',
        ),
      ],
    ),
  ],
  features: const [
    ProductFeature(
      title: 'Secure Snap-Fit Lid Options:',
      description:
          'Help prevent leaks, spills and food movement during transport, giving customers a better takeaway and delivery experience',
    ),
    ProductFeature(
      title: 'Suitable for Hot & Cold Foods:',
      description:
          'Ideal for salads, poke bowls, rice dishes, noodles, curries, chicken meals, desserts and meal prep',
    ),
    ProductFeature(
      title: 'Strong 300gsm Kraft Construction:',
      description:
          'Provides excellent stability and durability to help maintain food presentation from kitchen to customer',
    ),
    ProductFeature(
      title: 'Multiple Sizes & Lid Choices:',
      description:
          'Available in a range of capacities and diameters with optional PET or PP lids to suit different menu items and portion sizes.',
    ),
    ProductFeature(
      title: 'Eco-Friendly & Recyclable:',
      description:
          'A paper-based alternative to traditional plastic food containers that can be recycled where facilities exist and disposed of correctly.',
    ),
  ],
  specifications: const [
    ProductSpecification(
      label: 'Product Name',
      value: '750ml Rectangular Kraft Paper Container (25oz)',
    ),
    ProductSpecification(
      label: 'Material',
      value: 'Recyclable Kraft Paperboard',
    ),
    ProductSpecification(label: 'Capacity', value: '750ml / 25oz'),
    ProductSpecification(label: 'Colour', value: 'Natural Brown Kraft'),
    ProductSpecification(
      label: 'Lining',
      value: 'Food-Grade Grease-Resistant Coating',
    ),
    ProductSpecification(
      label: 'Dimensions',
      value: '170mm (L) x 120mm (W) x 60mm (H)',
    ),
    ProductSpecification(
      label: 'Suitable For',
      value:
          'Hot & Cold Foods \u2013 Pasta, Salads, Curries, Rice Bowls, Noodles, Meal Prep & More',
    ),
    ProductSpecification(
      label: 'Temperature Range',
      value: 'Suitable for hot and cold food service',
    ),
    ProductSpecification(label: 'Packaging', value: '600 Containers per Case'),
  ],
);

final mockProductDetailsByHandle = <String, ProductDetails>{
  mockKraftRoundBowlsProduct.handle: mockKraftRoundBowlsProduct,
  for (final product in mockProductCatalog)
    if (product.handle != mockKraftRoundBowlsProduct.handle)
      product.handle: _simpleProductDetails(product),
};

ProductDetails? mockProductDetailsForHandle(String handle) {
  return mockProductDetailsByHandle[handle];
}

ProductDetails _simpleProductDetails(ProductItem product) {
  final variants = [
    for (final size in product.variantSizes)
      ProductVariant(
        id: '${product.handle}-${_slug(size)}-standard',
        size: size,
        lid: 'Standard',
        price: product.price,
        availableForSale: true,
        piecesPerPack: product.quantity!,
        quantityAvailable: 100,
        imageAsset: product.imageAsset,
      ),
  ];

  return ProductDetails(
    id: product.id,
    handle: product.handle,
    title: product.title,
    images: [product.imageAsset!],
    currency: 'GBP',
    selectedVariantId: variants.first.id,
    variants: variants,
    sizes: product.variantSizes,
    lidOptions: const ['Standard'],
    quantityRule: const ProductQuantityRule(minimum: 1, increment: 1),
    description: [
      ProductDescriptionParagraph(
        segments: [
          ProductDescriptionSegment(
            '${product.title} for reliable food-service and takeaway packaging.',
          ),
        ],
      ),
    ],
    features: const [
      ProductFeature(
        title: 'Food-Service Ready:',
        description:
            'Designed for dependable everyday use in takeaway, catering and hospitality businesses.',
      ),
    ],
    specifications: [
      ProductSpecification(label: 'Product Name', value: product.title),
      ProductSpecification(
        label: 'Packaging',
        value: '${product.quantity} units per case',
      ),
    ],
  );
}

String _slug(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
}

abstract final class _MockVariantData {
  static ProductVariant variant({
    required String size,
    required String lid,
    required double price,
    required int piecesPerPack,
    required int quantityAvailable,
    bool availableForSale = true,
  }) {
    return ProductVariant(
      id: '${size.toLowerCase()}-${lid.toLowerCase().replaceAll(' ', '-')}',
      size: size,
      lid: lid,
      price: price,
      availableForSale: availableForSale,
      piecesPerPack: piecesPerPack,
      quantityAvailable: quantityAvailable,
      imageAsset: 'assets/images/products/cart_kraft_round_bowl.png',
    );
  }
}
