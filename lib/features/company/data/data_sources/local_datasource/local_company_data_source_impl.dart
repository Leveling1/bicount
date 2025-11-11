import 'dart:async';

import 'package:bicount/features/company/data/models/company.model.dart';
import 'package:bicount/features/company/data/models/company_with_user_link.model.dart';
import 'package:bicount/features/project/data/models/project.model.dart';
import 'package:brick_core/core.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../brick/repository.dart';
import '../../../../../core/errors/failure.dart';
import '../../../../group/data/models/group.model.dart';
import 'company_local_datasource.dart';

class LocalCompanyDataSourceImpl implements CompanyLocalDataSource {
  final supabaseInstance = Supabase.instance.client;
  late String uid = supabaseInstance.auth.currentUser!.id;

  /// For the all company
  final BehaviorSubject<List<CompanyModel>> _company = BehaviorSubject<List<CompanyModel>>.seeded([]);
  StreamSubscription<List<CompanyModel>>? _realtimeSubscription;
  bool _isInitialized = false;

  @override
  Stream<List<CompanyModel>> getCompany() {
    // Initialiser une seule fois
    if (!_isInitialized) {
      _initializeRealtimeSubscription();
    }
    return _company.stream;
  }

  void _initializeRealtimeSubscription() {
    try {
      _realtimeSubscription = Repository().subscribeToRealtime<CompanyModel>().listen(
            (members) {
          _company.add(members);
        },
        onError: (error) {
          _company.addError(
            MessageFailure(message: "Une erreur s'est produite : ${error.toString()}"),
          );
        },
      );
      _isInitialized = true;
    } catch (e) {
      _company.addError(
        MessageFailure(message: "Erreur d'initialisation : ${e.toString()}"),
      );
    }
  }

  /// For detail company
  final Map<String, BehaviorSubject<CompanyModel>> _companyDetailsCache = {};
  final Map<String, StreamSubscription<List<CompanyModel>>> _companyDetailsSubscriptions = {};

  @override
  Stream<CompanyModel> getCompanyDetails(String companyId) {
    try {
      // Si déjà en cache, retourner le stream existant
      if (_companyDetailsCache.containsKey(companyId)) {
        return _companyDetailsCache[companyId]!.stream;
      }

      // Créer un nouveau BehaviorSubject pour cette entreprise
      final companyDetailsController = BehaviorSubject<CompanyModel>();
      _companyDetailsCache[companyId] = companyDetailsController;

      // CORRECTION: Le type de subscription est StreamSubscription<List<CompanyModel>>
      final StreamSubscription<List<CompanyModel>> subscription =
      Repository().subscribeToRealtime<CompanyModel>(
          query: Query(where: [Where.exact('cid', companyId)])
      ).listen((List<CompanyModel> companies) { // Spécifier le type List<CompanyModel>
        if (companies.isNotEmpty) {
          // Prendre le premier élément de la liste
          companyDetailsController.add(companies.first);
        } else {
          companyDetailsController.addError(
              MessageFailure(message: "Entreprise non trouvée")
          );
        }
      }, onError: (error) {
        companyDetailsController.addError(error);
      });

      _companyDetailsSubscriptions[companyId] = subscription;

      return companyDetailsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des détails: ${e.toString()}"),
      );
    }
  }

  // Méthode pour libérer les ressources d'une entreprise spécifique
  void disposeCompanyDetails(String cid) {
    _companyDetailsSubscriptions[cid]?.cancel();
    _companyDetailsSubscriptions.remove(cid);
    _companyDetailsCache[cid]?.close();
    _companyDetailsCache.remove(cid);
  }

  void dispose() {
    _realtimeSubscription?.cancel();
    _company.close();
    _isInitialized = false;
  }

  void close() {
    // Nettoyer les abonnements aux détails
    for (final subscription in _companyDetailsSubscriptions.values) {
      subscription.cancel();
    }
    _companyDetailsSubscriptions.clear();

    for (final controller in _companyDetailsCache.values) {
      controller.close();
    }
    _companyDetailsCache.clear();
  }

  /// For the projects company
  final Map<String, BehaviorSubject<List<ProjectModel>>> _projectCompanyCache = {};
  final Map<String, StreamSubscription<List<ProjectModel>>> _projectCompanySubscriptions = {};

  @override
  Stream<List<ProjectModel>> getCompanyProjects(String cid) {
    try {
      // Vérifier si on a déjà un cache pour cette entreprise
      if (_projectCompanyCache.containsKey(cid)) {
        return _projectCompanyCache[cid]!.stream;
      }

      // CORRECTION: Créer un BehaviorSubject pour une LISTE de projets, pas un seul projet
      final projectsController = BehaviorSubject<List<ProjectModel>>.seeded([]);
      _projectCompanyCache[cid] = projectsController;

      // S'abonner aux projets de l'entreprise
      final StreamSubscription<List<ProjectModel>> subscription =
      Repository().subscribeToRealtime<ProjectModel>(
          query: Query(where: [Where.exact('cid', cid)])
      ).listen((List<ProjectModel> projects) { // projects est déjà une List<ProjectModel>
        // CORRECTION: Ajouter la liste complète des projets, pas juste le premier
        projectsController.add(projects);
      }, onError: (error) {
        projectsController.addError(error);
      });

      _projectCompanySubscriptions[cid] = subscription;

      return projectsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des projets: ${e.toString()}"),
      );
    }
  }


  /// For the groups company
  final Map<String, BehaviorSubject<List<GroupModel>>> _groupCompanyCache = {};
  final Map<String, StreamSubscription<List<GroupModel>>> _groupCompanySubscriptions = {};

  @override
  Stream<List<GroupModel>> getCompanyGroups(String cid) {
    try {
      if (_groupCompanyCache.containsKey(cid)) {
        return _groupCompanyCache[cid]!.stream;
      }

      final groupsController = BehaviorSubject<List<GroupModel>>.seeded([]);
      _groupCompanyCache[cid] = groupsController;

      final StreamSubscription<List<GroupModel>> subscription =
      Repository().subscribeToRealtime<GroupModel>(
          query: Query(where: [Where.exact('cid', cid)])
      ).listen((List<GroupModel> groups) {
        groupsController.add(groups);
      }, onError: (error) {
        groupsController.addError(error);
      });

      _groupCompanySubscriptions[cid] = subscription;

      return groupsController.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des groupes: ${e.toString()}"),
      );
    }
  }

  // Méthode pour nettoyer le cache
  void disposeCompanyGroups(String cid) {
    _groupCompanySubscriptions[cid]?.cancel();
    _groupCompanySubscriptions.remove(cid);

    _groupCompanyCache[cid]?.close();
    _groupCompanyCache.remove(cid);
  }

  /// For the company links
  BehaviorSubject<List<CompanyWithUserLinkModel>>? _linksController;

  @override
  Stream<List<CompanyWithUserLinkModel>> getCompanyLinks() {
    try {
      if (_linksController != null) {
        return _linksController!.stream;
      }

      _linksController = BehaviorSubject<List<CompanyWithUserLinkModel>>.seeded([]);

      Repository().subscribeToRealtime<CompanyWithUserLinkModel>().listen(
        (List<CompanyWithUserLinkModel> links) {
          _linksController?.add(links);
        },
        onError: (error) {
          _linksController?.addError(error);
        },
      );

      return _linksController!.stream;
    } catch (e) {
      return Stream.error(
        MessageFailure(message: "Erreur lors de la récupération des liens: ${e.toString()}"),
      );
    }
  }
}