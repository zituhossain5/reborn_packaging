class CollectionItem {
  const CollectionItem({
    this.id = '',
    required this.title,
    required this.handle,
    this.imageUrl,
    this.imageAltText,
    this.imageAsset,
  });

  factory CollectionItem.fromShopifyJson(Map<String, dynamic> json) {
    final image = json['image'];
    final imageData = image is Map<String, dynamic> ? image : null;

    return CollectionItem(
      id: json['id'] as String? ?? '',
      handle: json['handle'] as String? ?? '',
      title: json['title'] as String? ?? '',
      imageUrl: imageData?['url'] as String?,
      imageAltText: imageData?['altText'] as String?,
    );
  }

  final String id;
  final String title;
  final String handle;
  final String? imageUrl;
  final String? imageAltText;
  final String? imageAsset;
}
