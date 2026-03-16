part of 'sync_bloc.dart';

abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncInProgress extends SyncState {
  SyncInProgress({required this.message});
  final String message;
}

class SyncSuccess extends SyncState {}

class SyncFailure extends SyncState {
  SyncFailure({required this.message});
  final String message;
}
