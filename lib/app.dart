import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'config/di/injection.dart';
import 'config/routes/router_config.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/invitation/presentation/bloc/invitation_bloc.dart';
import 'features/payment/presentation/bloc/payment_bloc.dart';

// Placeholder for ThemeGalleryBloc as it wasn't detailed in PRD but used in main.dart snippet
class ThemeGalleryBloc extends Cubit<int> { ThemeGalleryBloc() : super(0); }

class NikahKitApp extends HookWidget {
  const NikahKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = useMemoized(() => getIt<AuthBloc>(), []);
    final router = useMemoized(() => createRouter(authBloc), [authBloc]);

    useEffect(() {
      authBloc.add(const AuthEvent.checkAuthStatus());
      return authBloc.close;
    }, []);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(create: (_) => getIt<InvitationBloc>()),
        BlocProvider(create: (_) => getIt<PaymentBloc>()),
        BlocProvider(create: (_) => ThemeGalleryBloc()),
      ],
      child: MaterialApp.router(
        title: 'NikahKit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(), // Placeholder for AppTheme.light
        darkTheme: ThemeData.dark(), // Placeholder for AppTheme.dark
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
