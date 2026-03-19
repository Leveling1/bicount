import 'package:bicount/app/app_providers.dart';
import 'package:bicount/core/constants/app_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlocScope extends StatelessWidget {
  final Widget child;

  const BlocScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final enableCompanySurface = AppConfig.exposeCompanySurface;
    return MultiRepositoryProvider(
      providers: buildRepositoryProviders(enableCompanySurface),
      child: MultiBlocProvider(
        providers: buildBlocProviders(enableCompanySurface),
        child: child,
      ),
    );
  }
}
