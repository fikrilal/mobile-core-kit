import 'package:flutter/widgets.dart';

const appSearchExperienceContainerKey = Key('app_search_experience_container');
const appSearchExperienceBarKey = Key('app_search_experience_bar');
const appSearchExperienceClearButtonKey = Key('app_search_experience_clear');
const appSearchExperienceClearHistoryKey = Key(
  'app_search_experience_clear_history',
);
const appSearchExperiencePanelKey = Key('app_search_experience_panel');
const appSearchExperiencePanelListKey = Key('app_search_experience_panel_list');

Key appSearchExperienceHistoryItemKey(String value) {
  return Key('app_search_experience_history_$value');
}

Key appSearchExperienceSuggestionItemKey(String label) {
  return Key('app_search_experience_suggestion_$label');
}
