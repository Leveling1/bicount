import 'package:bicount/core/constants/dropdown_menu_entry.dart';
import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/localization/l10n_extensions.dart';
import 'package:bicount/core/localization/runtime_message_localizer.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/services/smooth_insert.dart';
import 'package:bicount/core/utils/form_date_utils.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_dropdown_menu.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/subscription/domain/entities/subscription_entity.dart';
import 'package:bicount/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionForm extends StatefulWidget {
  const SubscriptionForm({super.key});

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

  @override
  void initState() => super.initState();

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
            context.l10n.subscriptionSavedSuccess,
          );
          Navigator.pop(context);
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
                context.l10n.subscriptionIntro,
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

    final now = DateTime.now();
    final nextBillingDate = isDifferentDate
        ? _resolveSubscriptionDate(_nextBillingDate.text)
        : _resolveSubscriptionDate(_startDate.text);
    context.read<SubscriptionBloc>().add(
      AddSubscriptionRequested(
        SubscriptionEntity(
          title: _name.text,
          amount: double.parse(_amount.text),
          currency: _currency.text,
          frequency: int.parse(_frequency.text),
          startDate: _resolveSubscriptionDate(_startDate.text),
          nextBillingDate: nextBillingDate,
          note: _note.text,
          status: SubscriptionConst.active,
          createdAt: now.toIso8601String(),
        ),
      ),
    );
  }

  String _resolveSubscriptionDate(String rawDate) {
    return resolveFormDateToIso(rawDate);
  }
}
