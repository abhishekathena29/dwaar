import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/firebase_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'features/admin/provider/admin_provider.dart';
import 'features/admin/repository/admin_repository.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/auth/repository/society_repository.dart';
import 'features/auth/screens/join_society_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/setup_profile_screen.dart';
import 'features/auth/screens/society_choice_screen.dart';
import 'features/auth/screens/verify_otp_screen.dart';
import 'features/committee/provider/committee_provider.dart';
import 'features/committee/repository/committee_repository.dart';
import 'features/complaints/provider/complaints_provider.dart';
import 'features/complaints/repository/complaints_repository.dart';
import 'features/events/provider/events_provider.dart';
import 'features/events/repository/events_repository.dart';
import 'features/noticeboard/provider/noticeboard_provider.dart';
import 'features/noticeboard/repository/noticeboard_repository.dart';
import 'features/services/provider/services_provider.dart';
import 'features/services/repository/services_repository.dart';
import 'shell/home_shell.dart';

class DwaarApp extends StatelessWidget {
  const DwaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseBootstrap.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MultiProvider(
          providers: [
            // Repositories
            Provider(create: (_) => AuthRepository()),
            Provider(create: (_) => SocietyRepository()),
            Provider(create: (_) => NoticeboardRepository()),
            Provider(create: (_) => ComplaintsRepository()),
            Provider(create: (_) => EventsRepository()),
            Provider(create: (_) => ServicesRepository()),
            Provider(create: (_) => CommitteeRepository()),
            Provider(create: (_) => AdminRepository()),

            // Auth provider
            ChangeNotifierProvider(
              create: (context) => AuthProvider(
                authRepository: context.read<AuthRepository>(),
                societyRepository: context.read<SocietyRepository>(),
              )..initialize(),
            ),

            // Feature providers
            ChangeNotifierProxyProvider<AuthProvider, NoticeboardProvider>(
              create: (context) => NoticeboardProvider(
                repository: context.read<NoticeboardRepository>(),
                authProvider: context.read<AuthProvider>(),
              ),
              update: (_, auth, provider) => provider!..bindAuth(auth),
            ),
            ChangeNotifierProxyProvider<AuthProvider, ComplaintsProvider>(
              create: (context) => ComplaintsProvider(
                repository: context.read<ComplaintsRepository>(),
                authProvider: context.read<AuthProvider>(),
              ),
              update: (_, auth, provider) => provider!..bindAuth(auth),
            ),
            ChangeNotifierProxyProvider<AuthProvider, EventsProvider>(
              create: (context) => EventsProvider(
                repository: context.read<EventsRepository>(),
                authProvider: context.read<AuthProvider>(),
              ),
              update: (_, auth, provider) => provider!..bindAuth(auth),
            ),
            ChangeNotifierProxyProvider<AuthProvider, ServicesProvider>(
              create: (context) => ServicesProvider(
                repository: context.read<ServicesRepository>(),
                authProvider: context.read<AuthProvider>(),
              ),
              update: (_, auth, provider) => provider!..bindAuth(auth),
            ),
            ChangeNotifierProxyProvider<AuthProvider, CommitteeProvider>(
              create: (context) => CommitteeProvider(
                repository: context.read<CommitteeRepository>(),
                authProvider: context.read<AuthProvider>(),
              ),
              update: (_, auth, provider) => provider!..bindAuth(auth),
            ),
            ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
              create: (context) => AdminProvider(
                repository: context.read<AdminRepository>(),
                authProvider: context.read<AuthProvider>(),
              ),
              update: (_, auth, provider) => provider!..bindAuth(auth),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Dwaar',
            theme: AppTheme.theme,
            routes: {
              LoginScreen.routeName: (_) => const LoginScreen(),
              VerifyOtpScreen.routeName: (_) => const VerifyOtpScreen(),
              SetupProfileScreen.routeName: (_) => const SetupProfileScreen(),
              SocietyChoiceScreen.routeName: (_) =>
                  const SocietyChoiceScreen(),
              JoinSocietyScreen.routeName: (_) => const JoinSocietyScreen(),
              HomeShell.routeName: (_) => const HomeShell(),
            },
            home: const AuthRouter(),
          ),
        );
      },
    );
  }
}

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }
        if (!auth.hasCompletedProfile) {
          return const SetupProfileScreen();
        }
        if (!auth.hasMembership) {
          return const SocietyChoiceScreen();
        }
        return const HomeShell();
      },
    );
  }
}
