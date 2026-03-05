import 'package:freezed_annotation/freezed_annotation.dart';

part 'list_me_sessions_request_entity.freezed.dart';

@freezed
abstract class ListMeSessionsRequestEntity with _$ListMeSessionsRequestEntity {
  const factory ListMeSessionsRequestEntity({
    int? limit,
    String? cursor,
    String? sort,
  }) = _ListMeSessionsRequestEntity;
}
