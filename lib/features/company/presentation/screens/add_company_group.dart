import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bicount/features/company/presentation/bloc/company_bloc.dart';
import '../../../../core/services/notification_helper.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_form_text_field.dart';
import '../../../../core/widgets/custom_pick_image.dart';
import '../../domain/entities/company_group_model.dart';

class AddCompanyGroup extends StatefulWidget {
  final int idCompany;
  const AddCompanyGroup({super.key, required this.idCompany});

  @override
  State<AddCompanyGroup> createState() => _AddCompanyGroupState();
}

class _AddCompanyGroupState extends State<AddCompanyGroup> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _description = TextEditingController();

  File? _selectedImage;

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompanyBloc, CompanyState>(
        listener: (context, state) {
          if (state is CompanyGroupCreated) {
            NotificationHelper.showSuccessNotification(
              context,
              "Group successfully established"
            );
            Navigator.of(context).pop();
          } else if (state is CompanyGroupError) {
            NotificationHelper.showFailureNotification(
              context,
              state.failure.message
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Add group company',
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
                        label: "Group name",
                        hint: 'Enter group name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a group name';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomFormField(
                  controller: _description,
                  label: "Description",
                  hint: 'Enter group description',
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
      final group = CompanyGroupModel(
        idCompany: widget.idCompany,
        name: _name.text,
        description: _description.text,
      );
      context.read<CompanyBloc>().add(
        CreateCompanyGroupEvent(
          group,
          logoFile: _selectedImage
        )
      );
    }
  }
}
