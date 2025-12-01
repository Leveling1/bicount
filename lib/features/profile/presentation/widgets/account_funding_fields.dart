import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/profile/domain/entities/add_account_funding_entity.dart';
import 'package:bicount/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountFundingForm extends StatefulWidget {
  const AccountFundingForm({super.key});

  @override
  State<AccountFundingForm> createState() => _AccountFundingFormState();
}

class _AccountFundingFormState extends State<AccountFundingForm> {
  final TextEditingController _source = TextEditingController(),
      _date = TextEditingController(),
      _amount = TextEditingController(),
      _currency = TextEditingController(),
      _note = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is AccountFundingAdded) {
          NotificationHelper.showSuccessNotification(context, 'Account funding transaction added successfully');
          Navigator.pop(context);
        } else if (state is AccountFundingError) {
          NotificationHelper.showFailureNotification(
            context,
            state.message,
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Add money to your account securely by recording a new deposit or credit to increase your available balance.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _source,
                label: "Source",
                hint: 'Enter source of funds',
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Amount",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  CustomAmountField(amount: _amount, currency: _currency),
                ],
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _note,
                label: "Note",
                hint: 'Add a note (optional)',
                enableValidator: false,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _date,
                hint: 'DD/MM/YYYY',
                inputType: TextInputType.datetime,
                isDate: true,
                label: 'When',
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save',
                loading: state is AccountFundingLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<ProfileBloc>(context).add(
        AddAccountFundingEvent(
          data: AddAccountFundingEntity(
            source: _source.text,
            amount: double.parse(_amount.text),
            currency: _currency.text,
            note: _note.text,
            date: _date.text,
          ),
        ),
      );
    }
  }
}
