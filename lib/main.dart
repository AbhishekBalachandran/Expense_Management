import 'package:expense_manager/bloc/auth/auth_bloc.dart';
import 'package:expense_manager/bloc/home/home_bloc.dart';
import 'package:expense_manager/bloc/sync/sync_bloc.dart';
import 'package:expense_manager/core/network/dio_service.dart';
import 'package:expense_manager/core/router/app_router.dart';
import 'package:expense_manager/core/storage/prefs_service.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:expense_manager/data/local/category_database.dart';
import 'package:expense_manager/data/local/database_helper.dart';
import 'package:expense_manager/data/local/transaction_database.dart';
import 'package:expense_manager/data/remote/auth_remote_source.dart';
import 'package:expense_manager/data/remote/category_remote_source.dart';
import 'package:expense_manager/data/remote/transaction_remote_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // initialize shared preferences
  final sharedPrefs = await SharedPreferences.getInstance();
  final prefsService = PrefsService(prefs: sharedPrefs);

  runApp(ExpenseManagerApp(prefsService: prefsService));
}

class ExpenseManagerApp extends StatelessWidget {
  final PrefsService prefsService;
  const ExpenseManagerApp({super.key, required this.prefsService});

  @override
  Widget build(BuildContext context) {
    final dioService = DioService(prefsService);
    final authRemoteSource = AuthRemoteSource(dioService: dioService);
    final dbHelper = DatabaseHelper.instance;
    final categoryDatabase = CategoryDatabase(dbHelper: dbHelper);
    final transDB = TransactionDatabase(dbHelper: dbHelper);
    final transRemote = TransactionRemoteSource(dioService: dioService);
    final catRemote = CategoryRemoteSource(dioService: dioService);
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => prefsService),
        RepositoryProvider<DatabaseHelper>(create: (_) => dbHelper),
        RepositoryProvider(create: (context) => categoryDatabase),
        RepositoryProvider(create: (context) => prefsService),
        RepositoryProvider<TransactionDatabase>(create: (_) => transDB),
        RepositoryProvider<TransactionRemoteSource>(create: (_) => transRemote),
        RepositoryProvider<CategoryRemoteSource>(create: (_) => catRemote),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              authRemoteSource: authRemoteSource,
              prefsService: prefsService,
            ),
          ),
          BlocProvider<HomeBloc>(
            create: (_) => HomeBloc(
              transactionDatabase: transDB,
              categoryDatabase: categoryDatabase,
            ),
          ),
          BlocProvider<SyncBloc>(
            create: (_) => SyncBloc(
              transDb: transDB,
              categoryDb: categoryDatabase,
              transactionRemoteSource: transRemote,
              categoryRemoteSource: catRemote,
            ),
          ),
        ],
        child: MaterialApp.router(
          title: "Expense Manager",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          routerConfig: AppRouter.generateRouter(prefsService),
        ),
      ),
    );
  }
}
