import 'package:flutter/material.dart';
import 'package:upgrader_sds/upgrader.dart';
import 'package:version/version.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only call clearSavedSettings() during testing to reset internal values.
  await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  runApp(const MyApp());
}

class MockStore extends UpgraderStore {
  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required UpgraderState state,
    required Version installedVersion,
    required String? country,
    required String? language,
  }) async {
    return UpgraderVersionInfo(
      installedVersion: Version(4, 9, 2),
      appStoreVersion: Version(4, 10, 1),
      appStoreListingURL: 'https://example.com',
      releaseNotes: '• Tối ưu hiệu năng ứng dụng',
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    _upgrader = Upgrader(
      debugDisplayAlways: true,
      debugLogging: true,
      messages: UpgraderMessages(code: 'vi'),
      storeController: UpgraderStoreController(
        onAndroid: () => MockStore(),
        oniOS: () => MockStore(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upgrader Example',
      home: UpgradeAlert(
        isFullScreen: false,
        upgrader: _upgrader,
        child: Scaffold(
          appBar: AppBar(title: const Text('Upgrader Example')),
          body: const Center(child: Text('Checking...')),
        ),
      ),
    );
  }
}
