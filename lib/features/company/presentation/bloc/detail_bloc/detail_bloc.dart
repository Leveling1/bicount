// bloc/detail_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../domain/entities/company_model.dart';
import '../../../domain/repositories/company_repository.dart';

part 'detail_state.dart';
part 'detail_event.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final CompanyRepository repository;
  CompanyModel? _cachedCompanyDetail;

  DetailBloc(this.repository) : super(DetailInitial()) {
    on<GetCompanyDetail>(_getCompanyDetail);
  }

  // For the company details
  Future<void> _getCompanyDetail(GetCompanyDetail event, Emitter<DetailState> emit) async {
    // Émettre directement le cache si disponible
    if (_cachedCompanyDetail != null && _cachedCompanyDetail!.id == event.company.id) {
      emit(DetailLoaded(_cachedCompanyDetail!));
      return;
    }

    emit(DetailLoading());
    try {
      // Écoute le stream Realtime
      await emit.forEach<CompanyModel>(
        repository.getCompanyDetailStream(event.company),
        onData: (companyDetail) {
          // Mettre à jour le cache interne
          _cachedCompanyDetail = companyDetail;
          return DetailLoaded(companyDetail);
        },
        onError: (error, stackTrace) =>
            DetailError(ServerFailure(error.toString())),
      );
    } catch (e) {
      emit(DetailError(ServerFailure(e.toString())));
    }
  }
}