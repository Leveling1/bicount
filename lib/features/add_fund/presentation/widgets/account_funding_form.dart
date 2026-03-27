import 'package:bicount/core/constants/account_funding_const.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/add_fund/data/models/account_funding.model.dart';
import 'package:bicount/features/add_fund/presentation/bloc/add_fund_bloc.dart';
import 'package:bicount/features/add_fund/presentation/helpers/account_funding_form_mapper.dart';
import 'package:bicount/features/add_fund/presentation/widgets/account_funding_selectors_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountFundingForm extends StatefulWidget {
  const AccountFundingForm({
    super.key,
    this.initialFunding,
    this.onCompleted,
  });

  final AccountFundingModel? initialFunding;
  final VoidCallback? onCompleted;

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
  bool get _isEditing => widget.initialFunding != null;

  @override
  void initState() {
    super.initState();
    final funding = widget.initialFunding;
    if (funding != null) {
      hydrateAccountFundingForm(
        funding: funding,
        sourceController: _source,
        dateController: _date,
        amountController: _amount,
        currencyController: _currency,
        noteController: _note,
        onFundingType: (value) => _selectedFundingType = value,
      );
    }
  }

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
    return BlocConsumer<AddFundBloc, AddFundState>(
      listener: _onStateChanged,
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
                allowRecurring: !_isEditing,
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
                loading: state is AddFundSaving,
                onPressed: _submit,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  void _onStateChanged(BuildContext context, AddFundState state) {
    if (state is AddFundSaved) {
          NotificationHelper.showSuccessNotification(
            context,
            state.isRecurring
                ? context.l10n.accountFundingRecurringSavedSuccess
                : context.l10n.accountFundingSavedSuccess,
          );
      final onCompleted = widget.onCompleted;
      if (onCompleted != null) {
        onCompleted();
      } else {
        Navigator.pop(context);
      }
    } else if (state is AddFundFailure) {
      NotificationHelper.showFailureNotification(
        context,
        localizeRuntimeMessage(context, state.message),
      );
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_isRecurring && _selectedFrequency == null) {
      NotificationHelper.showFailureNotification(
        context,
        context.l10n.validationFieldRequired,
      );
      return;
    }
    final event = buildAddFundEvent(
      initialFunding: widget.initialFunding,
      source: _source.text,
      amount: _amount.text,
      currency: _currency.text,
      note: _note.text,
      date: _date.text,
      fundingType: _selectedFundingType,
      isRecurring: _isRecurring,
      frequency: _selectedFrequency,
    );
    context.read<AddFundBloc>().add(event);
  }
}
