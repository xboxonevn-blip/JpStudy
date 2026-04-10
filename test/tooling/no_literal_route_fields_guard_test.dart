import 'package:flutter_test/flutter_test.dart';
import '../../tool/check_no_literal_route_fields.dart';

void main() {
  test('lib avoids literal route fields outside app/navigation', () {
    final failures = findLiteralRouteFields();
    expect(failures, isEmpty, reason: failures.join('\n'));
  });
}
