import 'dart:async';

import 'package:bicount/features/company/data/models/company.model.dart';
import 'package:bicount/features/company/data/models/company_with_user_link.model.dart';
import 'package:brick_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../brick/repository.dart';
import '../../../../../core/errors/failure.dart';
import 'company_local_datasource.dart';

class LocalCompanyDataSourceImpl implements CompanyLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  late String uid = supabaseInstance.auth.currentUser!.id;

  // Function for get the company link
  final _companyLinks = StreamController<List<CompanyWithUserLinkModel>>.broadcast();
  @override
  Stream<List<CompanyWithUserLinkModel>> getCompanyLink() {
    try {
      Repository().subscribeToRealtime<CompanyWithUserLinkModel>
      (query: Query(where: [Where.exact('userId', uid)])).listen((companyLinks) {
        _companyLinks.add(companyLinks);
      });
      return _companyLinks.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Une erreur s'est produite : ${e.toString()}"),
      );
    }
  }


  // Function for get the company
  final StreamController<List<CompanyModel>> _company = StreamController<List<CompanyModel>>.broadcast();
  List<CompanyModel> _currentCompanies = []; // Pour garder une trace des entreprises actuelles

  StreamSubscription? _companyLinksSubscription;
  final Map<String, StreamSubscription> _companySubscriptions = {};

  @override
  Stream<List<CompanyModel>> getCompany(Stream<List<CompanyWithUserLinkModel>> companyLinks) {
    try {
      // Annuler les abonnements précédents aux companyLinks
      _companyLinksSubscription?.cancel();

      // Écouter les changements de la liste des companyLinks
      _companyLinksSubscription = companyLinks.listen((List<CompanyWithUserLinkModel> links) {
        // Extraire tous les companyId de la nouvelle liste
        final companyIds = links.map((link) => link.companyId).toList();

        // Gérer l'abonnement aux entreprises en temps réel
        _updateCompanySubscriptions(companyIds);
      }, onError: (error) {
        Stream.error(
          MessageFailure(message: "Une erreur s'est produite : ${error.toString()}"),
        );
      });

      return _company.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Une erreur s'est produite : ${e.toString()}"),
      );
    }
  }

  void _updateCompanySubscriptions(List<String> companyIds) {
    // Annuler les abonnements aux entreprises qui ne sont plus dans la liste
    final currentIds = _companySubscriptions.keys.toSet();
    final newIds = companyIds.toSet();
    final idsToRemove = currentIds.difference(newIds);

    for (final id in idsToRemove) {
      _companySubscriptions[id]?.cancel();
      _companySubscriptions.remove(id);
    }

    // Ajouter des abonnements pour les nouvelles entreprises
    for (final companyId in companyIds) {
      if (!_companySubscriptions.containsKey(companyId)) {
        final subscription = Repository().subscribeToRealtime<CompanyModel>(
            query: Query(where: [Where.exact('cid', companyId)])
        ).listen((companies) {
          _updateCompaniesList(companies);
        }, onError: (error) {
          Stream.error(
            MessageFailure(message: "Une erreur s'est produite : ${error.toString()}"),
          );
        });

        _companySubscriptions[companyId] = subscription;
      }
    }

    // Si la liste est vide, émettre une liste vide
    if (companyIds.isEmpty) {
      _currentCompanies = [];
      _company.add([]);
    }
  }

  void _updateCompaniesList(List<CompanyModel> newCompanies) {
    // Créer une map des entreprises actuelles par ID
    final currentCompaniesMap = <String, CompanyModel>{};
    for (var company in _currentCompanies) {
      currentCompaniesMap[company.cid!] = company;
    }

    // Mettre à jour avec les nouvelles entreprises
    for (final company in newCompanies) {
      currentCompaniesMap[company.cid!] = company;
    }

    // Convertir en liste et mettre à jour le cache
    _currentCompanies = currentCompaniesMap.values.toList();

    // Émettre la nouvelle liste
    _company.add(_currentCompanies);
  }

  // Méthode pour libérer les ressources
  void close() {
    _companyLinksSubscription?.cancel();

    // Annuler tous les abonnements aux entreprises individuelles
    for (final subscription in _companySubscriptions.values) {
      subscription.cancel();
    }
    _companySubscriptions.clear();

    _company.close();
  }
}