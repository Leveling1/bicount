// bloc/list_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../domain/entities/company_model.dart';
import '../../../domain/repositories/company_repository.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  final CompanyRepository repository;
  List<CompanyModel>? _cachedCompanies;

  ListBloc(this.repository) : super(ListInitial()) {
    on<GetAllCompany>(_getAllCompany);
  }




  Future<void> _getAllCompany(GetAllCompany event, Emitter<ListState> emit) async {

    // Émettre directement le cache si disponible
    if (_cachedCompanies != null) {
      emit(ListLoaded(List.from(_cachedCompanies!)));
      return;
    }

    emit(ListLoading());
    try {
      // Écoute le stream Realtime
      await emit.forEach<List<CompanyModel>>(
        repository.getCompanyStream(),
        onData: (companies) {
          // Mettre à jour le cache interne
          _cachedCompanies = List.from(companies);
          return ListLoaded(List.from(companies));
        },
        onError: (error, stackTrace) =>
            ListError(ServerFailure(error.toString())),
      );
    } catch (e) {
      emit(ListError(ServerFailure(e.toString())));
    }
  }
}