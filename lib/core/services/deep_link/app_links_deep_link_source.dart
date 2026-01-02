import 'package:app_links/app_links.dart';

import 'deep_link_source.dart';

class AppLinksDeepLinkSource implements DeepLinkSource {
  AppLinksDeepLinkSource({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  @override
  Future<Uri?> getInitialUri() => _appLinks.getInitialLink();

  @override
  Stream<Uri> get uriStream => _appLinks.uriLinkStream;
}

