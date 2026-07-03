import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexevent/models/registration_model.dart';


final currentRegProvider =
    NotifierProvider<
      CurrentRegNotifier,
      RegistrationModel?
    >(
      CurrentRegNotifier.new,
    );




class CurrentRegNotifier extends Notifier<RegistrationModel?> {

  @override
  RegistrationModel? build() {
    return null;
  }

  void setUser(RegistrationModel reg) {
    state = reg;
  }

  void clearReg() {
    state = null;
  }
}