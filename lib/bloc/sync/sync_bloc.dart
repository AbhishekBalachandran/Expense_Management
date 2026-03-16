import 'package:expense_manager/data/local/category_database.dart';
import 'package:expense_manager/data/local/transaction_database.dart';
import 'package:expense_manager/data/remote/category_remote_source.dart';
import 'package:expense_manager/data/remote/transaction_remote_source.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required TransactionDatabase transDb,
    required CategoryDatabase categoryDb,
    required TransactionRemoteSource transactionRemoteSource,
    required CategoryRemoteSource categoryRemoteSource,
  }) : transDB = transDb,
       catDB = categoryDb,
       trRemote = transactionRemoteSource,
       catRemote = categoryRemoteSource,
       super(SyncInitial()) {
    on<SyncStartEvent>(_onSyncStart);
  }

  final TransactionDatabase transDB;
  final CategoryDatabase catDB;
  final TransactionRemoteSource trRemote;
  final CategoryRemoteSource catRemote;

  Future<void> _onSyncStart(
    SyncStartEvent event,
    Emitter<SyncState> emit,
  ) async {
    emit(SyncInProgress(message: 'Syncing...'));

    try {
      emit(SyncInProgress(message: 'Cleaning up transactions...'));
      final deletedTrans = await transDB.getPendingDeletion();
      if (deletedTrans.isNotEmpty) {
        final ids = deletedTrans.map((t) => t.id).toList();
        final confirmedIds = await trRemote.deleteTransactions(ids);
        // deleting completely only after api confirmation

        for (final id in confirmedIds) {
          await transDB.completeDelete(id);
        }
      }

      // delete categories remote
      emit(SyncInProgress(message: 'Cleaning up categories...'));
      final deletedCats = await catDB.getPendingDeletion();
      if (deletedCats.isNotEmpty) {
        final ids = deletedCats.map((c) => c.id).toList();
        final confirmedIds = await catRemote.deleteCategories(ids);
        for (final id in confirmedIds) {
          await catDB.completeDelete(id);
        }
      }

      // category syncing
      emit(SyncInProgress(message: 'Syncing categories...'));
      final unsyncedCats = await catDB.getPendingSync();
      if (unsyncedCats.isNotEmpty) {
        final syncedIds = await catRemote.addCategories(unsyncedCats);
        await catDB.markSynced(syncedIds);
      }

      // transaction sync
      emit(SyncInProgress(message: 'Syncing transactions...'));
      final unsyncedTxs = await transDB.getPendingSync();
      if (unsyncedTxs.isNotEmpty) {
        final syncedIds = await trRemote.addTransactions(unsyncedTxs);
        await transDB.markSynced(syncedIds);
      }

      emit(SyncSuccess());
    } catch (e) {
      emit(SyncFailure(message: e.toString()));
    }
  }
}
