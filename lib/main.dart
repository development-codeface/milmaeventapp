import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milma_group/provider/commonviewmodel.dart';
import 'package:milma_group/screens/splash_screen.dart';
import 'package:milma_group/session/shared_preferences.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommonViewModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Milma',
        theme: ThemeData(
          fontFamily: 'Figtree',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
