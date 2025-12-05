import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/payment/domain/entities/payment_entity.dart';

part 'app_router.g.dart';

// Root Navigation Key
final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

// Placeholder Pages
class SplashPage extends StatelessWidget { const SplashPage({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Splash'))); }
class LoginPage extends StatelessWidget { const LoginPage({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login'))); }
class RegisterPage extends StatelessWidget { const RegisterPage({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Register'))); }
class ForgotPasswordPage extends StatelessWidget { const ForgotPasswordPage({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Forgot Password'))); }
class VerifyOtpPage extends StatelessWidget { final String email; const VerifyOtpPage({super.key, required this.email}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Verify OTP for $email'))); }
class MainShellPage extends StatelessWidget { final Widget child; const MainShellPage({super.key, required this.child}); @override Widget build(BuildContext context) => Scaffold(body: child, bottomNavigationBar: BottomNavigationBar(items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home')])); }
class HomePage extends StatelessWidget { const HomePage({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Home'))); }
class InvitationsPage extends StatelessWidget { const InvitationsPage({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Invitations'))); }
class InvitationDetailPage extends StatelessWidget { final String invitationId; const InvitationDetailPage({super.key, required this.invitationId}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Invitation Detail $invitationId'))); }
class InvitationBuilderPage extends StatelessWidget { final String invitationId; final int initialStep; const InvitationBuilderPage({super.key, required this.invitationId, required this.initialStep}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Builder $invitationId step $initialStep'))); }
class GuestsPage extends StatelessWidget { final String invitationId; const GuestsPage({super.key, required this.invitationId}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Guests $invitationId'))); }
class ProfilePage extends StatelessWidget { const ProfilePage({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Profile'))); }
class SubscriptionPage extends StatelessWidget { const SubscriptionPage({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Subscription'))); }
class PaymentPage extends StatelessWidget { final PaymentType type; final String? packageType; final String? invitationId; const PaymentPage({super.key, required this.type, this.packageType, this.invitationId}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Payment ${type.name}'))); }
class PaymentStatusPage extends StatelessWidget { final String merchantOrderId; const PaymentStatusPage({super.key, required this.merchantOrderId}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Status $merchantOrderId'))); }
class PublicInvitationPage extends StatelessWidget { final String slug; final String? guestName; const PublicInvitationPage({super.key, required this.slug, this.guestName}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Invitation $slug for $guestName'))); }


// Route Definitions
@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashPage();
  }
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const LoginPage();
  }
}

@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const RegisterPage();
  }
}

@TypedGoRoute<ForgotPasswordRoute>(path: '/forgot-password')
class ForgotPasswordRoute extends GoRouteData {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ForgotPasswordPage();
  }
}

@TypedGoRoute<VerifyOtpRoute>(path: '/verify-otp/:email')
class VerifyOtpRoute extends GoRouteData {
  final String email;

  const VerifyOtpRoute({required this.email});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return VerifyOtpPage(email: email);
  }
}

// Shell Route for Main App with Bottom Navigation
@TypedShellRoute<MainShellRoute>(
  routes: [
    TypedGoRoute<HomeRoute>(path: '/home'),
    TypedGoRoute<InvitationsRoute>(
      path: '/invitations',
      routes: [
        TypedGoRoute<InvitationDetailRoute>(path: ':id'),
        TypedGoRoute<InvitationBuilderRoute>(path: 'builder/:id'),
        TypedGoRoute<InvitationPreviewRoute>(path: 'preview/:id'),
      ],
    ),
    TypedGoRoute<GuestsRoute>(
      path: '/guests/:invitationId',
      routes: [
        TypedGoRoute<GuestDetailRoute>(path: ':guestId'),
        TypedGoRoute<GuestImportRoute>(path: 'import'),
        TypedGoRoute<QrScannerRoute>(path: 'scan'),
      ],
    ),
    TypedGoRoute<ProfileRoute>(
      path: '/profile',
      routes: [
        TypedGoRoute<EditProfileRoute>(path: 'edit'),
        TypedGoRoute<SubscriptionRoute>(path: 'subscription'),
        TypedGoRoute<PaymentHistoryRoute>(path: 'payments'),
      ],
    ),
  ],
)
class MainShellRoute extends ShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return MainShellPage(child: navigator);
  }
}

class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const HomePage();
  }
}

class InvitationsRoute extends GoRouteData {
  const InvitationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const InvitationsPage();
  }
}

class InvitationDetailRoute extends GoRouteData {
  final String id;

  const InvitationDetailRoute({required this.id});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return InvitationDetailPage(invitationId: id);
  }
}

class InvitationBuilderRoute extends GoRouteData {
  final String id;
  final int? step;

  const InvitationBuilderRoute({required this.id, this.step});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return InvitationBuilderPage(invitationId: id, initialStep: step ?? 0);
  }
}

class InvitationPreviewRoute extends GoRouteData {
  final String id;
  const InvitationPreviewRoute({required this.id});
  @override
  Widget build(BuildContext context, GoRouterState state) {
     return Scaffold(body: Center(child: Text('Preview $id')));
  }
}

class GuestsRoute extends GoRouteData {
  final String invitationId;

  const GuestsRoute({required this.invitationId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return GuestsPage(invitationId: invitationId);
  }
}

class GuestDetailRoute extends GoRouteData {
  final String invitationId;
  final String guestId;
  const GuestDetailRoute({required this.invitationId, required this.guestId});
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Scaffold(body: Center(child: Text('Guest Detail $guestId')));
  }
}

class GuestImportRoute extends GoRouteData {
  final String invitationId;
  const GuestImportRoute({required this.invitationId});
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Scaffold(body: Center(child: Text('Import Guests')));
  }
}

class QrScannerRoute extends GoRouteData {
  final String invitationId;
  const QrScannerRoute({required this.invitationId});
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Scaffold(body: Center(child: Text('Scan QR')));
  }
}

class ProfileRoute extends GoRouteData {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
  }
}

class EditProfileRoute extends GoRouteData {
  const EditProfileRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('Edit Profile')));
  }
}

class SubscriptionRoute extends GoRouteData {
  const SubscriptionRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SubscriptionPage();
  }
}

class PaymentHistoryRoute extends GoRouteData {
  const PaymentHistoryRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Scaffold(body: Center(child: Text('Payment History')));
  }
}

// Payment Routes
@TypedGoRoute<PaymentRoute>(path: '/payment/:type')
class PaymentRoute extends GoRouteData {
  final String type; // subscription, envelope
  final String? packageType;
  final String? invitationId;

  const PaymentRoute({
    required this.type,
    this.packageType,
    this.invitationId,
  });

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PaymentPage(
      type: PaymentType.values.byName(type),
      packageType: packageType,
      invitationId: invitationId,
    );
  }
}

@TypedGoRoute<PaymentStatusRoute>(path: '/payment/status/:orderId')
class PaymentStatusRoute extends GoRouteData {
  final String orderId;

  const PaymentStatusRoute({required this.orderId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PaymentStatusPage(merchantOrderId: orderId);
  }
}

// Public Invitation View (No Auth)
@TypedGoRoute<PublicInvitationRoute>(path: '/i/:slug')
class PublicInvitationRoute extends GoRouteData {
  final String slug;
  final String? to; // Guest name parameter

  const PublicInvitationRoute({required this.slug, this.to});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return PublicInvitationPage(slug: slug, guestName: to);
  }
}
