import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/company_model.dart';
import '../../domain/repositories/company_repository.dart';
part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyRepository repository;
  CompanyBloc(this.repository) : super(CompanyInitial()) {
    on<CreateCompanyEvent>((event, emit) async {
      emit(CompanyLoading());
      try {
        await repository.createCompany(event.company, event.logoFile);
        emit(CompanyCreated());
        add(GetAllCompanyRequested());
      } catch (e) {
        emit(CompanyError(e is Failure ? e : UnknownFailure()));
      }
    });
  }
}
