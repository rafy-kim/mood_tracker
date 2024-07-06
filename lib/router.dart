import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mood_tracker/common/widgets/main_navigation/main_navigation_screen.dart';
import 'package:mood_tracker/features/authentication/repos/authentication_repository.dart';
import 'package:mood_tracker/features/authentication/views/login_screen.dart';
import 'package:mood_tracker/features/authentication/views/signup_screen.dart';

final routerProvider = Provider(
  (ref) {
    return GoRouter(
      initialLocation: "/",
      redirect: (context, state) {
        final isLoggedIn = ref.read(authRepo).isLoggedIn;
        if (!isLoggedIn) {
          if (state.subloc != SignupScreen.routeURL &&
              state.subloc != LoginScreen.routeURL) {
            return SignupScreen.routeURL;
          }
        }
        return null;
      },
      routes: [
        GoRoute(
          name: LoginScreen.routeName,
          path: LoginScreen.routeURL,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          name: SignupScreen.routeName,
          path: SignupScreen.routeURL,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          name: MainNavigationScreen.routeName,
          path: "/:tab(|search|activity|profile)",
          builder: (context, state) {
            final tab = state.params["tab"]!;
            return MainNavigationScreen(tab: tab);
          },
        ),
      ],
    );
  },
);
