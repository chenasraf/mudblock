import 'package:flutter/material.dart';
import 'package:mudblock/core/store.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: ChangeNotifierProvider(
          create: (_) => GameStore().init(),
          builder: (context, snapshot) {
            return const HomePage();
          }
        ),
      ),
    );
  }
}

