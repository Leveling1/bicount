import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bicount/features/company/presentation/bloc/company_bloc.dart';
import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_form_text_field.dart';
import '../../../../core/widgets/custom_pick_image.dart';
import '../../domain/entities/company_model.dart';

class AddCompany extends StatefulWidget {
  const AddCompany({super.key});

  @override
  State<AddCompany> createState() => _AddCompanyState();
}

class _AddCompanyState extends State<AddCompany> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();

  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompanyBloc, CompanyState>(
      listener: (context, state) {
        if (state is CompanyCreated) {
          NotificationHelper.showSuccessNotification(
              context,
              "Company successfully established"
          );
          Navigator.of(context).pop();
        } else if (state is CompanyError) {
          NotificationHelper.showFailureNotification(context, state.failure.message);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Add company',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Logo", style: Theme.of(context).textTheme.titleMedium),
                        CustomPickImage(
                          selectedImage: _selectedImage,
                          onImageSelected: (File? image) {
                            setState(() {
                              _selectedImage = image;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 4,
                    child: CustomFormField(
                      controller: _name,
                      label: "Company name",
                      hint: 'Enter company name',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _description,
                label: "Description",
                hint: 'Enter company description',
                inputType: TextInputType.multiline,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save',
                loading: state is CompanyLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final company = CompanyModel(
        name: _name.text,
        description: _description.text,
        image: "",
      );
      context.read<CompanyBloc>().add(CreateCompanyEvent(company, logoFile: _selectedImage));
    }
  }
}
