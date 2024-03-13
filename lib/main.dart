import 'package:flutter/material.dart';
import 'package:image_picker_example/cam_page.dart';
import 'package:image_picker_example/cam_red_page.dart';
import 'package:image_picker_example/image_picker_screen.dart';

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
      initialRoute: ImagePickerScreen.routeName,
      routes: {
        ImagePickerScreen.routeName: (context) => const ImagePickerScreen(),
        CamPage.routeName: (context) => const CamPage(),
        CamRedPage.routeName: (context) => const CamRedPage(),
      },
    );
  }
}
