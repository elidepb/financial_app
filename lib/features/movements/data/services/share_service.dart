import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareText({
    required String content,
    String? subject,
  }) async {
    await Share.share(
      content,
      subject: subject,
    );
  }
}

