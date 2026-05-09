/*
 * Copyright (c) 2019-2024 Larry Aasen. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:upgrader_sds/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only call clearSavedSettings() during testing to reset internal values.
  await Upgrader.clearSavedSettings(); // REMOVE this for release builds

  // On Android, the default behavior will be to use the Google Play Store
  // version of the app.
  // On iOS, the default behavior will be to use the App Store version of
  // the app, so update the Bundle Identifier in example/ios/Runner with a
  // valid identifier already in the App Store.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Upgrader Example',
      home: UpgradeAlert(
        isFullScreen: false,
        upgrader: Upgrader(
          messages: UpgraderMessages(code: 'vi'),
//           releaseNotes: '''
// 🚀 [Bổ sung]
// - Chức năng tạo đơn đặt phòng xe.
// - Thời gian vào ra giữa ca tại lịch sử chấm công.

// ⚡️ [Optimize]
// - Luồng hiển thị thông tin mượt mà hơn.

// 🛠 [Sửa lỗi]
// - Lỗi văng ứng dụng khi cập nhật ảnh đại diện.

// 🔒 [Security]
// - Cập nhật bảo mật hệ thống.
// ''',
        ),
        child: Scaffold(
          appBar: AppBar(title: const Text('Upgrader Example')),
          body: const Center(child: Text('Checking...')),
        ),
      ),
    );
  }
}
