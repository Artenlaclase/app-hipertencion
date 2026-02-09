import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/auth_token_service.dart';
import '../../presentation/screens/disclaimer_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/home_screen.dart';

class AppRoutes {
  static const String disclaimer = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String home = '/home';

  /// Determines the initial route based on auth state.
  static String get initialRoute {
    final authService = GetIt.instance<AuthTokenService>();
    if (authService.isAuthenticated) {
      if (authService.hasCompletedOnboarding) {
        return home;
      }
      return onboarding;
    }
    return disclaimer;
  }
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.disclaimer:
        return MaterialPageRoute(
          builder: (context) => DisclaimerScreen(
            onAccepted: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        );
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (context) => OnboardingScreen(
            onCompleted: (profile) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            },
          ),
        );
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
