import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../core/server/server_providers.dart';
import '../features/auth/sign_in_page.dart';
import '../features/events/event_page.dart';
import '../features/events/events_page.dart';
import '../features/organizations/organizations_page.dart';
import '../features/stage/stage_routes.dart';

/// Rute aplikasi. Semua halaman kecuali login dan demo butuh login.
///
///   /masuk                      → login / daftar
///   /demo                       → panggung demo (tanpa server)
///   /                           → organisasi saya
///   /o/:org                     → acara dalam organisasi
///   /o/:org/a/:event            → peserta, hadiah, pemenang
///   /o/:org/a/:event/panggung   → layar panggung acara
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(clientProvider).auth;
  final router = GoRouter(
    refreshListenable: auth.authInfoListenable,
    redirect: (context, state) {
      final path = state.uri.path;
      final public = path == '/masuk' || path == '/demo';
      if (!auth.isAuthenticated && !public) return '/masuk';
      if (auth.isAuthenticated && path == '/masuk') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/masuk', builder: (_, _) => const SignInPage()),
      GoRoute(path: '/demo', builder: (_, _) => const DemoStageRoute()),
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
  ref.onDispose(router.dispose);
  return router;
});

int _id(GoRouterState state, String name) => int.tryParse(state.pathParameters[name] ?? '') ?? -1;
