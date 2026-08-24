import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class PostLoginIntent {
  const PostLoginIntent();
}

class GuestOrderPostLoginIntent extends PostLoginIntent {
  const GuestOrderPostLoginIntent({required this.orderId});

  final String orderId;
}

final pendingPostLoginIntentProvider =
    NotifierProvider<PendingPostLoginIntentController, PostLoginIntent?>(
      PendingPostLoginIntentController.new,
    );

class PendingPostLoginIntentController extends Notifier<PostLoginIntent?> {
  @override
  PostLoginIntent? build() => null;

  void set(PostLoginIntent intent) => state = intent;

  PostLoginIntent? consume() {
    final intent = state;
    state = null;
    return intent;
  }
}
