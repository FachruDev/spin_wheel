import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../core/data/repository_providers.dart';
import '../core/server/server_providers.dart';
import '../features/auth/sign_in_page.dart';
import '../features/events/event_page.dart';
import '../features/events/events_page.dart';
import '../features/organizations/organizations_page.dart';
import '../features/stage/stage_routes.dart';

/// Rute aplikasi. Semua halaman kecuali login butuh login, kecuali di mode offline (data di
/// laptop ini, tanpa server dan tanpa login).
///
///   /masuk                      → login / daftar / masuk mode offline
///   /                           → organisasi saya
///   /o/:org                     → acara dalam organisasi
///   /o/:org/a/:event            → peserta, hadiah, pemenang
///   /o/:org/a/:event/panggung   → layar panggung acara
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(clientProvider).auth;
  final offline = ValueNotifier(ref.read(offlineSessionProvider) != null);
  ref.listen(offlineSessionProvider, (_, session) => offline.value = session != null);
  final router = GoRouter(
    refreshListenable: Listenable.merge([auth.authInfoListenable, offline]),
    redirect: (context, state) {
      final path = state.uri.path;
      final signedIn = auth.isAuthenticated || offline.value;
      if (!signedIn && path != '/masuk') return '/masuk';
      if (signedIn && path == '/masuk') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/masuk', builder: (_, _) => const SignInPage()),
      GoRoute(
        path: '/',
        builder: (_, _) => const OrganizationsPage(),
        routes: [
          GoRoute(
            path: 'o/:org',
            builder: (_, state) => EventsPage(organizationId: _id(state, 'org')),
            routes: [
              GoRoute(
                path: 'a/:event',
                builder: (_, state) => EventPage(organizationId: _id(state, 'org'), eventId: _id(state, 'event')),
                routes: [
                  GoRoute(
                    path: 'panggung',
                    builder: (_, state) =>
                        EventStageRoute(organizationId: _id(state, 'org'), eventId: _id(state, 'event')),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    offline.dispose();
  });
  return router;
});

int _id(GoRouterState state, String name) => int.tryParse(state.pathParameters[name] ?? '') ?? -1;
