import 'package:flutter/widgets.dart';
import 'package:flutter_nfc_test/view/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(await App.withDependency());
}
