import '../config.dart';

mixin DebugPrint {
  Config get config;

  void debugPrint(final Object item) {
    if (config.debug) {
      if (item is Iterable) {
        for (var it in item) {
          print(it.toString());
        }
      } else {
        print(item.toString());
      }
    } else {
      print(item.toString());
    }
  }
}
