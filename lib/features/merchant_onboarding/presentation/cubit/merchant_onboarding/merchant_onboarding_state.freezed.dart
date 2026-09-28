// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merchant_onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MerchantOnboardingState {

 MerchantOnboardingStep get step; MerchantReferenceStatus get referenceStatus; MerchantReferenceDataEntity? get referenceData; MerchantOnboardingInput get input; Set<String> get touchedPaths; Set<MerchantOnboardingStep> get attemptedSteps; List<MerchantValidationFailure> get localFailures; MerchantSubmissionStatus get submissionStatus; MerchantOnboardingFailure? get submissionFailure; String? get submittedApplicationId; bool get isMateriallyEdited;
/// Create a copy of MerchantOnboardingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MerchantOnboardingStateCopyWith<MerchantOnboardingState> get copyWith => _$MerchantOnboardingStateCopyWithImpl<MerchantOnboardingState>(this as MerchantOnboardingState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MerchantOnboardingState&&(identical(other.step, step) || other.step == step)&&(identical(other.referenceStatus, referenceStatus) || other.referenceStatus == referenceStatus)&&(identical(other.referenceData, referenceData) || other.referenceData == referenceData)&&(identical(other.input, input) || other.input == input)&&const DeepCollectionEquality().equals(other.touchedPaths, touchedPaths)&&const DeepCollectionEquality().equals(other.attemptedSteps, attemptedSteps)&&const DeepCollectionEquality().equals(other.localFailures, localFailures)&&(identical(other.submissionStatus, submissionStatus) || other.submissionStatus == submissionStatus)&&(identical(other.submissionFailure, submissionFailure) || other.submissionFailure == submissionFailure)&&(identical(other.submittedApplicationId, submittedApplicationId) || other.submittedApplicationId == submittedApplicationId)&&(identical(other.isMateriallyEdited, isMateriallyEdited) || other.isMateriallyEdited == isMateriallyEdited));
}


@override
int get hashCode => Object.hash(runtimeType,step,referenceStatus,referenceData,input,const DeepCollectionEquality().hash(touchedPaths),const DeepCollectionEquality().hash(attemptedSteps),const DeepCollectionEquality().hash(localFailures),submissionStatus,submissionFailure,submittedApplicationId,isMateriallyEdited);

@override
String toString() {
  return 'MerchantOnboardingState(step: $step, referenceStatus: $referenceStatus, referenceData: $referenceData, input: $input, touchedPaths: $touchedPaths, attemptedSteps: $attemptedSteps, localFailures: $localFailures, submissionStatus: $submissionStatus, submissionFailure: $submissionFailure, submittedApplicationId: $submittedApplicationId, isMateriallyEdited: $isMateriallyEdited)';
}


}

/// @nodoc
abstract mixin class $MerchantOnboardingStateCopyWith<$Res>  {
  factory $MerchantOnboardingStateCopyWith(MerchantOnboardingState value, $Res Function(MerchantOnboardingState) _then) = _$MerchantOnboardingStateCopyWithImpl;
@useResult
$Res call({
 MerchantOnboardingStep step, MerchantReferenceStatus referenceStatus, MerchantReferenceDataEntity? referenceData, MerchantOnboardingInput input, Set<String> touchedPaths, Set<MerchantOnboardingStep> attemptedSteps, List<MerchantValidationFailure> localFailures, MerchantSubmissionStatus submissionStatus, MerchantOnboardingFailure? submissionFailure, String? submittedApplicationId, bool isMateriallyEdited
});


$MerchantReferenceDataEntityCopyWith<$Res>? get referenceData;

}
/// @nodoc
class _$MerchantOnboardingStateCopyWithImpl<$Res>
    implements $MerchantOnboardingStateCopyWith<$Res> {
  _$MerchantOnboardingStateCopyWithImpl(this._self, this._then);

  final MerchantOnboardingState _self;
  final $Res Function(MerchantOnboardingState) _then;

/// Create a copy of MerchantOnboardingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? referenceStatus = null,Object? referenceData = freezed,Object? input = null,Object? touchedPaths = null,Object? attemptedSteps = null,Object? localFailures = null,Object? submissionStatus = null,Object? submissionFailure = freezed,Object? submittedApplicationId = freezed,Object? isMateriallyEdited = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as MerchantOnboardingStep,referenceStatus: null == referenceStatus ? _self.referenceStatus : referenceStatus // ignore: cast_nullable_to_non_nullable
as MerchantReferenceStatus,referenceData: freezed == referenceData ? _self.referenceData : referenceData // ignore: cast_nullable_to_non_nullable
as MerchantReferenceDataEntity?,input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as MerchantOnboardingInput,touchedPaths: null == touchedPaths ? _self.touchedPaths : touchedPaths // ignore: cast_nullable_to_non_nullable
as Set<String>,attemptedSteps: null == attemptedSteps ? _self.attemptedSteps : attemptedSteps // ignore: cast_nullable_to_non_nullable
as Set<MerchantOnboardingStep>,localFailures: null == localFailures ? _self.localFailures : localFailures // ignore: cast_nullable_to_non_nullable
as List<MerchantValidationFailure>,submissionStatus: null == submissionStatus ? _self.submissionStatus : submissionStatus // ignore: cast_nullable_to_non_nullable
as MerchantSubmissionStatus,submissionFailure: freezed == submissionFailure ? _self.submissionFailure : submissionFailure // ignore: cast_nullable_to_non_nullable
as MerchantOnboardingFailure?,submittedApplicationId: freezed == submittedApplicationId ? _self.submittedApplicationId : submittedApplicationId // ignore: cast_nullable_to_non_nullable
as String?,isMateriallyEdited: null == isMateriallyEdited ? _self.isMateriallyEdited : isMateriallyEdited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of MerchantOnboardingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantReferenceDataEntityCopyWith<$Res>? get referenceData {
    if (_self.referenceData == null) {
    return null;
  }

  return $MerchantReferenceDataEntityCopyWith<$Res>(_self.referenceData!, (value) {
    return _then(_self.copyWith(referenceData: value));
  });
}
}


/// Adds pattern-matching-related methods to [MerchantOnboardingState].
extension MerchantOnboardingStatePatterns on MerchantOnboardingState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MerchantOnboardingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MerchantOnboardingState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MerchantOnboardingState value)  $default,){
final _that = this;
switch (_that) {
case _MerchantOnboardingState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MerchantOnboardingState value)?  $default,){
final _that = this;
switch (_that) {
case _MerchantOnboardingState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MerchantOnboardingStep step,  MerchantReferenceStatus referenceStatus,  MerchantReferenceDataEntity? referenceData,  MerchantOnboardingInput input,  Set<String> touchedPaths,  Set<MerchantOnboardingStep> attemptedSteps,  List<MerchantValidationFailure> localFailures,  MerchantSubmissionStatus submissionStatus,  MerchantOnboardingFailure? submissionFailure,  String? submittedApplicationId,  bool isMateriallyEdited)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MerchantOnboardingState() when $default != null:
return $default(_that.step,_that.referenceStatus,_that.referenceData,_that.input,_that.touchedPaths,_that.attemptedSteps,_that.localFailures,_that.submissionStatus,_that.submissionFailure,_that.submittedApplicationId,_that.isMateriallyEdited);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MerchantOnboardingStep step,  MerchantReferenceStatus referenceStatus,  MerchantReferenceDataEntity? referenceData,  MerchantOnboardingInput input,  Set<String> touchedPaths,  Set<MerchantOnboardingStep> attemptedSteps,  List<MerchantValidationFailure> localFailures,  MerchantSubmissionStatus submissionStatus,  MerchantOnboardingFailure? submissionFailure,  String? submittedApplicationId,  bool isMateriallyEdited)  $default,) {final _that = this;
switch (_that) {
case _MerchantOnboardingState():
return $default(_that.step,_that.referenceStatus,_that.referenceData,_that.input,_that.touchedPaths,_that.attemptedSteps,_that.localFailures,_that.submissionStatus,_that.submissionFailure,_that.submittedApplicationId,_that.isMateriallyEdited);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MerchantOnboardingStep step,  MerchantReferenceStatus referenceStatus,  MerchantReferenceDataEntity? referenceData,  MerchantOnboardingInput input,  Set<String> touchedPaths,  Set<MerchantOnboardingStep> attemptedSteps,  List<MerchantValidationFailure> localFailures,  MerchantSubmissionStatus submissionStatus,  MerchantOnboardingFailure? submissionFailure,  String? submittedApplicationId,  bool isMateriallyEdited)?  $default,) {final _that = this;
switch (_that) {
case _MerchantOnboardingState() when $default != null:
return $default(_that.step,_that.referenceStatus,_that.referenceData,_that.input,_that.touchedPaths,_that.attemptedSteps,_that.localFailures,_that.submissionStatus,_that.submissionFailure,_that.submittedApplicationId,_that.isMateriallyEdited);case _:
  return null;

}
}

}

/// @nodoc


class _MerchantOnboardingState implements MerchantOnboardingState {
  const _MerchantOnboardingState({this.step = MerchantOnboardingStep.business, this.referenceStatus = MerchantReferenceStatus.loading, this.referenceData, required this.input, final  Set<String> touchedPaths = const <String>{}, final  Set<MerchantOnboardingStep> attemptedSteps = const <MerchantOnboardingStep>{}, final  List<MerchantValidationFailure> localFailures = const <MerchantValidationFailure>[], this.submissionStatus = MerchantSubmissionStatus.idle, this.submissionFailure, this.submittedApplicationId, this.isMateriallyEdited = false}): _touchedPaths = touchedPaths,_attemptedSteps = attemptedSteps,_localFailures = localFailures;
  

@override@JsonKey() final  MerchantOnboardingStep step;
@override@JsonKey() final  MerchantReferenceStatus referenceStatus;
@override final  MerchantReferenceDataEntity? referenceData;
@override final  MerchantOnboardingInput input;
 final  Set<String> _touchedPaths;
@override@JsonKey() Set<String> get touchedPaths {
  if (_touchedPaths is EqualUnmodifiableSetView) return _touchedPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_touchedPaths);
}

 final  Set<MerchantOnboardingStep> _attemptedSteps;
@override@JsonKey() Set<MerchantOnboardingStep> get attemptedSteps {
  if (_attemptedSteps is EqualUnmodifiableSetView) return _attemptedSteps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_attemptedSteps);
}

 final  List<MerchantValidationFailure> _localFailures;
@override@JsonKey() List<MerchantValidationFailure> get localFailures {
  if (_localFailures is EqualUnmodifiableListView) return _localFailures;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_localFailures);
}

@override@JsonKey() final  MerchantSubmissionStatus submissionStatus;
@override final  MerchantOnboardingFailure? submissionFailure;
@override final  String? submittedApplicationId;
@override@JsonKey() final  bool isMateriallyEdited;

/// Create a copy of MerchantOnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MerchantOnboardingStateCopyWith<_MerchantOnboardingState> get copyWith => __$MerchantOnboardingStateCopyWithImpl<_MerchantOnboardingState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MerchantOnboardingState&&(identical(other.step, step) || other.step == step)&&(identical(other.referenceStatus, referenceStatus) || other.referenceStatus == referenceStatus)&&(identical(other.referenceData, referenceData) || other.referenceData == referenceData)&&(identical(other.input, input) || other.input == input)&&const DeepCollectionEquality().equals(other._touchedPaths, _touchedPaths)&&const DeepCollectionEquality().equals(other._attemptedSteps, _attemptedSteps)&&const DeepCollectionEquality().equals(other._localFailures, _localFailures)&&(identical(other.submissionStatus, submissionStatus) || other.submissionStatus == submissionStatus)&&(identical(other.submissionFailure, submissionFailure) || other.submissionFailure == submissionFailure)&&(identical(other.submittedApplicationId, submittedApplicationId) || other.submittedApplicationId == submittedApplicationId)&&(identical(other.isMateriallyEdited, isMateriallyEdited) || other.isMateriallyEdited == isMateriallyEdited));
}


@override
int get hashCode => Object.hash(runtimeType,step,referenceStatus,referenceData,input,const DeepCollectionEquality().hash(_touchedPaths),const DeepCollectionEquality().hash(_attemptedSteps),const DeepCollectionEquality().hash(_localFailures),submissionStatus,submissionFailure,submittedApplicationId,isMateriallyEdited);

@override
String toString() {
  return 'MerchantOnboardingState(step: $step, referenceStatus: $referenceStatus, referenceData: $referenceData, input: $input, touchedPaths: $touchedPaths, attemptedSteps: $attemptedSteps, localFailures: $localFailures, submissionStatus: $submissionStatus, submissionFailure: $submissionFailure, submittedApplicationId: $submittedApplicationId, isMateriallyEdited: $isMateriallyEdited)';
}


}

/// @nodoc
abstract mixin class _$MerchantOnboardingStateCopyWith<$Res> implements $MerchantOnboardingStateCopyWith<$Res> {
  factory _$MerchantOnboardingStateCopyWith(_MerchantOnboardingState value, $Res Function(_MerchantOnboardingState) _then) = __$MerchantOnboardingStateCopyWithImpl;
@override @useResult
$Res call({
 MerchantOnboardingStep step, MerchantReferenceStatus referenceStatus, MerchantReferenceDataEntity? referenceData, MerchantOnboardingInput input, Set<String> touchedPaths, Set<MerchantOnboardingStep> attemptedSteps, List<MerchantValidationFailure> localFailures, MerchantSubmissionStatus submissionStatus, MerchantOnboardingFailure? submissionFailure, String? submittedApplicationId, bool isMateriallyEdited
});


@override $MerchantReferenceDataEntityCopyWith<$Res>? get referenceData;

}
/// @nodoc
class __$MerchantOnboardingStateCopyWithImpl<$Res>
    implements _$MerchantOnboardingStateCopyWith<$Res> {
  __$MerchantOnboardingStateCopyWithImpl(this._self, this._then);

  final _MerchantOnboardingState _self;
  final $Res Function(_MerchantOnboardingState) _then;

/// Create a copy of MerchantOnboardingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? referenceStatus = null,Object? referenceData = freezed,Object? input = null,Object? touchedPaths = null,Object? attemptedSteps = null,Object? localFailures = null,Object? submissionStatus = null,Object? submissionFailure = freezed,Object? submittedApplicationId = freezed,Object? isMateriallyEdited = null,}) {
  return _then(_MerchantOnboardingState(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as MerchantOnboardingStep,referenceStatus: null == referenceStatus ? _self.referenceStatus : referenceStatus // ignore: cast_nullable_to_non_nullable
as MerchantReferenceStatus,referenceData: freezed == referenceData ? _self.referenceData : referenceData // ignore: cast_nullable_to_non_nullable
as MerchantReferenceDataEntity?,input: null == input ? _self.input : input // ignore: cast_nullable_to_non_nullable
as MerchantOnboardingInput,touchedPaths: null == touchedPaths ? _self._touchedPaths : touchedPaths // ignore: cast_nullable_to_non_nullable
as Set<String>,attemptedSteps: null == attemptedSteps ? _self._attemptedSteps : attemptedSteps // ignore: cast_nullable_to_non_nullable
as Set<MerchantOnboardingStep>,localFailures: null == localFailures ? _self._localFailures : localFailures // ignore: cast_nullable_to_non_nullable
as List<MerchantValidationFailure>,submissionStatus: null == submissionStatus ? _self.submissionStatus : submissionStatus // ignore: cast_nullable_to_non_nullable
as MerchantSubmissionStatus,submissionFailure: freezed == submissionFailure ? _self.submissionFailure : submissionFailure // ignore: cast_nullable_to_non_nullable
as MerchantOnboardingFailure?,submittedApplicationId: freezed == submittedApplicationId ? _self.submittedApplicationId : submittedApplicationId // ignore: cast_nullable_to_non_nullable
as String?,isMateriallyEdited: null == isMateriallyEdited ? _self.isMateriallyEdited : isMateriallyEdited // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of MerchantOnboardingState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MerchantReferenceDataEntityCopyWith<$Res>? get referenceData {
    if (_self.referenceData == null) {
    return null;
  }

  return $MerchantReferenceDataEntityCopyWith<$Res>(_self.referenceData!, (value) {
    return _then(_self.copyWith(referenceData: value));
  });
}
}

// dart format on
