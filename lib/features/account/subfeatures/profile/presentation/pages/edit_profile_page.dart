import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_core_kit/core/design_system/theme/typography/components/text.dart';
import 'package:mobile_core_kit/core/design_system/widgets/snackbar/snackbar.dart';
import 'package:mobile_core_kit/core/presentation/localization/auth_failure_localizer.dart';
import 'package:mobile_core_kit/core/presentation/localization/l10n.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/edit_profile/edit_profile_cubit.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_effect.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/cubit/profile_form/profile_form_state.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/presentation/widgets/profile_form.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  StreamSubscription<ProfileFormEffect>? _effectSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectSubscription ??= context.read<EditProfileCubit>().effects.listen(
      _handleEffect,
    );
  }

  void _handleEffect(ProfileFormEffect effect) {
    if (!mounted) return;

    switch (effect) {
      case ProfileFormFailureEffect(:final failure):
        AppSnackBar.showError(
          context,
          message: messageForAuthFailure(failure, context.l10n),
        );
    }
  }

  @override
  void dispose() {
    unawaited(_effectSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProfileCubit, ProfileFormState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == ProfileFormStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: Scaffold(
        appBar: AppBar(
          title: AppText.titleMedium(context.l10n.profileEditTitle),
        ),
        body: ProfileForm<EditProfileCubit>(
          submitText: context.l10n.profileSaveChanges,
          submitSemanticIdentifier: 'profile_edit_submit',
        ),
      ),
    );
  }
}
