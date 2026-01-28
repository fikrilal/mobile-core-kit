import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile_core_kit/features/auth/domain/failure/auth_failure.dart';

part 'profile_image_state.freezed.dart';

enum ProfileImageStatus { initial, loading, success, failure }

enum ProfileImageAction { none, upload, clear, loadUrl }

@freezed
abstract class ProfileImageState with _$ProfileImageState {
  const factory ProfileImageState({
    @Default(ProfileImageStatus.initial) ProfileImageStatus status,
    @Default(ProfileImageAction.none) ProfileImageAction action,
    String? imageUrl,
    AuthFailure? failure,
  }) = _ProfileImageState;

  const ProfileImageState._();

  bool get isLoading => status == ProfileImageStatus.loading;

  bool get isUploading => isLoading && action == ProfileImageAction.upload;

  bool get isClearing => isLoading && action == ProfileImageAction.clear;

  bool get isLoadingUrl => isLoading && action == ProfileImageAction.loadUrl;

  factory ProfileImageState.initial() => const ProfileImageState();
}
