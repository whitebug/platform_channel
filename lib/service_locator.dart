import 'package:get_it/get_it.dart';
import 'package:keyboard_ios/key.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<KeyboardListener>(() => KeyboardListener());
}
