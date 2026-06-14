import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/user_model.dart';


final currentUserProvider =
    NotifierProvider<
      CurrentUserNotifier,
      UserModel?
    >(
      CurrentUserNotifier.new,
    );




class CurrentUserNotifier extends Notifier<UserModel?> {

  @override
  UserModel? build() {
    return null;
  }

  void setUser(UserModel user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}