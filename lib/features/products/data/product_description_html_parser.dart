import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../models/product_details.dart';

class ParsedProductContent {
  const ParsedProductContent({
    required this.description,
    required this.features,
    required this.specifications,
  });

  final List<ProductDescriptionParagraph> description;
  final List<ProductFeature> features;
  final List<ProductSpecification> specifications;
}

class ProductDescriptionHtmlParser {
  const ProductDescriptionHtmlParser();

  ParsedProductContent parse(String html, {String fallbackText = ''}) {
    final state = _ProductContentParserState();

    if (html.trim().isNotEmpty) {
      final fragment = html_parser.parseFragment(html);
      state.parseNodes(fragment.nodes);
    }

    if (!state.hasContent && fallbackText.trim().isNotEmpty) {
      state.addFallbackText(fallbackText);
    }

    return state.result;
  }
}

enum _ContentSection { description, features, specifications }

class _ProductContentParserState {
  final List<ProductDescriptionParagraph> _description = [];
  final List<ProductFeature> _features = [];
  final List<ProductSpecification> _specifications = [];
  _ContentSection _section = _ContentSection.description;

  bool get hasContent =>
      _description.isNotEmpty ||
      _features.isNotEmpty ||
      _specifications.isNotEmpty;

  ParsedProductContent get result => ParsedProductContent(
    description: List.unmodifiable(_description),
    features: List.unmodifiable(_features),
    specifications: List.unmodifiable(_specifications),
  );

  void parseNodes(Iterable<Node> nodes) {
    for (final node in nodes) {
      if (node is Text) {
        final text = _normalizeText(node.data);
        if (text.isNotEmpty) _addDescriptionText(text);
        continue;
      }
      if (node is! Element) continue;

      final tag = node.localName;
      if (_headingTags.contains(tag)) {
        _parseHeading(node);
      } else if (tag == 'table') {
        _parseTable(node);
      } else if (tag == 'ul' || tag == 'ol') {
        for (final item in node.children.where(
          (child) => child.localName == 'li',
        )) {
          _parseTextBlock(item, isListItem: true);
        }
      } else if (tag == 'li') {
        _parseTextBlock(node, isListItem: true);
      } else if (_paragraphTags.contains(tag)) {
        if (_containsBlockChildren(node)) {
          parseNodes(node.nodes);
        } else {
          _parseTextBlock(node);
        }
      } else if (_containsBlockChildren(node)) {
        parseNodes(node.nodes);
      } else {
        _parseTextBlock(node);
      }
    }
  }

  void addFallbackText(String value) {
    for (final paragraph in value.split(RegExp(r'\n\s*\n'))) {
      final text = _normalizeText(paragraph);
      if (text.isNotEmpty) _addDescriptionText(text);
    }
  }

  void _parseHeading(Element element) {
    final text = _plainText(element);
    if (text.isEmpty) return;
    final section = _sectionFromHeading(text);
    if (section != null) {
      _section = section;
      return;
    }

    _description.add(
      ProductDescriptionParagraph(
        segments: _inlineSegments(element),
        type: ProductDescriptionBlockType.heading,
      ),
    );
  }

  void _parseTextBlock(Element element, {bool isListItem = false}) {
    final segments = _inlineSegments(element);
    final text = _segmentsText(segments);
    if (text.isEmpty) return;

    final section = _sectionFromHeading(text);
    if (section != null && _looksLikeStandaloneHeading(element, text)) {
      _section = section;
      return;
    }

    final wordListItem =
        isListItem ||
        (element.attributes['style'] ?? '').toLowerCase().contains(
          'mso-list',
        ) ||
        _startsWithBullet(text);

    switch (_section) {
      case _ContentSection.description:
        _description.add(
          ProductDescriptionParagraph(
            segments: _withoutLeadingBullet(segments),
            type: wordListItem
                ? ProductDescriptionBlockType.listItem
                : ProductDescriptionBlockType.paragraph,
          ),
        );
      case _ContentSection.features:
        _addFeature(_withoutLeadingBullet(segments));
      case _ContentSection.specifications:
        _addInlineSpecification(segments);
    }
  }

  void _parseTable(Element table) {
    for (final row in table.querySelectorAll('tr')) {
      final cells = row.children
          .where((cell) => cell.localName == 'td' || cell.localName == 'th')
          .map(_plainText)
          .where((cell) => cell.isNotEmpty)
          .toList(growable: false);
      if (cells.length < 2 || _isSpecificationHeader(cells[0], cells[1])) {
        continue;
      }
      _specifications.add(
        ProductSpecification(
          label: cells.first,
          value: cells.skip(1).join(' '),
        ),
      );
    }
    if (_specifications.isNotEmpty) {
      _section = _ContentSection.specifications;
    }
  }

  void _addFeature(List<ProductDescriptionSegment> segments) {
    final text = _segmentsText(segments);
    if (text.isEmpty) return;

    final emphasized = _normalizeText(
      segments
          .where((segment) => segment.emphasized)
          .map((segment) => segment.text)
          .join(),
    );
    if (emphasized.isNotEmpty && text.startsWith(emphasized)) {
      final title = emphasized.replaceFirst(RegExp(r':\s*$'), '');
      final description = text
          .substring(emphasized.length)
          .replaceFirst(RegExp(r'^\s*[:\-–]\s*'), '')
          .trim();
      _features.add(ProductFeature(title: title, description: description));
      return;
    }

    _features.add(ProductFeature(title: text, description: ''));
  }

  void _addInlineSpecification(List<ProductDescriptionSegment> segments) {
    final text = _segmentsText(segments);
    if (text.isEmpty) return;
    final emphasized = _normalizeText(
      segments
          .where((segment) => segment.emphasized)
          .map((segment) => segment.text)
          .join(),
    );
    final colonIndex = text.indexOf(':');
    final label = emphasized.isNotEmpty
        ? emphasized.replaceFirst(RegExp(r':\s*$'), '')
        : colonIndex > 0
        ? text.substring(0, colonIndex).trim()
        : '';
    final value = label.isEmpty
        ? text
        : text
              .substring(text.indexOf(label) + label.length)
              .replaceFirst(RegExp(r'^\s*:\s*'), '')
              .trim();
    _specifications.add(ProductSpecification(label: label, value: value));
  }

  void _addDescriptionText(String text) {
    _description.add(
      ProductDescriptionParagraph(segments: [ProductDescriptionSegment(text)]),
    );
  }
}

const _headingTags = {'h1', 'h2', 'h3', 'h4', 'h5', 'h6'};
const _paragraphTags = {'p', 'div', 'section', 'article', 'blockquote'};
const _blockTags = {
  ..._headingTags,
  ..._paragraphTags,
  'table',
  'ul',
  'ol',
  'li',
};

bool _containsBlockChildren(Element element) {
  return element.children.any((child) => _blockTags.contains(child.localName));
}

_ContentSection? _sectionFromHeading(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
  if (normalized.contains('product specification') ||
      normalized == 'specification' ||
      normalized == 'specifications') {
    return _ContentSection.specifications;
  }
  if (normalized.contains('key feature') || normalized == 'features') {
    return _ContentSection.features;
  }
  if (normalized.contains('product description') ||
      normalized == 'description') {
    return _ContentSection.description;
  }
  return null;
}

bool _looksLikeStandaloneHeading(Element element, String text) {
  final normalized = text.trim();
  if (normalized.length > 48) return false;
  if (element.querySelector('strong, b') != null) return true;
  return normalized.endsWith(':');
}

bool _isSpecificationHeader(String first, String second) {
  final labels = {first.toLowerCase().trim(), second.toLowerCase().trim()};
  return labels.contains('detail') && labels.contains('specification') ||
      labels.contains('label') && labels.contains('value');
}

bool _startsWithBullet(String value) {
  return RegExp(r'^[•●▪◦]').hasMatch(value.trimLeft());
}

String _plainText(Node node) => _normalizeText(node.text ?? '');

String _normalizeText(String value) {
  return value
      .replaceAll('\u00a0', ' ')
      .replaceAll(RegExp(r'[ \t\r\n]+'), ' ')
      .trim();
}

String _segmentsText(List<ProductDescriptionSegment> segments) {
  return _normalizeText(segments.map((segment) => segment.text).join());
}

List<ProductDescriptionSegment> _inlineSegments(Node root) {
  final raw = <ProductDescriptionSegment>[];

  void visit(Node node, bool emphasized) {
    if (node is Text) {
      final value = node.data
          .replaceAll('\u00a0', ' ')
          .replaceAll(RegExp(r'[ \t\r\n]+'), ' ');
      if (value.isNotEmpty) {
        raw.add(ProductDescriptionSegment(value, emphasized: emphasized));
      }
      return;
    }
    if (node is! Element) return;
    if (node.localName == 'br') {
      raw.add(ProductDescriptionSegment('\n', emphasized: emphasized));
      return;
    }
    final childEmphasized =
        emphasized || node.localName == 'strong' || node.localName == 'b';
    for (final child in node.nodes) {
      visit(child, childEmphasized);
    }
  }

  for (final child in root.nodes) {
    visit(child, false);
  }

  final merged = <ProductDescriptionSegment>[];
  for (final segment in raw) {
    if (merged.isNotEmpty && merged.last.emphasized == segment.emphasized) {
      merged[merged.length - 1] = ProductDescriptionSegment(
        '${merged.last.text}${segment.text}',
        emphasized: segment.emphasized,
      );
    } else {
      merged.add(segment);
    }
  }
  if (merged.isEmpty) return const [];
  merged[0] = ProductDescriptionSegment(
    merged.first.text.trimLeft(),
    emphasized: merged.first.emphasized,
  );
  merged[merged.length - 1] = ProductDescriptionSegment(
    merged.last.text.trimRight(),
    emphasized: merged.last.emphasized,
  );
  return merged.where((segment) => segment.text.isNotEmpty).toList();
}

List<ProductDescriptionSegment> _withoutLeadingBullet(
  List<ProductDescriptionSegment> segments,
) {
  final result = List<ProductDescriptionSegment>.from(segments);
  while (result.isNotEmpty) {
    final cleaned = result.first.text.replaceFirst(RegExp(r'^[\s•●▪◦]+'), '');
    if (cleaned.isEmpty) {
      result.removeAt(0);
      continue;
    }
    result[0] = ProductDescriptionSegment(
      cleaned,
      emphasized: result.first.emphasized,
    );
    break;
  }
  return result;
}
