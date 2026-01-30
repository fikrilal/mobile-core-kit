import 'dart:typed_data';

import 'package:mobile_core_kit/core/infra/network/download/presigned_download_client.dart';

/// Feature-level wrapper around [PresignedDownloadClient] for downloading the
/// profile avatar bytes from a presigned render URL.
///
/// This file intentionally does not depend on Dio directly (see `restricted_imports`).
class ProfileAvatarDownloadDataSource {
  ProfileAvatarDownloadDataSource(this._download);

  final PresignedDownloadClient _download;

  Future<Uint8List> downloadBytes({required String url}) async {
    final normalized = url.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(url, 'url', 'URL cannot be empty');
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      throw ArgumentError.value(url, 'url', 'Invalid URL');
    }

    return _download.downloadBytes(uri);
  }
}
