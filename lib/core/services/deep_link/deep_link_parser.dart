import 'package:mobile_core_kit/navigation/app_routes.dart';

/// Parses and validates external deep links (e.g. HTTPS universal links) into
/// internal GoRouter locations.
///
/// safety goals:
/// - Only allow a strict set of hosts.
/// - Only allow an explicit allowlist of internal destinations.
/// - Normalize paths to avoid duplicates (`/home/` -> `/home`).
class DeepLinkParser {
  DeepLinkParser({
    Set<String> allowedHosts = const {'orymu.com'},
    Set<String> allowedPaths = const {AppRoutes.home, AppRoutes.profile},
  }) : _allowedHosts = allowedHosts,
       _allowedPaths = allowedPaths;

  final Set<String> _allowedHosts;
  final Set<String> _allowedPaths;

  bool isAllowedExternalUri(Uri uri) {
    if (uri.scheme != 'https') return false;
    final host = uri.host.toLowerCase();
    if (!_allowedHosts.contains(host)) return false;
    final path = _normalizePath(uri.path);
    return _allowedPaths.contains(path);
  }

  /// Converts an allowed external HTTPS deep link into an internal location.
  ///
  /// Returns null when:
  /// - the URI is not HTTPS,
  /// - the host is not allowlisted,
  /// - the path is not allowlisted.
  String? parseExternalUri(Uri uri) {
    if (!isAllowedExternalUri(uri)) return null;

    final path = _normalizePath(uri.path);
    final query = uri.query;
    if (query.isEmpty) return path;
    return '$path?$query';
  }

  /// Returns whether the internal GoRouter location is allowlisted.
  ///
  /// This validates the path only and ignores query parameters.
  bool isAllowedInternalLocation(String location) {
    final uri = Uri.parse(location);
    final path = _normalizePath(uri.path);
    return _allowedPaths.contains(path);
  }

  static String _normalizePath(String path) {
    if (path.isEmpty) return AppRoutes.root;
    if (path == AppRoutes.root) return AppRoutes.root;
    if (path.endsWith('/')) return path.substring(0, path.length - 1);
    return path;
  }
}
