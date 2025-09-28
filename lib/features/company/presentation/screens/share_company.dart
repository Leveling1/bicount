import 'package:flutter/material.dart';

class ShareCompany extends StatefulWidget {
  final String CID;
  const ShareCompany({super.key, required this.CID});

  @override
  State<ShareCompany> createState() => _ShareCompanyState();
}

class _ShareCompanyState extends State<ShareCompany> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Share company",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5,),
        Text(
          "Use the QR code or link to allow another user of the application to access this company.",
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10,),

      ],
    );
  }
}
