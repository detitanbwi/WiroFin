import 'package:get_it/get_it.dart';
import '../config/app_config.dart';
import '../../services/database_helper.dart';
import '../../services/sync_service.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/offline_expense_repository_impl.dart';
import '../../data/repositories/hybrid_expense_repository_impl.dart';

final getIt = GetIt.instance;

void setupInjection() {
  // Database Helper as Singleton
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // Repository Selection
  if (AppConfig.instance.isOfflineMode) {
    getIt.registerLazySingleton<ExpenseRepository>(
      () => OfflineExpenseRepositoryImpl(getIt<DatabaseHelper>()),
    );
  } else {
    // Sync Service as Singleton (Only needed if not offline)
    getIt.registerLazySingleton<SyncService>(() => SyncService.instance);
    
    getIt.registerLazySingleton<ExpenseRepository>(
      () => HybridExpenseRepositoryImpl(getIt<DatabaseHelper>(), getIt<SyncService>()),
    );
  }
}
