import 'dart:io';
import 'package:image/image.dart' as image;
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart'
    as webview_flutter_android;

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _webViewController;
  late bool result = false;
  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {
            showNoInternetDialog();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://erp.polt.pk'));

    if (Platform.isAndroid) {
      fileHandling();
    }
  }

  Future<void> fileHandling() async {
    final controller = (_webViewController.platform
        as webview_flutter_android.AndroidWebViewController);

    await controller.setOnShowFileSelector(
        (webview_flutter_android.FileSelectorParams params) async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      print("File Picker${result}");
      if (params.acceptTypes.any((type) => type == 'image/*')) {
        final picker = image_picker.ImagePicker();
        final photo =
            await picker.pickImage(source: image_picker.ImageSource.gallery);

        if (photo == null) {
          return [];
        }

        final imageData = await photo.readAsBytes();
        final decodedImage = image.decodeImage(imageData)!;
        final scaledImage = image.copyResize(decodedImage, width: 500);
        final jpg = image.encodeJpg(scaledImage, quality: 90);

        final filePath = (await getTemporaryDirectory()).uri.resolve(
              './image_${DateTime.now().microsecondsSinceEpoch}.jpg',
            );
        final file = await File.fromUri(filePath).create(recursive: true);
        await file.writeAsBytes(jpg, flush: true);

        return [file.uri.toString()];
      }

      // if (result != null && result.files.isNotEmpty) {
      //   // User picked a file
      //   // Extract file paths from the result
      //   List<String> filePaths =
      //       result.files.map((file) => file.path!).toList();

      //   // You can now use the selected file path(s) as needed
      //   // For demonstration purposes, let's return the selected file paths.
      //   print("picked file${filePaths}");
      //   return filePaths;
      // } else {
      //   // User canceled the file picker
      //   // Return an empty list or null to indicate no files selected.
      //   return [];
      // }
       return [];
    });
  }

  Future<void> checkInternetConnection() async {
    result = await InternetConnectionChecker().hasConnection;
  }

  void loadWebView() {}

  void showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Flutter Simple Example')),
      body: SafeArea(
          child: WebViewWidget(
        controller: _webViewController,
      )),
    );
  }
}
