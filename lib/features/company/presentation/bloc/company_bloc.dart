// bloc/company_bloc.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failure.dart';
import '../../../group/domain/entities/group_model.dart';
import '../../domain/entities/company.dart';
import '../../domain/repositories/company_repository.dart';
part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyRepository repository;

  CompanyBloc(this.repository) : super(CompanyInitial()) {
    on<CreateCompanyEvent>(_onCreateCompany);
  }

  Future<void> _onCreateCompany(CreateCompanyEvent event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      final createdCompany =
      await repository.createCompany(event.company, event.logoFile);
      emit(CompanyCreated(createdCompany));
      add(GetAllCompany());
    } catch (e) {
      emit(CompanyError(e is Failure ? e : UnknownFailure()));
    }
  }
}