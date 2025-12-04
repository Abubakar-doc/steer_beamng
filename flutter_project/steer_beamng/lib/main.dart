import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:steer_beamng/bindings/console_binding.dart';
import 'constants/routes_helper.dart';
import 'routes/app_pages.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Steering Wheel',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.steering,
      initialBinding: ConsoleBinding(),
      getPages: AppPages.routes,
    );
  }
}
