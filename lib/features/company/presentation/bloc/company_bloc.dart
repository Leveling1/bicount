// bloc/company_bloc.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/group_model.dart';
import '../../domain/entities/company_model.dart';
import '../../domain/repositories/company_repository.dart';
part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyRepository repository;
  List<CompanyModel>? _cachedCompanies;

  CompanyBloc(this.repository) : super(CompanyInitial()) {
    on<CreateCompanyEvent>(_onCreateCompany);
    on<CreateCompanyGroupEvent>(_onCreateCompanyGroup);
    on<GetAllCompany>(_getAllCompany);
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

  Future<void> _onCreateCompanyGroup(CreateCompanyGroupEvent event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());
    try {
      final createdCompany =
      await repository.createCompanyGroup(event.group, event.logoFile);
      emit(CompanyGroupCreated(createdCompany));
      add(GetAllCompany());
    } catch (e) {
      emit(CompanyError(e is Failure ? e : UnknownFailure()));
    }
  }

  Future<void> _getAllCompany(GetAllCompany event, Emitter<CompanyState> emit) async {

    // Émettre directement le cache si disponible
    if (_cachedCompanies != null) {
      emit(CompanyLoaded(List.from(_cachedCompanies!)));
      return;
    }

    emit(CompanyLoading());
    try {
      // Écoute le stream Realtime
      await emit.forEach<List<CompanyModel>>(
        repository.getCompanyStream(),
        onData: (companies) {
          // Mettre à jour le cache interne
          _cachedCompanies = List.from(companies);
          return CompanyLoaded(List.from(companies));
        },
        onError: (error, stackTrace) =>
            CompanyError(ServerFailure(error.toString())),
      );
    } catch (e) {
      emit(CompanyError(ServerFailure(e.toString())));
    }
  }
}