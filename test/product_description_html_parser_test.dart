import 'package:flutter_test/flutter_test.dart';
import 'package:reborn_packaging/features/products/data/product_description_html_parser.dart';
import 'package:reborn_packaging/features/products/models/product_details.dart';

void main() {
  const parser = ProductDescriptionHtmlParser();

  test('converts a Shopify specification table into label and value rows', () {
    final content = parser.parse('''
      <h3>Product Specification</h3>
      <table>
        <tr><td><b><br>Detail</b></td><td><b>Specification</b></td></tr>
        <tr><td><b>Product Name</b></td><td>1oz Portion Pot</td></tr>
        <tr><td><b>Material</b></td><td>Kraft Paper + Food-Grade PE Lining</td></tr>
      </table>
    ''');

    expect(content.description, isEmpty);
    expect(content.features, isEmpty);
    expect(content.specifications, hasLength(2));
    expect(content.specifications.first.label, 'Product Name');
    expect(content.specifications.first.value, '1oz Portion Pot');
    expect(content.specifications.last.label, 'Material');
  });

  test('preserves rich paragraphs, features, lists and specifications', () {
    final content = parser.parse('''
      <h3><b>Product Description</b></h3>
      <p>Suitable for <strong>hot and cold food</strong>.<br>Easy to stack.</p>
      <p><b>Key Features:</b></p>
      <p style="mso-list: l0 level1 lfo1">● Secure during transport</p>
      <ul><li><strong>Recyclable:</strong> dispose of correctly.</li></ul>
      <h3>Product Specification</h3>
      <table>
        <tr><th>Specification</th><th>Detail</th></tr>
        <tr><td>Capacity</td><td>750ml</td></tr>
      </table>
    ''');

    expect(content.description, hasLength(1));
    expect(
      content.description.single.segments.any(
        (segment) =>
            segment.emphasized && segment.text.contains('hot and cold food'),
      ),
      isTrue,
    );
    expect(
      content.description.single.segments.map((segment) => segment.text).join(),
      contains('\n'),
    );
    expect(content.features, hasLength(2));
    expect(content.features.first.title, 'Secure during transport');
    expect(content.features.last.title, 'Recyclable');
    expect(content.features.last.description, 'dispose of correctly.');
    expect(content.specifications.single.label, 'Capacity');
    expect(content.specifications.single.value, '750ml');
  });

  test('keeps standard list items structured in a generic description', () {
    final content = parser.parse(
      '<p>Intro paragraph.</p><ol><li>First use</li><li>Second use</li></ol>',
    );

    expect(content.description, hasLength(3));
    expect(content.description[1].type, ProductDescriptionBlockType.listItem);
    expect(content.description[2].type, ProductDescriptionBlockType.listItem);
  });
}
