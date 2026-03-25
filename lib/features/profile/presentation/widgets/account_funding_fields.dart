import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/profile/domain/entities/add_account_funding_entity.dart';
import 'package:bicount/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bicount/features/profile/presentation/widgets/account_funding_selectors_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountFundingForm extends StatefulWidget {
  const AccountFundingForm({super.key});

  @override
  State<AccountFundingForm> createState() => _AccountFundingFormState();
}

class _AccountFundingFormState extends State<AccountFundingForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _source = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _currency = TextEditingController();
  final TextEditingController _note = TextEditingController();

  bool _isRecurring = false;
  int _selectedFundingType = AccountFundingType.other;
  int? _selectedFrequency;

  @override
  void dispose() {
    _source.dispose();
    _date.dispose();
    _amount.dispose();
    _currency.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is AccountFundingAdded) {
          NotificationHelper.showSuccessNotification(
            context,
            state.isRecurring
                ? context.l10n.accountFundingRecurringSavedSuccess
                : context.l10n.accountFundingSavedSuccess,
          );
          Navigator.pop(context);
        } else if (state is AccountFundingError) {
          NotificationHelper.showFailureNotification(
            context,
            localizeRuntimeMessage(context, state.message),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                context.l10n.accountFundingIntro,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              AccountFundingSelectorsSection(
                selectedFundingType: _selectedFundingType,
                isRecurring: _isRecurring,
                selectedFrequency: _selectedFrequency,
                onFundingTypeChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFundingType = value);
                  }
                },
                onRecurringChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                    _selectedFrequency ??= value ? Frequency.monthly : null;
                  });
                },
                onFrequencyChanged: (value) {
                  setState(() => _selectedFrequency = value);
                },
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _source,
                label: context.l10n.commonSource,
                hint: context.l10n.accountFundingEnterSource,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.commonAmount,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  CustomAmountField(amount: _amount, currency: _currency),
                ],
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _note,
                label: context.l10n.commonNote,
                hint: context.l10n.commonPlaceholderNote,
                enableValidator: false,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _date,
                hint: context.l10n.commonDateHint,
                inputType: TextInputType.datetime,
                isDate: true,
                label: _isRecurring
                    ? context.l10n.accountFundingFirstCreditDate
                    : context.l10n.commonWhen,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: context.l10n.commonSave,
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isRecurring && _selectedFrequency == null) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.validationFieldRequired,
      );
      return;
    }

    context.read<ProfileBloc>().add(
      AddAccountFundingEvent(
        data: AddAccountFundingEntity(
          source: _source.text,
          amount: double.parse(_amount.text),
          currency: _currency.text,
          note: _note.text,
          date: _date.text,
          fundingType: _selectedFundingType,
          isRecurring: _isRecurring,
          frequency: _selectedFrequency,
        ),
      ),
    );
  }
}
