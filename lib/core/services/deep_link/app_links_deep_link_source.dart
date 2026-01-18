import 'package:app_links/app_links.dart';

import 'package:mobile_core_kit/core/services/deep_link/deep_link_source.dart';

class AppLinksDeepLinkSource implements DeepLinkSource {
  AppLinksDeepLinkSource({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  @override
  Stream<Uri> get uriStream => _appLinks.uriLinkStream;
}
