import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each translated message has explicit legal review metadata', () {
    Set<String>? reference;
    for (final locale in ['es', 'en']) {
      final data =
          jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
              as Map<String, dynamic>;
      final keys = data.keys.where((key) => !key.startsWith('@')).toSet();
      expect(keys, isNotEmpty);
      if (reference != null) expect(keys, reference);
      reference = keys;
      for (final key in keys) {
        final metadata = data['@$key'];
        expect(metadata, isA<Map<String, dynamic>>(), reason: '$locale:$key');
        expect(
          ['pending', 'approved'],
          contains((metadata as Map<String, dynamic>)['legal_review']),
          reason: '$locale:$key needs an explicit review status',
        );
      }
      for (final key in data.keys.where(
        (key) => key.startsWith('@') && !key.startsWith('@@'),
      )) {
        expect(
          keys,
          contains(key.substring(1)),
          reason: 'Orphan metadata $key',
        );
      }
    }
  });
}
