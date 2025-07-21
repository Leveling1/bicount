import 'package:flutter/cupertino.dart';

import '../../domain/entities/company_model.dart';

class DetailCompanyScreen extends StatefulWidget {
  final CompanyModel company;
  const DetailCompanyScreen({super.key, required this.company});

  @override
  State<DetailCompanyScreen> createState() => _DetailCompanyScreenState();
}

class _DetailCompanyScreenState extends State<DetailCompanyScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
