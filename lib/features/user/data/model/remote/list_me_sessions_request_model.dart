import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/user/domain/entity/list_me_sessions_request_entity.dart';

part 'list_me_sessions_request_model.freezed.dart';

/// Request metadata for `GET /v1/me/sessions`.
@freezed
abstract class ListMeSessionsRequestModel with _$ListMeSessionsRequestModel {
  const factory ListMeSessionsRequestModel({
    int? limit,
    String? cursor,
    String? sort,
  }) = _ListMeSessionsRequestModel;

  const ListMeSessionsRequestModel._();

  Map<String, dynamic> toQueryParameters() {
    return <String, dynamic>{
      if (limit != null) 'limit': limit,
      if (cursor != null && cursor!.trim().isNotEmpty) 'cursor': cursor,
      if (sort != null && sort!.trim().isNotEmpty) 'sort': sort,
    };
  }
}

extension ListMeSessionsRequestEntityX on ListMeSessionsRequestEntity {
  ListMeSessionsRequestModel toModel() {
    return ListMeSessionsRequestModel(limit: limit, cursor: cursor, sort: sort);
  }
}
