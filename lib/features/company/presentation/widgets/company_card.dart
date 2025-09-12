import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/company_model.dart';

class CompanyCard extends StatelessWidget {
  final CompanyModel company;
  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        context.push('/companyDetail', extra: company);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: Theme.of(context).cardColor,
              radius: 20,
              child: SizedBox(
                width: 30.w,
                height: 30.h,
                child: CachedNetworkImage(
                  imageUrl: company.image!,
                  placeholder: (context, url) => const CircularProgressIndicator(), // affiché en attendant
                  errorWidget: (context, url, error) => const Icon(Icons.error),   // si l’image échoue
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Name and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "time",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
