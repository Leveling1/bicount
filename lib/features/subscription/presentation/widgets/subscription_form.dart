import 'package:bicount/core/constants/dropdown_menu_entry.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/services/smooth_insert.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_dropdown_menu.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/subscription/data/models/subscription.model.dart';
import 'package:bicount/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:bicount/features/subscription/presentation/helpers/subscription_form_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionForm extends StatefulWidget {
  const SubscriptionForm({
    super.key,
    this.initialSubscription,
    this.onCompleted,
  });

  final SubscriptionModel? initialSubscription;
  final VoidCallback? onCompleted;

  @override
  State<SubscriptionForm> createState() => _SubscriptionFormState();
}

class _SubscriptionFormState extends State<SubscriptionForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _currency = TextEditingController();
  final TextEditingController _frequency = TextEditingController();
  final TextEditingController _startDate = TextEditingController();
  final TextEditingController _nextBillingDate = TextEditingController();
  final TextEditingController _note = TextEditingController();

  bool isDifferentDate = false;
  bool get _isEditing => widget.initialSubscription != null;

  @override
  void initState() {
    super.initState();
    final initialSubscription = widget.initialSubscription;
    if (initialSubscription != null) {
      hydrateSubscriptionForm(
        subscription: initialSubscription,
        nameController: _name,
        amountController: _amount,
        currencyController: _currency,
        frequencyController: _frequency,
        startDateController: _startDate,
        nextBillingDateController: _nextBillingDate,
        noteController: _note,
        onDifferentDate: (value) => isDifferentDate = value,
      );
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _currency.dispose();
    _frequency.dispose();
    _startDate.dispose();
    _nextBillingDate.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionSaved) {
          NotificationHelper.showSuccessNotification(
            context,
            state.isUpdated
                ? context.l10n.subscriptionUpdatedSuccess
                : context.l10n.subscriptionSavedSuccess,
          );
          final onCompleted = widget.onCompleted;
          if (onCompleted != null) {
            onCompleted();
          } else {
            Navigator.pop(context);
          }
        } else if (state is SubscriptionFailure) {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing
                    ? context.l10n.subscriptionEditTitle
                    : context.l10n.subscriptionIntro,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _name,
                label: context.l10n.subscriptionName,
                hint: context.l10n.subscriptionNameHint,
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
              CustomDropdownMenu(
                title: context.l10n.commonFrequency,
                hintText: context.l10n.subscriptionFrequencyHint,
                initialValue: int.tryParse(_frequency.text),
                onChanged: (value) =>
                    setState(() => _frequency.text = '$value'),
                menuEntries: DropdownMenuEntryConstants.frequencyEntries(
                  context,
                ),
              ),
              const SizedBox(height: 16),
              CustomFormField(
                controller: _startDate,
                label: context.l10n.subscriptionStartDate,
                hint: context.l10n.commonDateHint,
                isDate: true,
                inputType: TextInputType.datetime,
              ),
              CheckboxListTile(
                value: isDifferentDate,
                onChanged: (checked) =>
                    setState(() => isDifferentDate = checked ?? false),
                title: Text(
                  context.l10n.subscriptionNextPaymentDifferent,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              SmoothInsert(
                visible: isDifferentDate,
                child: Column(
                  children: [
                    CustomFormField(
                      controller: _nextBillingDate,
                      label: context.l10n.subscriptionNextBillingDate,
                      hint: context.l10n.commonDateHint,
                      isDate: true,
                      inputType: TextInputType.datetime,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              CustomFormField(
                controller: _note,
                label: context.l10n.commonNote,
                hint: context.l10n.commonPlaceholderNote,
                enableValidator: false,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: context.l10n.commonSave,
                loading: state is SubscriptionSaving,
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final payload = buildSubscriptionPayload(
      initialSubscription: widget.initialSubscription,
      title: _name.text,
      amount: _amount.text,
      currency: _currency.text,
      frequency: _frequency.text,
      startDate: _startDate.text,
      nextBillingDate: isDifferentDate
          ? _nextBillingDate.text
          : _startDate.text,
      note: _note.text,
    );
    final event = _isEditing
        ? UpdateSubscriptionRequested(payload)
        : AddSubscriptionRequested(payload);
    context.read<SubscriptionBloc>().add(event);
  }
}
