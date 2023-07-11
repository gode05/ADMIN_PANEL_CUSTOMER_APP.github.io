import 'package:admin_panel_customers_app/providers/dark_theme_provider.dart';
import 'package:admin_panel_customers_app/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'hide MenuController;
import 'package:provider/provider.dart';

import 'consts/theme_data.dart';
import 'controllers/menu_controller.dart';
import 'inner_screens/add_prod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
      options: const FirebaseOptions(
  apiKey: "AIzaSyAnOSWFE2E5QbCiirshhezq4GpKOGPSWyU",
  authDomain: "customers-app-62f8c.firebaseapp.com",
  projectId: "customers-app-62f8c",
  storageBucket: "customers-app-62f8c.appspot.com",
  messagingSenderId: "671164035990",
  appId: "1:671164035990:web:1d526735273c1a874863b7",
  measurementId: "G-CXNQY1T0M2"));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text('App is being initialized'),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: Center(
                    child: Text('An error has been occured ${snapshot.error}'),
                  ),
                ),
              ),
            );
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => MenuController(),
              ),
              ChangeNotifierProvider(
                create: (_) {
                  return themeChangeProvider;
                },
              ),
            ],
            child: Consumer<DarkThemeProvider>(
              builder: (context, themeProvider, child) {
                return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: 'shop',
                    theme:
                        Styles.themeData(themeProvider.getDarkTheme, context),
                    home: const Home(),
                    routes: {
                      AddProducts.routeName: (context) => const AddProducts(),
                    });
              },
            ),
          );
        });
  }
}
