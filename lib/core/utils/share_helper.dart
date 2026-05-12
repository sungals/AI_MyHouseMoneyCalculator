import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  ShareHelper._();

  static Future<ShareResult> shareText(
    BuildContext context, {
    required String text,
    String? subject,
    String? title,
  }) {
    return Share.share(
      text,
      subject: subject ?? title,
      sharePositionOrigin: _shareOrigin(context),
    );
  }

  static Future<ShareResult> shareFiles(
    BuildContext context, {
    required List<XFile> files,
    String? text,
    String? subject,
    String? title,
  }) {
    return Share.shareXFiles(
      files,
      text: text,
      subject: subject ?? title,
      sharePositionOrigin: _shareOrigin(context),
    );
  }

  static Rect _shareOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    final overlayRenderObject =
        Navigator.maybeOf(context)?.overlay?.context.findRenderObject();

    if (renderObject is RenderBox &&
        overlayRenderObject is RenderBox &&
        renderObject.hasSize &&
        overlayRenderObject.hasSize) {
      return MatrixUtils.transformRect(
        renderObject.getTransformTo(overlayRenderObject),
        Offset.zero & renderObject.size,
      );
    }

    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }
}
