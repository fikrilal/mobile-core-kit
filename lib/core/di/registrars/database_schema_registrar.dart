import 'package:get_it/get_it.dart';
import 'package:mobile_core_kit/features/account/di/account_database_schema.dart';

void registerDatabaseSchema(GetIt locator) {
  AccountDatabaseSchema.register();
}
