import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_core_kit/core/di/service_locator.dart';
import 'package:mobile_core_kit/features/user/presentation/cubit/complete_profile/complete_profile_cubit.dart';
import 'package:mobile_core_kit/features/user/presentation/pages/complete_profile_page.dart';
import 'package:mobile_core_kit/navigation/user/user_routes.dart';

final List<GoRoute> userRoutes = [
  GoRoute(
    path: UserRoutes.completeProfile,
    name: 'complete-profile',
    builder: (context, state) => BlocProvider<CompleteProfileCubit>(
      create: (_) => locator<CompleteProfileCubit>()..loadDraft(),
      child: const CompleteProfilePage(),
    ),
  ),
];
