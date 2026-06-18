import 'package:flutter_test/flutter_test.dart';

import 'package:mot_zaique/core/theme/pastel_theme.dart';
import 'package:mot_zaique/data/models/app_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('pastel theme is material3', () {
    expect(PastelTheme.build(AppSettings.defaults).useMaterial3, isTrue);
  });
}
