// bloc/company_bloc.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/company_model.dart';
import '../../domain/repositories/company_repository.dart';
part 'company_event.dart';
part 'company_state.dart';

class CompanyBloc extends Bloc<CompanyEvent, CompanyState> {
  final CompanyRepository repository;
  StreamSubscription? _streamSubscription;
  List<CompanyModel> _companies = [];

  CompanyBloc(this.repository) : super(CompanyInitial()) {
    on<CreateCompanyEvent>(_onCreateCompany);
    on<GetAllCompany>(_getAllCompany);
    on<CompanyDataUpdated>(_onDataUpdated);
    on<CompanyStreamError>(_onStreamError);
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

  Future<void> _getAllCompany(GetAllCompany event, Emitter<CompanyState> emit) async {
    emit(CompanyLoading());

    // Annuler tout abonnement existant
    await _streamSubscription?.cancel();

    try {
      _streamSubscription = repository.getCompanyStream().listen(
            (companies) {
          // Ajouter un événement plutôt que d'émettre directement
          add(CompanyDataUpdated(companies));
        },
        onError: (error) {
          add(CompanyStreamError(error));
        },
      );
    } catch (e) {
      if (!isClosed) {
        emit(CompanyError(e is Failure ? e : UnknownFailure()));
      }
    }
  }

  void _onDataUpdated(CompanyDataUpdated event, Emitter<CompanyState> emit) {
    if (!isClosed) {
      _companies = event.companies;
      emit(CompanyLoaded(_companies));
    }
  }

  void _onStreamError(CompanyStreamError event, Emitter<CompanyState> emit) {
    if (!isClosed) {
      emit(CompanyError(event.error is Failure ? event.error : UnknownFailure()));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    repository.disconnect();
    return super.close();
  }
}