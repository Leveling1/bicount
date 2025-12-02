import 'package:bicount/core/constants/subscription_const.dart';
import 'package:bicount/core/services/notification_helper.dart';
import 'package:bicount/core/widgets/custom_amount_field.dart';
import 'package:bicount/core/widgets/custom_button.dart';
import 'package:bicount/core/widgets/custom_form_text_field.dart';
import 'package:bicount/features/transaction/domain/entities/subscription_entity.dart';
import 'package:bicount/features/transaction/presentation/bloc/transaction_bloc.dart';
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
  final TextEditingController _note = TextEditingController();

  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is SubscriptionAdded) {
          NotificationHelper.showSuccessNotification(
            context,
            'Subscription saved successfully!',
          );
          Navigator.pop(context);
        } else if (state is SubscriptionError) {
          NotificationHelper.showFailureNotification(context, state.message);
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Register a recurring payment such as streaming services, internet, gym, software, or any repetitive expense.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Name
              CustomFormField(
                controller: _name,
                label: "Subscription name",
                hint: "e.g. Netflix, Spotify...",
              ),
              const SizedBox(height: 16),

              // Amount + currency
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

              // Frequency
              CustomFormField(
                controller: _frequency,
                label: "Frequency",
                hint: "Monthly, Weekly, Yearly...",
              ),
              const SizedBox(height: 16),

              // Start date
              CustomFormField(
                controller: _startDate,
                label: "Start date",
                hint: "DD/MM/YYYY",
                isDate: true,
                inputType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),

              // Notes
              CustomFormField(
                controller: _note,
                label: "Note",
                hint: "Add a note (optional)",
                enableValidator: false,
              ),

              const SizedBox(height: 32),

              // Save button
              CustomButton(
                text: "Save",
                loading: state is SubscriptionLoading,
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
      final now = DateTime.now();
      BlocProvider.of<TransactionBloc>(context).add(
        AddSubscriptionEvent(
          SubscriptionEntity(
            title: _name.text,
            amount: double.parse(_amount.text),
            currency: _currency.text,
            frequency: int.parse(_frequency.text),
            customIntervalDays: null, // gérer plus tard si besoin
            startDate: _startDate.text,
            nextBillingDate: _startDate.text,
            note: _note.text,
            status: SubscriptionConst.active,
            createdAt: now.toIso8601String(),
          ),
        ),
      );
    }
  }
}
