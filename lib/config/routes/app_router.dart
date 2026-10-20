import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:secret/core/navigation/bottom_navigation_bar.dart';
import 'package:secret/core/network/user_state_network.dart';
import 'package:secret/core/service/auth_service.dart';
import 'package:secret/features/auth/presentation/screens/login_screen.dart';
import 'package:secret/features/auth/presentation/screens/register_screen.dart';
import 'package:secret/features/auth/presentation/screens/username_screen.dart';
import 'package:secret/features/chat/presentation/screens/chat_screen.dart';
import 'package:secret/features/home/presentation/screens/home_screen.dart';
import 'package:secret/features/profile/presentation/screens/profile_screen.dart';
import 'package:secret/features/settings/presentation/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: GetIt.I<AuthService>(),
  redirect: (context, state) {
    final bool isInitialized = GetIt.I<AuthService>().isInitialized;
    final bool isLoggedIn = GetIt.I<AuthService>().isLoggedIn;
    final bool hasUsername = GetIt.I<AuthService>().hasUsername;

    final bool loggingIn =
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/username';

    final bool isSplash = state.matchedLocation == '/splash';

    if (!isInitialized) {
      return isSplash ? null : '/splash';
    }

    if (isLoggedIn && !hasUsername) {
      return '/username';
    }

    if (!isLoggedIn) {
      return loggingIn ? null : '/login';
    }

    if (loggingIn || isSplash) {
      GetIt.I<UserStateNetwork>().startTracking();
      return state.namedLocation('home');
    }

    if (loggingIn && hasUsername) {
      GetIt.I<UserStateNetwork>().startTracking();
      return state.namedLocation('home');
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Image.asset('assets/images/app_icon/app_icon_loading.gif'),
        ),
      ),
    ),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
    GoRoute(path: '/username', builder: (context, state) => UsernameScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/profile', builder: (context, state) => ProfileScreen()),
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/chat/:chatRoomId/:partnerName/:partnerId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final chatRoomId = state.pathParameters['chatRoomId']!;
        final partnerName = state.pathParameters['partnerName']!;
        final partnerId = state.pathParameters['partnerId']!;

        return ChatScreen(
          chatRoomId: chatRoomId,
          partnerName: partnerName,
          partnerId: partnerId,
        );
      },
    ),
  ],
);
