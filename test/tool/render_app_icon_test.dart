import 'dart:io';
import 'dart:ui' as ui;

import 'package:bloom_app/theme/app_colors.dart';
import 'package:bloom_app/widgets/bloom_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Generates launcher PNGs from the in-app lotus mark.
///
/// flutter test test/tool/render_app_icon_test.dart --dart-define=GENERATE_ICONS=true
void main() {
  const generate = bool.fromEnvironment('GENERATE_ICONS');

  testWidgets('render Bloom launcher icons', (tester) async {
    final branding = Directory('assets/branding');
    if (!branding.existsSync()) {
      branding.createSync(recursive: true);
    }

    tester.view.physicalSize = const Size(1024, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _writeIcon(
      tester,
      path: 'assets/branding/app_icon.png',
      background: const _IconBackdrop(),
      markSize: 620,
      fillOpacity: 0.18,
    );

    await _writeIcon(
      tester,
      path: 'assets/branding/app_icon_foreground.png',
      background: const ColoredBox(color: Colors.transparent),
      markSize: 560,
      fillOpacity: 0,
    );
  }, skip: !generate);
}

Future<void> _writeIcon(
  WidgetTester tester, {
  required String path,
  required Widget background,
  required double markSize,
  required double fillOpacity,
}) async {
  final key = GlobalKey();

  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          fit: StackFit.expand,
          children: [
            background,
            Center(
              child: BloomMark(
                size: markSize,
                strokeWidthFactor: 1.65,
                fillOpacity: fillOpacity,
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pump();

  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

class _IconBackdrop extends StatelessWidget {
  const _IconBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, 0.08),
          radius: 0.78,
          colors: [
            AppColors.blush,
            AppColors.cream,
          ],
        ),
      ),
    );
  }
}
