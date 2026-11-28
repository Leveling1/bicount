import 'package:bicount/core/themes/app_dimens.dart';
import 'package:flutter/material.dart';

class ShareCompany extends StatefulWidget {
  final String cid;
  const ShareCompany({super.key, required this.cid});

  @override
  State<ShareCompany> createState() => _ShareCompanyState();
}

class _ShareCompanyState extends State<ShareCompany> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Share company", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSizes.dp5),
        Text(
          "Use the QR code or link to allow another user of the application to access this company.",
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSizes.dp10),
      ],
    );
  }
}
