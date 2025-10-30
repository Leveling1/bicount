// bloc/list_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/errors/failure.dart';
import '../../../data/models/company.model.dart';
import '../../../domain/entities/company.dart';
import '../../../domain/repositories/company_repository.dart';

part 'list_event.dart';
part 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  final CompanyRepository repository;

  ListBloc(this.repository) : super(ListInitial()) {
    on<GetAllCompany>(_getAllCompany);
  }

  Future<void> _getAllCompany(GetAllCompany event, Emitter<ListState> emit) async {
    emit(ListLoading());
    try {
      // Écoute le stream Realtime
      await emit.forEach<List<CompanyModel>>(
        repository.getCompanyStream(),
        onData: (companies) {
          // Mettre à jour le cache interne
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