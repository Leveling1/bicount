import 'package:flutter/material.dart';

import '../../domain/entities/company_group_model.dart';
import 'company_profil.dart';

class GroupCard extends StatelessWidget {
  final CompanyGroupModel group;
  const GroupCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          CompanyProfil(
            width: 120,
            height: 120,
            radius: 50,
            image: group.image,
          ),
          Text(
            group.name
          ),
          Text(
            '${group.number} members'
          ),
        ],
      ),
    );
  }
}
