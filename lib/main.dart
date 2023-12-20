import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_erp/web_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: false, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl : true // option: set to false to disable working with http links (default: false)
  );
  PermissionStatus status = await requestFilePermissionAndShowDialog();
  if (!status.isGranted) {
       await requestFilePermissionAndShowDialog();
  }
   runApp(const MyApp());
}

void showFileDialog(BuildContext context) {
  // Implement your file dialog logic here
  // You can use packages like file_picker to pick a file or implement your own dialog
  // based on your requirements.
}

Future<PermissionStatus> requestFilePermissionAndShowDialog() async {
  var status = await Permission.storage.status;

  if (!status.isGranted) {
    status = await Permission.storage.request();
  }
  return status;
  // Handle the status as needed
  // ...

  // You can also access the context here if needed
  // Example: Navigator.of(context).push(...);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Change the color to your desired color
      statusBarBrightness: Brightness.dark, // Change the brightness if needed
    ));
    return MaterialApp(
      color: Colors.black,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WebViewScreen(),
    );
  }
}
