import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/custom_bottom_sheet.dart';
import '../widgets/company_choice_handler.dart';
import 'add_company.dart';
import 'join_company.dart';


class CompanyHandler extends StatefulWidget {
  const CompanyHandler({super.key});

  @override
  State<CompanyHandler> createState() => _CompanyHandlerState();
}

class _CompanyHandlerState extends State<CompanyHandler> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Text(
              'Add',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(width: 48.w), // Pour équilibrer l'IconButton
          ],
        ),
        SizedBox(height: 20.h,),
        CompanyChoiceHandler(
          title: 'Start a new company',
          content: 'Create a new company from scratch',
          color: Theme.of(context).primaryColor,
          icon: Icons.add,
          onTap: () {
            Navigator.of(context).pop();
            showCustomBottomSheet(
              context: context,
              minHeight: 0.95,
              color: null,
              child: const AddCompany(),
            );
          },

        ),
        SizedBox(height: 15.h,),
        CompanyChoiceHandler(
          title: 'Join a company',
          content: 'Use the invitation link to join a company',
          color:  Colors.blue,
          icon: Icons.link,
          onTap: () {
            Navigator.of(context).pop();
            showCustomBottomSheet(
              context: context,
              minHeight: 0.95,
              color: null,
              child: const JoinCompany(),
            );
          },

        )
      ],
    );
  }
}
