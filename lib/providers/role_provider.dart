import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/providers/user_provider.dart';

final roleProvider =
    Provider<String?>((ref) {

  final user =
      ref.watch(currentUserProvider);

  return user?.role;
});