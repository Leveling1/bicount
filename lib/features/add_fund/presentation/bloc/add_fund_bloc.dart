import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/core/errors/failure.dart';
import 'package:bicount/features/add_fund/domain/entities/add_account_funding_entity.dart';
import 'package:bicount/features/add_fund/domain/repositories/add_fund_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'add_fund_event.dart';
part 'add_fund_state.dart';

class AddFundBloc extends Bloc<AddFundEvent, AddFundState> {
  AddFundBloc(this.repository) : super(AddFundInitial()) {
    on<AddFundDeleteRequested>(_onDeleteAccountFunding);
    on<AddFundSubmitted>(_onAddAccountFunding);
    on<AddFundUpdated>(_onUpdateAccountFunding);
  }

  final AddFundRepository repository;

  Future<void> _onAddAccountFunding(
    AddFundSubmitted event,
    Emitter<AddFundState> emit,
  ) async {
    emit(AddFundSaving());
    try {
      await repository.addAccountFunding(event.data);
      emit(AddFundSaved(isRecurring: event.data.isRecurring));
    } on MessageFailure catch (error) {
      emit(AddFundFailure(error.message));
    } on Failure catch (error) {
      emit(AddFundFailure(error.message));
    } catch (_) {
      emit(AddFundFailure('Unable to save this account funding right now.'));
    }
  }

  Future<void> _onDeleteAccountFunding(
    AddFundDeleteRequested event,
    Emitter<AddFundState> emit,
  ) async {
    emit(AddFundSaving());
    try {
      await repository.deleteAccountFunding(event.funding);
      emit(AddFundDeleted());
    } on MessageFailure catch (error) {
      emit(AddFundFailure(error.message));
    } on Failure catch (error) {
      emit(AddFundFailure(error.message));
    } catch (_) {
      emit(AddFundFailure('Unable to delete this account funding right now.'));
    }
  }

  Future<void> _onUpdateAccountFunding(
    AddFundUpdated event,
    Emitter<AddFundState> emit,
  ) async {
    emit(AddFundSaving());
    try {
      await repository.updateAccountFunding(event.data);
      emit(const AddFundSaved(isRecurring: false, isUpdated: true));
    } on MessageFailure catch (error) {
      emit(AddFundFailure(error.message));
    } on Failure catch (error) {
      emit(AddFundFailure(error.message));
    } catch (_) {
      emit(AddFundFailure('Unable to update this account funding right now.'));
    }
  }
}
