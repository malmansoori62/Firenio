import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'logic/game_controller.dart';
import 'logic/progress_manager.dart';
import 'models/app_settings.dart';
import 'screens/splash_screen.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  final settings = AppSettings();
  final progress = ProgressManager();
  await Future.wait([settings.load(), progress.load()]);

  runApp(ElementsGridApp(settings: settings, progress: progress));
}

class ElementsGridApp extends StatelessWidget {
  final AppSettings settings;
  final ProgressManager progress;

  const ElementsGridApp({
    super.key,
    required this.settings,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: progress),
        ChangeNotifierProvider(create: (_) => GameController()),
      ],
      child: MaterialApp(
        title: 'Elements Grid',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
