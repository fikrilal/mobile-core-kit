import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';

sealed class RequestAccountDeletionEffect {
  const RequestAccountDeletionEffect();
}

class ShowRequestAccountDeletionFailure extends RequestAccountDeletionEffect {
  const ShowRequestAccountDeletionFailure(this.failure);

  final AuthFailure failure;
}

class ShowAccountDeletionRequested extends RequestAccountDeletionEffect {
  const ShowAccountDeletionRequested();
}

class ShowAccountDeletionCanceled extends RequestAccountDeletionEffect {
  const ShowAccountDeletionCanceled();
}
