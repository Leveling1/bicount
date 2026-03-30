import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/domain/entities/subscription_entity.dart';
import 'package:bicount/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc(this.repository) : super(SubscriptionInitial()) {
    on<AddSubscriptionRequested>(_onAddSubscription);
    on<UpdateSubscriptionRequested>(_onUpdateSubscription);
    on<UnsubscribeRequested>(_onUnsubscribe);
  }

  final SubscriptionRepository repository;

  Future<void> _onAddSubscription(
    AddSubscriptionRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionSaving());

    try {
      await repository.addSubscription(event.subscription);
      emit(SubscriptionSaved());
    } on MessageFailure catch (error) {
      emit(SubscriptionFailure(error.message));
    } on Failure catch (error) {
      emit(SubscriptionFailure(error.message));
    } catch (_) {
      emit(SubscriptionFailure('An unexpected error occurred.'));
    }
  }

  Future<void> _onUpdateSubscription(
    UpdateSubscriptionRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionSaving());

    try {
      await repository.updateSubscription(event.subscription);
      emit(const SubscriptionSaved(isUpdated: true));
    } on MessageFailure catch (error) {
      emit(SubscriptionFailure(error.message));
    } on Failure catch (error) {
      emit(SubscriptionFailure(error.message));
    } catch (_) {
      emit(SubscriptionFailure('An unexpected error occurred.'));
    }
  }

  Future<void> _onUnsubscribe(
    UnsubscribeRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionUnsubscribing());

    try {
      await repository.unsubscribe(event.subscription);
      emit(SubscriptionUnsubscribed());
    } on MessageFailure catch (error) {
      emit(SubscriptionFailure(error.message));
    } on Failure catch (error) {
      emit(SubscriptionFailure(error.message));
    } catch (_) {
      emit(SubscriptionFailure('An unexpected error occurred.'));
    }
  }
}
