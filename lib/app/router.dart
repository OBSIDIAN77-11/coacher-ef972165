import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/reset_password_screen.dart';
import '../features/onboarding/onboarding_flow.dart';
import '../features/onboarding/payment_result_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const OnboardingFlow(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/payment-result',
        builder: (context, state) => PaymentResultScreen(
          paymentRef: state.uri.queryParameters['ref'],
        ),
      ),
    ],
  );
});
