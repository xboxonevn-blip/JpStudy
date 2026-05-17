import 'package:go_router/go_router.dart';
import 'package:jpstudy/app/navigation/routes/memory_routes.dart';
import 'package:jpstudy/app/navigation/routes/practice_routes.dart';

StatefulShellBranch buildReviewBranch() {
  return StatefulShellBranch(
    routes: [...buildPracticeRoutes(), ...buildMemoryRoutes()],
  );
}
