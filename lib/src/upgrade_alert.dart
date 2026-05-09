/*
 * Copyright (c) 2021-2024 Larry Aasen. All rights reserved.
 * Edited by LamBaoBao for SDS company
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'upgrade_messages.dart';
import 'upgrade_state.dart';
import 'upgrader.dart';

/// There are two different dialog styles: Cupertino and Material
enum UpgradeDialogStyle { cupertino, material }

/// A widget to display the upgrade dialog.
/// Override the [createState] method to provide a custom class
/// with overridden methods.
class UpgradeAlert extends StatefulWidget {
  /// Creates a new [UpgradeAlert].
  UpgradeAlert({
    super.key,
    Upgrader? upgrader,
    this.barrierDismissible = false,
    this.dialogStyle = UpgradeDialogStyle.material,
    this.onIgnore,
    this.onLater,
    this.onUpdate,
    this.shouldPopScope,
    this.showPrompt = true,
    this.showIgnore = true,
    this.showLater = true,
    this.showReleaseNotes = true,
    this.cupertinoButtonTextStyle,
    this.dialogKey,
    this.navigatorKey,
    this.icon,
    this.dialogBackgroundColor,
    this.textColor,
    this.buttonColor,
    this.buttonTextColor,
    this.child,
    this.isFullScreen,
    this.releaseNotesWidget,
  }) : upgrader = upgrader ?? Upgrader.sharedInstance;

  /// The upgraders used to configure the upgrade dialog.
  final Upgrader upgrader;

  /// The `barrierDismissible` argument is used to indicate whether tapping on the
  /// barrier will dismiss the dialog. (default: false)
  final bool barrierDismissible;

  /// The upgrade dialog style. Used only on UpgradeAlert. (default: material)
  final UpgradeDialogStyle dialogStyle;

  /// Called when the ignore button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  final BoolCallback? onIgnore;

  /// Called when the later button is tapped or otherwise activated.
  final BoolCallback? onLater;

  /// Called when the update button is tapped or otherwise activated.
  /// Return false when the default behavior should not execute.
  final BoolCallback? onUpdate;

  /// Called to determine if the dialog blocks the current route from being popped.
  final BoolCallback? shouldPopScope;

  /// Hide or show Prompt label on dialog (default: true)
  final bool showPrompt;

  /// Hide or show Ignore button on dialog (default: true)
  final bool showIgnore;

  /// Hide or show Later button on dialog (default: true)
  final bool showLater;

  /// Hide or show release notes (default: true)
  final bool showReleaseNotes;

  /// The text style for the cupertino dialog buttons. Used only for
  /// [UpgradeDialogStyle.cupertino]. Optional.
  final TextStyle? cupertinoButtonTextStyle;

  /// The [Key] assigned to the dialog when it is shown.
  final GlobalKey? dialogKey;

  /// For use by the Router architecture as part of the RouterDelegate.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// For use to config dialog
  final Widget? icon;
  final Color? dialogBackgroundColor;
  final Color? textColor;
  final List<Color>? buttonColor;
  final Color? buttonTextColor;
  final bool? isFullScreen;

  /// The [child] contained by the widget.
  final Widget? child;

  /// A custom widget to replace the default release notes list.
  final Widget? releaseNotesWidget;

  @override
  UpgradeAlertState createState() => UpgradeAlertState();
}

/// The [UpgradeAlert] widget state.
class UpgradeAlertState extends State<UpgradeAlert> {
  /// Is the alert dialog being displayed right now?
  bool displayed = false;

  @override
  void initState() {
    super.initState();
    widget.upgrader.initialize();
  }

  /// Describes the part of the user interface represented by this widget.
  @override
  Widget build(BuildContext context) {
    if (widget.upgrader.state.debugLogging) {
      print('upgrader: build UpgradeAlert');
    }

    return StreamBuilder(
      initialData: widget.upgrader.state,
      stream: widget.upgrader.stateStream,
      builder: (BuildContext context, AsyncSnapshot<UpgraderState> snapshot) {
        if ((snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.active) &&
            snapshot.data != null) {
          final upgraderState = snapshot.data!;
          if (upgraderState.versionInfo != null) {
            if (widget.upgrader.state.debugLogging) {
              print("upgrader: need to evaluate version");
            }

            if (!displayed) {
              final checkContext = widget.navigatorKey != null &&
                      widget.navigatorKey!.currentContext != null
                  ? widget.navigatorKey!.currentContext!
                  : context;
              checkVersion(context: checkContext);
            }
          }
        }
        return widget.child ?? const SizedBox.shrink();
      },
    );
  }

  /// Will show the alert dialog when it should be dispalyed.
  void checkVersion({required BuildContext context}) {
    final shouldDisplay = widget.upgrader.shouldDisplayUpgrade();
    if (widget.upgrader.state.debugLogging) {
      print('upgrader: shouldDisplayReleaseNotes: $shouldDisplayReleaseNotes');
    }
    if (shouldDisplay) {
      displayed = true;
      final appMessages = widget.upgrader.determineMessages(context);

      Future.delayed(Duration.zero, () {
        showTheDialog(
          key: widget.dialogKey ?? const Key('upgrader_alert_dialog'),
          // ignore: use_build_context_synchronously
          context: context,
          title: appMessages.message(UpgraderMessage.title),
          message: widget.upgrader.body(appMessages),
          releaseNotes:
              shouldDisplayReleaseNotes ? widget.upgrader.releaseNotes : null,
          barrierDismissible: widget.barrierDismissible,
          messages: appMessages,
          icon: widget.icon,
          dialogBackgroundColor: widget.dialogBackgroundColor,
          textColor: widget.textColor,
          buttonColor: widget.buttonColor,
          buttonTextColor: widget.buttonTextColor,
          isFullScreen: widget.isFullScreen,
          releaseNotesWidget: widget.releaseNotesWidget,
        );
      });
    }
  }

  void onUserIgnored(BuildContext context, bool shouldPop) {
    if (widget.upgrader.state.debugLogging) {
      print('upgrader: button tapped: ignore');
    }

    // If this callback has been provided, call it.
    final doProcess = widget.onIgnore?.call() ?? true;

    if (doProcess) {
      widget.upgrader.saveIgnored();
    }

    if (shouldPop) {
      popNavigator(context);
    }
  }

  void onUserLater(BuildContext context, bool shouldPop) {
    if (widget.upgrader.state.debugLogging) {
      print('upgrader: button tapped: later');
    }

    // If this callback has been provided, call it.
    widget.onLater?.call();

    if (shouldPop) {
      popNavigator(context);
    }
  }

  void onUserUpdated(BuildContext context, bool shouldPop) {
    if (widget.upgrader.state.debugLogging) {
      print('upgrader: button tapped: update now');
    }

    // If this callback has been provided, call it.
    final doProcess = widget.onUpdate?.call() ?? true;

    if (doProcess) {
      widget.upgrader.sendUserToAppStore();
    }

    if (shouldPop) {
      popNavigator(context);
    }
  }

  void popNavigator(BuildContext context) {
    Navigator.of(context).pop();
    displayed = false;
  }

  bool get shouldDisplayReleaseNotes =>
      widget.showReleaseNotes &&
      (widget.upgrader.releaseNotes?.isNotEmpty ?? false);

  /// Show the alert dialog.
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
    Widget? icon,
    Color? dialogBackgroundColor,
    Color? textColor,
    List<Color>? buttonColor,
    Color? buttonTextColor,
    bool? isFullScreen,
    Widget? releaseNotesWidget,
  }) {
    if (widget.upgrader.state.debugLogging) {
      print('upgrader: showTheDialog title: $title');
      print('upgrader: showTheDialog message: $message');
      print('upgrader: showTheDialog releaseNotes: $releaseNotes');
    }

    if (!context.mounted) {
      if (widget.upgrader.state.debugLogging) {
        print('upgrader: showTheDialog context not mounted - dialog not shown');
      }
      return;
    }

    // Save the date/time as the last time alerted.
    widget.upgrader.saveLastAlerted();

    // Detect if CupertinoApp is in the widget tree
    final isCupertinoApp =
        context.findAncestorWidgetOfExactType<CupertinoApp>() != null;

    dialogBuilder(BuildContext context) => PopScope(
          canPop: onCanPop(),
          onPopInvokedWithResult: (didPop, result) {
            if (widget.upgrader.state.debugLogging) {
              print('upgrader: showTheDialog onPopInvoked: $didPop');
            }
          },
          child: alertDialog(
            key,
            title ?? '',
            message,
            releaseNotes,
            context,
            widget.dialogStyle == UpgradeDialogStyle.cupertino,
            messages,
            icon: icon,
            dialogBackgroundColor: dialogBackgroundColor,
            textColor: textColor,
            buttonColor: buttonColor,
            buttonTextColor: buttonTextColor,
            isFullScreen: isFullScreen,
            releaseNotesWidget: releaseNotesWidget,
          ),
        );

    if (isCupertinoApp) {
      showCupertinoDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: dialogBuilder,
      );
    } else {
      showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: dialogBuilder,
      );
    }
  }

  /// Determines if the dialog blocks the current route from being popped.
  /// Will return the result from [shouldPopScope] if it is not null, otherwise it will return false.
  bool onCanPop() {
    if (widget.upgrader.state.debugLogging) {
      print('upgrader: onCanPop called');
    }
    if (widget.shouldPopScope != null) {
      final should = widget.shouldPopScope!();
      if (widget.upgrader.state.debugLogging) {
        print('upgrader: shouldPopScope=$should');
      }
      return should;
    }

    return false;
  }

  Widget alertDialog(
    Key? key,
    String title,
    String message,
    String? releaseNotes,
    BuildContext context,
    bool cupertino,
    UpgraderMessages messages, {
    bool? isFullScreen,
    Widget? icon,
    Color? dialogBackgroundColor,
    Color? textColor,
    List<Color>? buttonColor,
    Color? buttonTextColor,
    Widget? releaseNotesWidget,
  }) {
    // Logic kiểm tra nút bấm (Giữ nguyên logic gốc)
    final isBlocked = widget.upgrader.blocked();
    final showIgnore = isBlocked ? false : widget.showIgnore;
    final showLater = isBlocked ? false : widget.showLater;

    // Design Tokens (Modern HR Style)
    const Color primaryOrange = Color(0xFFFF6B35);
    // const Color headerLightOrange = Color(0xFFFFF4ED);
    const Color textDark = Color(0xFF191C1E);
    const Color textSecondary = Color(0xFF594139);
    const Color bgWhite = Colors.white;

    // Typography styles
    const TextStyle titleStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textDark,
      fontFamily: 'Inter',
    );
    const TextStyle contentStyle = TextStyle(
      fontSize: 14,
      color: textDark,
      fontFamily: 'Inter',
      height: 1.5,
    );
    const TextStyle releaseNoteHeaderStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: textDark,
      fontFamily: 'Inter',
    );

    // Xử lý phần Release Notes (Matching new reference image)
    Widget? notes;
    if (widget.showReleaseNotes) {
      if (releaseNotesWidget != null) {
        notes = Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: releaseNotesWidget,
        );
      } else if (releaseNotes != null) {
        final sections = ReleaseNoteParser.parse(releaseNotes);

        notes = Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE0E3E5).withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Decorative Blurred Circle
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            primaryOrange.withOpacity(0.15),
                            primaryOrange.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          (messages.message(UpgraderMessage.releaseNotesHeader) ??
                                  'WHAT\'S NEW')
                              .toUpperCase(),
                          style: releaseNoteHeaderStyle.copyWith(
                            fontSize: 12,
                            letterSpacing: 1.0,
                            color: const Color(0xFF594139),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...sections.map((section) {
                          final tagInfo =
                              _getTagInfo(section.tagType, messages);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (section.tagType != ReleaseNoteTagType.none)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(tagInfo.icon,
                                            size: 16, color: tagInfo.color),
                                        const SizedBox(width: 8),
                                        Text(
                                          '[${tagInfo.label}]',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: tagInfo.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ...section.lines.map((line) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 4.0, left: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('• ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Expanded(
                                          child: Text(
                                            line,
                                            style: contentStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: textDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    Widget child = Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                mainAxisSize:
                    isFullScreen ?? false ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  // 1. Icon Header (Exact Figma layering)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE0E3E5), // Base fill from Figma
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF6B35)
                                .withOpacity(0.2), // Stop 0%: 20% opacity
                            const Color(0xFF04A3E7)
                                .withOpacity(0.1), // Stop 100%: 10% opacity
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      child: Center(
                        child: icon ??
                            const Icon(
                              Icons.rocket_launch,
                              size: 40,
                              color: primaryOrange,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Title
                  Text(
                    title,
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // 3. Scrollable Content
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            message,
                            style: contentStyle,
                            textAlign: TextAlign.center,
                          ),
                          if (widget.showPrompt) ...[
                            const SizedBox(height: 10),
                            Text(
                              messages.message(UpgraderMessage.prompt) ?? '',
                              style: contentStyle.copyWith(
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (notes != null) notes,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Update Button
                  InkWell(
                    onTap: () =>
                        onUserUpdated(context, !widget.upgrader.blocked()),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: primaryOrange,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: primaryOrange.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        messages.message(UpgraderMessage.buttonTitleUpdate) ??
                            'UPDATE NOW',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // 5. Secondary Button (Later)
                  if (showLater)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextButton(
                        onPressed: () => onUserLater(context, true),
                        child: Text(
                          messages.message(UpgraderMessage.buttonTitleLater) ??
                              'LATER',
                          style: const TextStyle(
                              color: textSecondary,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                  // Ignore button
                  if (showIgnore && !showLater)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: () => onUserIgnored(context, true),
                        child: Text(
                          messages.message(UpgraderMessage.buttonTitleIgnore) ??
                              'IGNORE',
                          style: const TextStyle(
                              color: Colors.black38, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Close Button (X)
            if (showLater || showIgnore)
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: textSecondary, size: 18),
                  onPressed: () => onUserLater(context, true),
                ),
              ),
          ],
        ),
      ),
    );

    return isFullScreen ?? false
        ? Dialog.fullscreen(
            key: key,
            backgroundColor: Colors.transparent,
            child: child,
          )
        : Dialog(
            key: key,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: child,
          );
  }

  Widget button({
    required bool cupertino,
    String? text,
    required BuildContext context,
    VoidCallback? onPressed,
    bool isDefaultAction = false,
  }) {
    return cupertino
        ? CupertinoDialogAction(
            textStyle: widget.cupertinoButtonTextStyle,
            onPressed: onPressed,
            isDefaultAction: isDefaultAction,
            child: Text(text ?? ''))
        : TextButton(onPressed: onPressed, child: Text(text ?? ''));
  }

  _TagInfo _getTagInfo(ReleaseNoteTagType type, UpgraderMessages messages) {
    switch (type) {
      case ReleaseNoteTagType.newFeature:
        return _TagInfo(
          label: messages.message(UpgraderMessage.tagNew) ?? 'Mới',
          icon: Icons.rocket_launch,
          color: const Color(0xFFFF6B35),
        );
      case ReleaseNoteTagType.optimize:
        return _TagInfo(
          label: messages.message(UpgraderMessage.tagOptimize) ?? 'Tối ưu',
          icon: Icons.bolt,
          color: const Color(0xFF04A3E7),
        );
      case ReleaseNoteTagType.fix:
        return _TagInfo(
          label: messages.message(UpgraderMessage.tagFix) ?? 'Sửa lỗi',
          icon: Icons.build,
          color: Colors.grey,
        );
      case ReleaseNoteTagType.security:
        return _TagInfo(
          label: messages.message(UpgraderMessage.tagSecurity) ?? 'Bảo mật',
          icon: Icons.lock,
          color: Colors.green,
        );
      case ReleaseNoteTagType.none:
        return _TagInfo(label: '', icon: Icons.info, color: Colors.black);
    }
  }
}

class _TagInfo {
  final String label;
  final IconData icon;
  final Color color;

  _TagInfo({required this.label, required this.icon, required this.color});
}

enum ReleaseNoteTagType { newFeature, optimize, fix, security, none }

class ReleaseNoteSection {
  final ReleaseNoteTagType tagType;
  final List<String> lines;

  ReleaseNoteSection({required this.tagType, required this.lines});
}

class ReleaseNoteParser {
  static List<ReleaseNoteSection> parse(String text) {
    final sections = <ReleaseNoteSection>[];
    final lines = text.split('\n');

    ReleaseNoteTagType currentTag = ReleaseNoteTagType.none;
    List<String> currentLines = [];

    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;

      final tagMatch = RegExp(r'^\[(.+?)\]').firstMatch(trimmedLine);
      if (tagMatch != null) {
        if (currentLines.isNotEmpty || currentTag != ReleaseNoteTagType.none) {
          sections.add(
              ReleaseNoteSection(tagType: currentTag, lines: currentLines));
        }

        final tagText = tagMatch.group(1)!.toLowerCase();
        currentTag = _parseTagType(tagText);
        currentLines = [];

        // Nếu dòng có nội dung sau tag, thêm vào lines
        final content = trimmedLine
            .replaceFirst(RegExp(r'^\[.+?\]'), '')
            .replaceFirst(RegExp(r'^[-•*]\s*'), '')
            .trim();
        if (content.isNotEmpty) {
          currentLines.add(content);
        }
      } else {
        currentLines.add(trimmedLine.replaceFirst(RegExp(r'^[-•*]\s*'), '').trim());
      }
    }

    if (currentLines.isNotEmpty || currentTag != ReleaseNoteTagType.none) {
      sections.add(ReleaseNoteSection(tagType: currentTag, lines: currentLines));
    }

    return sections;
  }

  static ReleaseNoteTagType _parseTagType(String tag) {
    if (tag.contains('mới') ||
        tag.contains('bổ sung') ||
        tag.contains('new') ||
        tag.contains('added')) {
      return ReleaseNoteTagType.newFeature;
    }
    if (tag.contains('tối ưu') ||
        tag.contains('cải thiện') ||
        tag.contains('optimize') ||
        tag.contains('improve')) {
      return ReleaseNoteTagType.optimize;
    }
    if (tag.contains('sửa lỗi') ||
        tag.contains('khắc phục') ||
        tag.contains('fix') ||
        tag.contains('bug')) {
      return ReleaseNoteTagType.fix;
    }
    if (tag.contains('bảo mật') || tag.contains('security')) {
      return ReleaseNoteTagType.security;
    }
    return ReleaseNoteTagType.none;
  }
}
