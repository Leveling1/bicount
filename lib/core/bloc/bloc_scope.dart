import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class BlocScope extends StatelessWidget {
  final Widget child;

  const BlocScope({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
		//TODO: ADD here BlocProvider
	  ],
      child: child,
    );
  }
}
