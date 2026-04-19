import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/app_router.dart';
import 'core/design/design.dart';
import 'services/notification_service.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await Hive.initFlutter();
  await Hive.openBox<String>('favorites');
  await Hive.openBox('settings');
  await NotificationService.init();
  runApp(const ProviderScope(child: ScraberApp()));
}

class ScraberApp extends ConsumerStatefulWidget {
  const ScraberApp({super.key});

  @override
  ConsumerState<ScraberApp> createState() => _ScraberAppState();
}

class _ScraberAppState extends ConsumerState<ScraberApp> {
  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesControllerProvider);
    NotificationService.syncThreshold(prefs.threshold);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(NotificationService.bindRouter(ref.read(appRouterProvider)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesControllerProvider);
    return MaterialApp.router(
      title: 'Scraber',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: prefs.themeMode,
      routerConfig: ref.watch(appRouterProvider),
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
